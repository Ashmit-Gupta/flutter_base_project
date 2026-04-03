import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_project_setup/core/services/permission_service.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:basic_project_setup/core/services/face_detector_service.dart';
import 'dart:async';
import 'dart:io';
import '../../../../core/di/core_providers.dart';
import '../../domain/capture_flow_strategy.dart';
import '../provider/face_flow_provider.dart';
import '../provider/face_validation_provider.dart';
import '../../domain/face_detection_validation_strategy.dart';
import '../../widgets/face_overlay_painter.dart';
import '../model/face_capture_config.dart';

enum CameraStatus { idle, loading, ready, permissionDenied, error }

enum FaceCaptureStep { left, front, right }

class FaceCaptureState extends Equatable {
  final CameraStatus status;
  final CameraController? cameraController;
  final String? errorMessage;
  final FaceAlignState alignState;
  final double eulerY;
  final int faceCount;
  final FaceCaptureStep currentStep;
  final double progress;
  final bool isCaptureComplete;
  final String? lastCapturedPhotoPath;
  final String lastCapturedStepKey;
  final int completedSteps;
  final Map<String, String> capturedPhotoByProfile;

  // ── New: real-time guidance message ──────────────────────────
  // Empty string = no issue, all good
  final String feedbackMessage;

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
    this.feedbackMessage = '', // ← new
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
    String? feedbackMessage, // ← new
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
      capturedPhotoByProfile: capturedPhotoByProfile ?? this.capturedPhotoByProfile,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage, // ← new
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, alignState, eulerY, faceCount, currentStep, progress, isCaptureComplete, lastCapturedPhotoPath, lastCapturedStepKey, completedSteps, capturedPhotoByProfile, feedbackMessage];
}

class FaceCaptureController extends Notifier<FaceCaptureState> {
  FaceCaptureController(this._config);

  final FaceCaptureConfig _config;

  late final MediaPermissionHandler _permissionHandler;
  late final AppLogger _logger;
  late final FaceDetectorService _faceDetectorService;
  late FaceValidationStrategy _validationStrategy;
  late CaptureFlowStrategy _flowStrategy;
  CameraController? _controller;
  CameraDescription? _activeCamera;
  bool _isInitializing = false;
  bool _streamActive = false;
  bool _isCapturingPhoto = false;
  DateTime _lastAngleLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _angleLogThrottle = Duration(milliseconds: 350);
  List<FaceCaptureStep> _captureSteps = const <FaceCaptureStep>[FaceCaptureStep.left, FaceCaptureStep.front, FaceCaptureStep.right];

  @override
  FaceCaptureState build() {
    _permissionHandler = ref.read(mediaPermissionHandlerProvider);
    _logger = ref.read(appLoggerProvider);
    _faceDetectorService = ref.watch(faceDetectorServiceProvider);
    _validationStrategy = ref.read(faceValidationStrategyProvider(_config));
    _flowStrategy = ref.read(captureFlowStrategyProvider(_config));
    _flowStrategy.reset();
    ref.onDispose(() {
      _streamActive = false;
      _flowStrategy.reset();
      final controller = _controller;
      _controller = null;
      _activeCamera = null;
      if (controller != null) {
        unawaited(_disposeControllerSafely(controller));
      }
    });
    final firstStep = _config.steps.isEmpty ? FaceCaptureStep.left : _config.steps.first;
    return FaceCaptureState(currentStep: firstStep);
  }

