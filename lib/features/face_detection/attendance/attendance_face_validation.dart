import 'package:basic_project_setup/features/face_detection/presentation/controller/face_capture_controller.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../domain/face_detection_validation_strategy.dart';

/// Attendance validation: front-facing only, simpler guidance.
class AttendanceFaceValidation implements FaceValidationStrategy {
  static const double _frontMin = -12.0;
  static const double _frontMax = 12.0;

  @override
  FaceValidationResult validate({
    required Face face,
    required FaceCaptureStep step,
    required double imageWidth,
  }) {
    final correctedEulerY = (face.headEulerAngleY ?? 0.0) * -1;
    final eulerX = face.headEulerAngleX ?? 0.0;
    final eulerZ = face.headEulerAngleZ ?? 0.0;

    final obstruction = _obstructionFeedback(face);
    if (obstruction.isNotEmpty) {
      return FaceValidationResult(
        isAligned: false,
        feedback: obstruction,
        correctedEulerY: correctedEulerY,
      );
    }

    final feedback = _computeFeedback(
      face: face,
      imageWidth: imageWidth,
      eulerX: eulerX,
      eulerZ: eulerZ,
      correctedEulerY: correctedEulerY,
    );

    final aligned = feedback.isEmpty && _isFrontAligned(correctedEulerY);

    return FaceValidationResult(
      isAligned: aligned,
      feedback: feedback,
      correctedEulerY: correctedEulerY,
    );
  }

  bool _isFrontAligned(double y) => y >= _frontMin && y <= _frontMax;

  String _computeFeedback({
    required Face face,
    required double imageWidth,
    required double eulerX,
    required double eulerZ,
    required double correctedEulerY,
  }) {
    final bbox = face.boundingBox;
    final faceRatio = bbox.width / imageWidth;

    if (faceRatio > 0.68) return "You're too close — move back a little";
    if (faceRatio < 0.22) return 'Move closer to the camera';

    if (eulerZ.abs() > 12.0) {
      return eulerZ > 0 ? 'Tilt your head to the left' : 'Tilt your head to the right';
    }
    if (eulerX < -15.0) return 'Lower your chin slightly';
    if (eulerX > 15.0) return 'Raise your chin slightly';

    if (!_isFrontAligned(correctedEulerY)) return 'Look straight at the camera';
    return '';
  }

  String _obstructionFeedback(Face face) {
    // Keep this light for attendance; just ensure key landmark is present.
    final nose = face.landmarks[FaceLandmarkType.noseBase];
    if (nose == null) {
      return 'Keep your face visible — do not cover it with hands or objects';
    }
    return '';
  }
}

