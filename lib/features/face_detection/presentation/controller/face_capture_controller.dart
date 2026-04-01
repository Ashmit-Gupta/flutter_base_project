import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_project_setup/core/services/permission_service.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:basic_project_setup/core/services/face_detector_service.dart';
import 'dart:io';
import '../../../../core/di/core_providers.dart';
import '../../widgets/face_overlay_painter.dart';
import '../model/face_capture_config.dart';

enum CameraStatus { idle, loading, ready, permissionDenied, error }
enum FaceCaptureStep { left, front, right }

class FaceCaptureState extends Equatable {
  final CameraStatus status;
  final CameraController? cameraController;
  final String? errorMessage;

  // ── Step 4: face detection results ───────────────────────────
  final FaceAlignState alignState;
  final double eulerY;      // corrected angle from MLKit
  final int faceCount;      // 0, 1, or 2+
  final FaceCaptureStep currentStep;
  final double progress; // 0.0 -> 1.0 hold progress for current step
  final bool isCaptureComplete;
  final String? lastCapturedPhotoPath;
  final String lastCapturedStepKey;
  final int completedSteps;
  final Map<String, String> capturedPhotoByProfile;

  const FaceCaptureState({
    this.status = CameraStatus.idle,
    this.cameraController,
    this.errorMessage,
    this.alignState = FaceAlignState.idle,
    this.eulerY = 0.0,
    this.faceCount = 0,
    this.currentStep = FaceCaptureStep.left,
    this.progress = 0.0,
    this.isCaptureComplete = false,
    this.lastCapturedPhotoPath,
    this.lastCapturedStepKey = '',
    this.completedSteps = 0,
    this.capturedPhotoByProfile = const <String, String>{},
  });

  FaceCaptureState copyWith({
    CameraStatus? status,
    CameraController? cameraController,
    String? errorMessage,
    FaceAlignState? alignState,
    double? eulerY,
    int? faceCount,
    FaceCaptureStep? currentStep,
    double? progress,
    bool? isCaptureComplete,
    String? lastCapturedPhotoPath,
    String? lastCapturedStepKey,
    int? completedSteps,
    Map<String, String>? capturedPhotoByProfile,
  }) {
    return FaceCaptureState(
      status: status ?? this.status,
      cameraController: cameraController ?? this.cameraController,
      errorMessage: errorMessage ?? this.errorMessage,
      alignState: alignState ?? this.alignState,
      eulerY: eulerY ?? this.eulerY,
      faceCount: faceCount ?? this.faceCount,
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
      isCaptureComplete: isCaptureComplete ?? this.isCaptureComplete,
      lastCapturedPhotoPath: lastCapturedPhotoPath ?? this.lastCapturedPhotoPath,
      lastCapturedStepKey: lastCapturedStepKey ?? this.lastCapturedStepKey,
      completedSteps: completedSteps ?? this.completedSteps,
      capturedPhotoByProfile:
          capturedPhotoByProfile ?? this.capturedPhotoByProfile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    alignState,
    eulerY,
    faceCount,
    currentStep,
    progress,
    isCaptureComplete,
    lastCapturedPhotoPath,
    lastCapturedStepKey,
    completedSteps,
    capturedPhotoByProfile,
    // ⚠️ cameraController intentionally excluded
  ];
}

class FaceCaptureController extends Notifier<FaceCaptureState> {
  late final MediaPermissionHandler _permissionHandler;
  late final AppLogger _logger;
  late final FaceDetectorService _faceDetectorService;
  CameraController? _controller;
  CameraDescription? _activeCamera;
  bool _isInitializing = false;
  bool _streamActive = false;
  bool _isCapturingPhoto = false;
  DateTime _lastAngleLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastNoFaceLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _angleLogThrottle = Duration(milliseconds: 350);
  static const _noFaceLogThrottle = Duration(seconds: 2);
  static const _holdDuration = Duration(milliseconds: 1500);
  List<FaceCaptureStep> _captureSteps = const <FaceCaptureStep>[
    FaceCaptureStep.left,
    FaceCaptureStep.front,
    FaceCaptureStep.right,
  ];
  // ── Angle thresholds (from test flow) ───────────────────────────
  static const double _leftAlignedMin = -45.0;
  static const double _leftAlignedMax = -25.0;
  static const double _frontAlignedMin = -12.0;
  static const double _frontAlignedMax = 12.0;
  static const double _rightAlignedMin = 25.0;
  static const double _rightAlignedMax = 45.0;
  DateTime? _alignedSince;

  @override
  FaceCaptureState build() {
    _permissionHandler = ref.read(mediaPermissionHandlerProvider);
    _logger = ref.read(appLoggerProvider);
    _faceDetectorService = ref.watch(faceDetectorServiceProvider);
    ref.onDispose(() {
      _controller?.dispose();
      _controller = null;
    });
    return const FaceCaptureState();
  }