  Future<void> initialize({FaceCaptureConfig config = const FaceCaptureConfig.allProfiles()}) async {
    // Idempotency guard: prevents duplicate in-flight initializations.
    if (_isInitializing || state.status == CameraStatus.loading) {
      _logger.debug('[FaceCaptureController] initialize skipped (already initializing). status=${state.status}');
      return;
    }
    // If camera is already ready and controller is alive, normally do nothing.
    // But if a capture flow already completed, we must re-arm the flow so
    // another employee (or same) can capture again without leaving the screen.
    if (state.status == CameraStatus.ready && _controller != null && !state.isCaptureComplete) {
      _logger.debug('[FaceCaptureController] initialize skipped (camera already ready).');
      return;
    }

    _logger.info('[FaceCaptureController] initialize start');

    _isInitializing = true;
    _validationStrategy = ref.read(
      faceValidationStrategyProvider(config),
    );
    _flowStrategy = ref.read(
      captureFlowStrategyProvider(config),
    );
    _flowStrategy.reset();
    _captureSteps = config.steps.isEmpty ? const <FaceCaptureStep>[FaceCaptureStep.left, FaceCaptureStep.front, FaceCaptureStep.right] : config.steps;
    final firstStep = _captureSteps.first;

    final previousController = _controller;
    if (previousController != null) {
      await _disposeControllerSafely(previousController);
    }
    _controller = null;
    state = state.copyWith(status: CameraStatus.loading, cameraController: null, errorMessage: null, alignState: FaceAlignState.idle, eulerY: 0.0, faceCount: 0, currentStep: firstStep, progress: 0.0, isCaptureComplete: false, lastCapturedPhotoPath: null, lastCapturedStepKey: '', completedSteps: 0, capturedPhotoByProfile: const <String, String>{});

    final permission = await _permissionHandler.ensureCameraAccess();
    _logger.info('[FaceCaptureController] camera permission result=$permission');
    if (permission != PermissionResult.granted) {
      state = state.copyWith(status: CameraStatus.permissionDenied);
      _logger.warning('[FaceCaptureController] camera permission denied');
      _isInitializing = false;
      return;
    }

    try {
      final cameras = await availableCameras();
      _logger.info('[FaceCaptureController] available cameras count=${cameras.length}');
      if (cameras.isEmpty) {
        state = state.copyWith(status: CameraStatus.error, errorMessage: 'No camera available on this device.');
        _logger.error('[FaceCaptureController] no camera available');
        _isInitializing = false;
        return;
      }

      final frontCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front, orElse: () => cameras.first);

      final controller = CameraController(frontCamera, ResolutionPreset.high, enableAudio: false, imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888);
      await controller.initialize();
      _controller = controller;
      _activeCamera = frontCamera;
      await _startFaceStream(controller: controller, camera: frontCamera);
      _logger.info('[FaceCaptureController] camera initialized lens=${frontCamera.lensDirection} [ANGLE_TRACE_BOOT_OK]');

      state = state.copyWith(status: CameraStatus.ready, cameraController: controller, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: CameraStatus.error, errorMessage: e.toString());
      _logger.error('[FaceCaptureController] initialize failed', error: e);
    } finally {
      _isInitializing = false;
      _logger.debug('[FaceCaptureController] initialize end status=${state.status}');
    }
  }

  Future<void> disposeCamera() async {
    _logger.info('[FaceCaptureController] disposeCamera called');
    _streamActive = false;
    _flowStrategy.reset();
    // Clear controller from state first so UI stops building CameraPreview
    // before we dispose the native controller.
    if (state.status != CameraStatus.idle || state.cameraController != null) {
      state = state.copyWith(
        status: CameraStatus.idle,
        cameraController: null,
        errorMessage: null,
        progress: 0.0,
        feedbackMessage: '',
      );
    }
    final controller = _controller;
    if (controller != null) {
      await _disposeControllerSafely(controller);
    }
    _controller = null;
    _activeCamera = null;
  }

  Future<void> _disposeControllerSafely(CameraController controller) async {
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Ignore plugin teardown races.
    }
    try {
      await controller.dispose();
    } catch (_) {
      // Ignore late/double dispose races.
    }
  }

  Future<void> _startFaceStream({required CameraController controller, required CameraDescription camera}) async {
    if (controller.value.isStreamingImages) return;
    _streamActive = true;
    _logger.info('[ANGLE_TRACE_UNIQUE] image-stream-start');

    await controller.startImageStream((image) async {
      if (!_streamActive || _controller != controller) return;

      final faces = await _faceDetectorService.detectFaces(cameraImage: image, camera: camera);

      if (!_streamActive || _controller != controller) return;

      // null = skipped frame — preserve everything, do nothing
      if (faces == null) return;

      // ── No face ────────────────────────────────────────────────
      if (faces.isEmpty) {
        _flowStrategy.reset();
        state = state.copyWith(alignState: FaceAlignState.idle, faceCount: 0, eulerY: 0.0, progress: 0.0, feedbackMessage: 'Position only your face in the frame');
        return;
      }

      // ── Multiple faces ─────────────────────────────────────────
      if (faces.length > 1) {
        _flowStrategy.reset();
        state = state.copyWith(alignState: FaceAlignState.wrong, faceCount: faces.length, progress: 0.0, feedbackMessage: 'Only one face should be in frame');
        return;
      }

      // ── Single face: full analysis ─────────────────────────────
      final now = DateTime.now();
      final face = faces.first;
      final result = _validationStrategy.validate(
        face: face,
        step: state.currentStep,
        // image.height is used because the front camera image is landscape
        // (1280×720), but displayed rotated 90°.
        imageWidth: image.height.toDouble(),
      );

      // Prevent re-capturing once the full capture flow is completed.
      // This is important when the UI stays on-screen after completion.
      if (state.isCaptureComplete) {
        state = state.copyWith(
          alignState: FaceAlignState.aligned,
          faceCount: 1,
          eulerY: result.correctedEulerY,
          progress: 0.0,
          feedbackMessage: '',
        );
        return;
      }
      final feedback = result.feedback;
      final aligned = feedback.isEmpty && result.isAligned;

      final flowEval = _flowStrategy.evaluate(isAligned: aligned, now: now);
      var progress = flowEval.progress;
      if (flowEval.shouldCapture) {
        await _capturePhoto(
          controller: controller,
          camera: camera,
          capturedStep: state.currentStep,
        );
        progress = 0.0;
      }

      state = state.copyWith(
        alignState: aligned ? FaceAlignState.aligned : FaceAlignState.wrong,
        faceCount: 1,
        eulerY: result.correctedEulerY,
        progress: progress,
        feedbackMessage: feedback,
      );

      if (now.difference(_lastAngleLogAt) >= _angleLogThrottle) {
        _lastAngleLogAt = now;
        _logger.info(
          '[ANGLE_TRACE_UNIQUE] y=${result.correctedEulerY.toStringAsFixed(1)} '
          'faces=1 progress=${(progress * 100).toStringAsFixed(0)}% '
          'feedback="$feedback"',
        );
      }
    });
  }

  Future<void> _capturePhoto({required CameraController controller, required CameraDescription camera, required FaceCaptureStep capturedStep}) async {
    if (_isCapturingPhoto) return;
    _isCapturingPhoto = true;
    try {
      _streamActive = false;
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final file = await controller.takePicture();
      final advanced = _flowStrategy.onCaptureSuccess(
        currentStep: capturedStep,
        steps: _captureSteps,
      );
      final profileKey = _profileKeyForStep(capturedStep);
      final updatedProfileMap = <String, String>{...state.capturedPhotoByProfile, profileKey: file.path};
      _logger.info('[ANGLE_TRACE_UNIQUE] photo-captured path=${file.path}');
      state = state.copyWith(lastCapturedPhotoPath: file.path, lastCapturedStepKey: capturedStep.name, completedSteps: updatedProfileMap.length, currentStep: advanced.$1, isCaptureComplete: advanced.$2, progress: 0.0, capturedPhotoByProfile: updatedProfileMap);
    } catch (e, st) {
      _logger.error('[ANGLE_TRACE_UNIQUE] photo-capture-failed', error: e, stackTrace: st);
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
      _logger.warning('[FaceCaptureController] manual-capture skipped (camera not ready)');
      return;
    }
    _logger.info('[FaceCaptureController] manual-capture step=${state.currentStep.name}');
    await _capturePhoto(controller: controller, camera: camera, capturedStep: state.currentStep);
  }

  /// Re-arms capture flow without restarting camera preview/stream.
  /// Useful for attendance loops where repeated captures are needed
  /// and full re-initialize causes visible flicker.
  void rearmCaptureFlow() {
    if (state.status != CameraStatus.ready || _controller == null) return;
    _flowStrategy.reset();
    final firstStep = _captureSteps.isEmpty ? FaceCaptureStep.front : _captureSteps.first;
    state = state.copyWith(
      alignState: FaceAlignState.idle,
      progress: 0.0,
      isCaptureComplete: false,
      lastCapturedPhotoPath: null,
      lastCapturedStepKey: '',
      completedSteps: 0,
      capturedPhotoByProfile: const <String, String>{},
      currentStep: firstStep,
      feedbackMessage: '',
    );
  }

  String _profileKeyForStep(FaceCaptureStep step) {
    return switch (step) {
      FaceCaptureStep.left => 'left_profile',
      FaceCaptureStep.front => 'front_profile',
      FaceCaptureStep.right => 'right_profile',
    };
  }
}
