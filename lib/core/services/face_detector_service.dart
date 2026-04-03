
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../logging/app_logger.dart';

class FaceDetectorService {
  FaceDetectorService({AppLogger? logger}) : _logger = logger;

  final AppLogger? _logger;

  // Landmarks + classification + contours: needed to reject covered/occluded
  // faces (hands/objects). Accurate mode improves euler angles and landmark
  // stability for guided capture.
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.12,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  bool _isProcessing = false; // guard: skip frame if previous not done yet
  bool _isClosed = false;
  DateTime _lastNoFaceLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastFrameMetaLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastSkipLogAt = DateTime.fromMillisecondsSinceEpoch(0);
  static const _noFaceLogThrottle = Duration(seconds: 2);
  static const _frameMetaLogThrottle = Duration(seconds: 3);
  static const _skipLogThrottle = Duration(seconds: 2);

  /// Converts a raw [CameraImage] frame to [InputImage] and runs detection.
  /// Returns:
  /// - `null` when frame is skipped (busy/closed)
  /// - `[]` when processed but no face found
  /// - `[Face, ...]` when faces are detected
  Future<List<Face>?> detectFaces({
    required CameraImage cameraImage,
    required CameraDescription camera,
  }) async {
    if (_isClosed) {
      return null;
    }
    if (_isProcessing) {
      final now = DateTime.now();
      if (now.difference(_lastSkipLogAt) >= _skipLogThrottle) {
        _lastSkipLogAt = now;
        _logger?.debug('[FACE_DETECTOR_DBG] skip frame: previous still processing');
      }
      return null;
    }
    _isProcessing = true;

    try {
      final now = DateTime.now();
      if (now.difference(_lastFrameMetaLogAt) >= _frameMetaLogThrottle) {
        _lastFrameMetaLogAt = now;
        _logger?.debug(
          '[FACE_DETECTOR_DBG] frame meta w=${cameraImage.width} h=${cameraImage.height} '
          'planes=${cameraImage.planes.length} sensor=${camera.sensorOrientation} lens=${camera.lensDirection} '
          'rawFormat=${cameraImage.format.raw}',
        );
      }

      final inputImage = _buildInputImage(
        cameraImage: cameraImage,
        camera: camera,
      );

      if (inputImage == null) {
        _logger?.warning('[FACE_DETECTOR_DBG] InputImage build returned null');
        return const <Face>[];
      }

      final faces = await _detector.processImage(inputImage);
      if (faces.isEmpty) {
        final nowNoFace = DateTime.now();
        if (nowNoFace.difference(_lastNoFaceLogAt) >= _noFaceLogThrottle) {
          _lastNoFaceLogAt = nowNoFace;
          _logger?.debug('[FACE_DETECTOR_DBG] MLKit processed frame, no face found');
        }
        return const <Face>[];
      }

      final first = faces.first;
      _logger?.info(
        '[FACE_DETECTOR_DBG] faces=${faces.length} '
        'y=${(first.headEulerAngleY ?? 0.0).toStringAsFixed(1)} '
        'x=${(first.headEulerAngleX ?? 0.0).toStringAsFixed(1)}',
      );
      return faces;
    } catch (e, st) {
      _logger?.error(
        '[FACE_DETECTOR_DBG] detectFaces failed',
        error: e,
        stackTrace: st,
      );
      return const <Face>[];
    } finally {
      _isProcessing = false;
    }
  }

  /// Builds the [InputImage] MLKit needs from a raw camera frame.
  InputImage? _buildInputImage({
    required CameraImage cameraImage,
    required CameraDescription camera,
  }) {
    // ── 1. Pick the right rotation ────────────────────────────────
    // MLKit needs to know how the image is rotated relative to the screen.
    final rotation = _rotationFromCamera(camera.sensorOrientation);
    if (rotation == null) {
      _logger?.warning(
        '[FACE_DETECTOR_DBG] Unsupported sensor rotation=${camera.sensorOrientation}',
      );
      return null;
    }

    // ── 2. Pick the right format ──────────────────────────────────
    // We set yuv420 in the controller — map it to what MLKit expects.
    final format = InputImageFormatValue.fromRawValue(cameraImage.format.raw);
    if (format == null) {
      _logger?.warning(
        '[FACE_DETECTOR_DBG] Unsupported raw image format=${cameraImage.format.raw}',
      );
      return null;
    }
    if (Platform.isAndroid && format != InputImageFormat.nv21) {
      _logger?.warning(
        '[FACE_DETECTOR_DBG] Android format must be NV21. got=$format raw=${cameraImage.format.raw}',
      );
      return null;
    }
    if (Platform.isIOS && format != InputImageFormat.bgra8888) {
      _logger?.warning(
        '[FACE_DETECTOR_DBG] iOS format must be BGRA8888. got=$format raw=${cameraImage.format.raw}',
      );
      return null;
    }

    // ── 3. Build metadata ─────────────────────────────────────────
    if (cameraImage.planes.isEmpty) {
      _logger?.warning('[FACE_DETECTOR_DBG] Camera image has zero planes');
      return null;
    }
    final plane = cameraImage.planes.first;

    final metadata = InputImageMetadata(
      size: Size(
        cameraImage.width.toDouble(),
        cameraImage.height.toDouble(),
      ),
      rotation: rotation,        // for Android
      format: format,            // for iOS
      bytesPerRow: plane.bytesPerRow,
    );

    // For NV21/BGRA8888, MLKit expects bytes from the first plane.
    final bytes = cameraImage.planes.first.bytes;

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  /// Maps sensor orientation degrees → MLKit's [InputImageRotation].
  InputImageRotation? _rotationFromCamera(int sensorOrientation) {
    switch (sensorOrientation) {
      case 0:   return InputImageRotation.rotation0deg;
      case 90:  return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default:  return null;
    }
  }

  /// Must be called when you're done — releases native MLKit resources.
  Future<void> close() async {
    if (_isClosed) return;
    _isClosed = true;
    _logger?.info('[FACE_DETECTOR_DBG] closing MLKit face detector');
    await _detector.close();
  }
}