  Future<void> initialize({FaceCaptureConfig config = const FaceCaptureConfig.allProfiles()}) async {
    // Idempotency guard: prevents duplicate in-flight initializations.
    if (_isInitializing || state.status == CameraStatus.loading) {
      _logger.debug(
        '[FaceCaptureController] initialize skipped (already initializing). status=${state.status}',
      );
      return;
    }
    // If camera is already ready and controller is alive, do nothing.
    if (state.status == CameraStatus.ready && _controller != null) {
      _logger.debug(
        '[FaceCaptureController] initialize skipped (camera already ready).',
      );
      return;
    }

    _logger.info('[FaceCaptureController] initialize start');

    _isInitializing = true;
    _captureSteps = config.steps.isEmpty
        ? const <FaceCaptureStep>[
            FaceCaptureStep.left,
            FaceCaptureStep.front,
            FaceCaptureStep.right,
          ]
        : config.steps;
    final firstStep = _captureSteps.first;

    await _controller?.dispose();
    _controller = null;
    state = state.copyWith(
      status: CameraStatus.loading,
      cameraController: null,
      errorMessage: null,
      alignState: FaceAlignState.idle,
      eulerY: 0.0,
      faceCount: 0,
      currentStep: firstStep,
      progress: 0.0,
      isCaptureComplete: false,
      lastCapturedPhotoPath: null,
      lastCapturedStepKey: '',
      completedSteps: 0,
      capturedPhotoByProfile: const <String, String>{},
    );

    final permission = await _permissionHandler.ensureCameraAccess();
    _logger.info(
      '[FaceCaptureController] camera permission result=$permission',
    );
    if (permission != PermissionResult.granted) {
      state = state.copyWith(status: CameraStatus.permissionDenied);
      _logger.warning(
        '[FaceCaptureController] camera permission denied',
      );
      _isInitializing = false;
      return;
    }

    try {
      final cameras = await availableCameras();
      _logger.info(
        '[FaceCaptureController] available cameras count=${cameras.length}',
      );
      if (cameras.isEmpty) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'No camera available on this device.',
        );
        _logger.error('[FaceCaptureController] no camera available');
        _isInitializing = false;
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      _controller = controller;
      _activeCamera = frontCamera;
      await _startFaceStream(controller: controller, camera: frontCamera);
      _logger.info(
        '[FaceCaptureController] camera initialized lens=${frontCamera.lensDirection} [ANGLE_TRACE_BOOT_OK]',
      );

      state = state.copyWith(
        status: CameraStatus.ready,
        cameraController: controller,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
      _logger.error(
        '[FaceCaptureController] initialize failed',
        error: e,
      );
    } finally {
      _isInitializing = false;
      _logger.debug(
        '[FaceCaptureController] initialize end status=${state.status}',
      );
    }
  }

  Future<void> disposeCamera() async {
    _logger.info('[FaceCaptureController] disposeCamera called');
    _streamActive = false;
    _alignedSince = null;
    if (_controller?.value.isStreamingImages == true) {
      await _controller?.stopImageStream();
    }
    await _controller?.dispose();
    _controller = null;
    _activeCamera = null;
    state = state.copyWith(
      status: CameraStatus.idle,
      cameraController: null,
      errorMessage: null,
    );
  }

