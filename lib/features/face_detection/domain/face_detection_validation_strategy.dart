import 'package:basic_project_setup/features/face_detection/presentation/controller/face_capture_controller.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

abstract class FaceValidationStrategy {
  FaceValidationResult validate({
    required Face face,
    required FaceCaptureStep step,
    required double imageWidth,
  });
}

class FaceValidationResult {
  final bool isAligned;
  final String feedback;
  final double correctedEulerY;

  const FaceValidationResult({
    required this.isAligned,
    required this.feedback,
    required this.correctedEulerY,
  });
}

