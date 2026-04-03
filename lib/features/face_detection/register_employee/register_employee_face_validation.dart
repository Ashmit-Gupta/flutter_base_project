import 'package:basic_project_setup/features/face_detection/presentation/controller/face_capture_controller.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/face_detection_validation_strategy.dart';

class RegisterEmployeeFaceValidation implements FaceValidationStrategy {
  // same thresholds you already have
  static const double _leftMin = -45.0;
  static const double _leftMax = -25.0;
  static const double _frontMin = -12.0;
  static const double _frontMax = 12.0;
  static const double _rightMin = 25.0;
  static const double _rightMax = 45.0;

  @override
  FaceValidationResult validate({
    required Face face,
    required FaceCaptureStep step,
    required double imageWidth,
  }) {
    final correctedEulerY = (face.headEulerAngleY ?? 0.0) * -1;
    final eulerX = face.headEulerAngleX ?? 0.0;
    final eulerZ = face.headEulerAngleZ ?? 0.0;

    // 1. obstruction check
    final obstruction = _obstructionFeedback(face, step);
    if (obstruction.isNotEmpty) {
      return FaceValidationResult(
        isAligned: false,
        feedback: obstruction,
        correctedEulerY: correctedEulerY,
      );
    }

    // 2. positioning feedback
    final feedback = _computeFeedback(
      face: face,
      imageWidth: imageWidth,
      eulerX: eulerX,
      eulerZ: eulerZ,
      correctedEulerY: correctedEulerY,
      step: step,
    );

    // 3. alignment
    final aligned = feedback.isEmpty && _isAligned(step, correctedEulerY);

    return FaceValidationResult(
      isAligned: aligned,
      feedback: feedback,
      correctedEulerY: correctedEulerY,
    );
  }

  // ─────────────────────────────────────────────
  // 👇 moved from controller
  // ─────────────────────────────────────────────

  bool _isAligned(FaceCaptureStep step, double y) {
    return switch (step) {
      FaceCaptureStep.left => y >= _leftMin && y <= _leftMax,
      FaceCaptureStep.front => y >= _frontMin && y <= _frontMax,
      FaceCaptureStep.right => y >= _rightMin && y <= _rightMax,
    };
  }

  String _computeFeedback({
    required Face face,
    required double imageWidth,
    required double eulerX,
    required double eulerZ,
    required double correctedEulerY,
    required FaceCaptureStep step,
  }) {
    final bbox = face.boundingBox;
    final faceRatio = bbox.width / imageWidth;

    if (faceRatio > 0.68) {
      return "You're too close — move back";
    }
    if (faceRatio < 0.22) {
      return "Move closer";
    }

    if (eulerZ.abs() > 12.0) {
      return eulerZ > 0
          ? 'Tilt head left'
          : 'Tilt head right';
    }

    if (eulerX < -15.0) return 'Lower chin';
    if (eulerX > 15.0) return 'Raise chin';

    if (!_isAligned(step, correctedEulerY)) {
      return switch (step) {
        FaceCaptureStep.left => 'Turn left',
        FaceCaptureStep.front => 'Look straight',
        FaceCaptureStep.right => 'Turn right',
      };
    }

    return '';
  }

  String _obstructionFeedback(Face face, FaceCaptureStep step) {
    final nose = face.landmarks[FaceLandmarkType.noseBase];

    if (nose == null) {
      return 'Keep your face visible';
    }

    return '';
  }
}