  Future<void> _startFaceStream({
    required CameraController controller,
    required CameraDescription camera,
  }) async {
    if (controller.value.isStreamingImages) return;
    _streamActive = true;
    _logger.info('[ANGLE_TRACE_UNIQUE] image-stream-start');
    await controller.startImageStream((image) async {
      if (!_streamActive || _controller != controller) return;
      final faces = await _faceDetectorService.detectFaces(
        cameraImage: image,
        camera: camera,
      );
      if (!_streamActive || _controller != controller) return;

      // Crucial fix: skipped frame (null) must not reset hold/progress state.
      if (faces == null) return;
      if (faces.isEmpty) {
        _alignedSince = null;
        state = state.copyWith(
          alignState: FaceAlignState.idle,
          faceCount: 0,
          eulerY: 0.0,
          progress: 0.0,
        );
        final now = DateTime.now();
        if (now.difference(_lastNoFaceLogAt) >= _noFaceLogThrottle) {
          _lastNoFaceLogAt = now;
          _logger.debug('[ANGLE_TRACE_UNIQUE] no-face');
        }
        return;
      }

      if (faces.length > 1) {
        _alignedSince = null;
        state = state.copyWith(
          alignState: FaceAlignState.wrong,
          faceCount: faces.length,
          progress: 0.0,
        );
        _logger.warning(
          '[ANGLE_TRACE_UNIQUE] multiple-faces faces=${faces.length}',
        );
        return;
      }

      final now = DateTime.now();
      final face = faces.first;
      final correctedEulerY = (face.headEulerAngleY ?? 0.0) * -1;
      final eulerX = face.headEulerAngleX ?? 0.0;
      final aligned = _isAlignedForCurrentStep(correctedEulerY);

      var progress = 0.0;
      if (aligned) {
        _alignedSince ??= now;
        final elapsed = now.difference(_alignedSince!);
        progress = (elapsed.inMilliseconds / _holdDuration.inMilliseconds)
            .clamp(0.0, 1.0);
        if (progress >= 1.0) {
          await _capturePhoto(
            controller: controller,
            camera: camera,
            capturedStep: state.currentStep,
          );
          progress = 0.0;
          _alignedSince = null;
        }
      } else {
        _alignedSince = null;
      }

      state = state.copyWith(
        alignState: aligned ? FaceAlignState.aligned : FaceAlignState.wrong,
        faceCount: 1,
        eulerY: correctedEulerY,
        progress: progress,
      );
      if (now.difference(_lastAngleLogAt) >= _angleLogThrottle) {
        _lastAngleLogAt = now;
        _logger.info(
          '[ANGLE_TRACE_UNIQUE] y=${correctedEulerY.toStringAsFixed(1)} x=${eulerX.toStringAsFixed(1)} faces=${faces.length} progress=${(progress * 100).toStringAsFixed(0)}%',
        );
      }
    });
  }

  bool _isAlignedForCurrentStep(double eulerY) {
    if (state.isCaptureComplete) return true;
    return switch (state.currentStep) {
      FaceCaptureStep.left =>
        eulerY >= _leftAlignedMin && eulerY <= _leftAlignedMax,
      FaceCaptureStep.front =>
        eulerY >= _frontAlignedMin && eulerY <= _frontAlignedMax,
      FaceCaptureStep.right =>
        eulerY >= _rightAlignedMin && eulerY <= _rightAlignedMax,
    };
  }

  Future<void> _capturePhoto({
    required CameraController controller,
    required CameraDescription camera,
    required FaceCaptureStep capturedStep,
  }) async {
    if (_isCapturingPhoto) return;
    _isCapturingPhoto = true;
    try {
      _streamActive = false;
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final file = await controller.takePicture();
      final advanced = _advanceStep(capturedStep);
      final profileKey = _profileKeyForStep(capturedStep);
      final updatedProfileMap = <String, String>{
        ...state.capturedPhotoByProfile,
        profileKey: file.path,
      };
      _logger.info('[ANGLE_TRACE_UNIQUE] photo-captured path=${file.path}');
      state = state.copyWith(
        lastCapturedPhotoPath: file.path,
        lastCapturedStepKey: capturedStep.name,
        completedSteps: updatedProfileMap.length,
        currentStep: advanced.$1,
        isCaptureComplete: advanced.$2,
        progress: 0.0,
        capturedPhotoByProfile: updatedProfileMap,
      );
    } catch (e, st) {
      _logger.error(
        '[ANGLE_TRACE_UNIQUE] photo-capture-failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isCapturingPhoto = false;
      if (_controller == controller) {
        _streamActive = true;
        await _startFaceStream(controller: controller, camera: camera);
      }
    }
  }

  Future<void> captureCurrentStepManually() async {
    if (state.status != CameraStatus.ready || state.isCaptureComplete) {
      return;
    }
    final controller = _controller;
    final camera = _activeCamera;
    if (controller == null || camera == null) {
      _logger.warning(
        '[FaceCaptureController] manual-capture skipped (camera not ready)',
      );
      return;
    }
    _logger.info(
      '[FaceCaptureController] manual-capture step=${state.currentStep.name}',
    );
    await _capturePhoto(
      controller: controller,
      camera: camera,
      capturedStep: state.currentStep,
    );
  }

  (FaceCaptureStep, bool) _advanceStep(FaceCaptureStep currentStep) {
    final currentIndex = _captureSteps.indexOf(currentStep);
    if (currentIndex < 0) {
      return (_captureSteps.first, false);
    }
    final nextIndex = currentIndex + 1;
    if (nextIndex >= _captureSteps.length) {
      return (currentStep, true);
    }
    return (_captureSteps[nextIndex], false);
  }

  String _profileKeyForStep(FaceCaptureStep step) {
    return switch (step) {
      FaceCaptureStep.left => 'left_profile',
      FaceCaptureStep.front => 'front_profile',
      FaceCaptureStep.right => 'right_profile',
    };
  }
}
