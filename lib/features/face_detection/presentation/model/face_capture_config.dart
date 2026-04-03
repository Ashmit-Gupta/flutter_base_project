import '../controller/face_capture_controller.dart';

class FaceCaptureConfig {
  final List<FaceCaptureStep> steps;
  const FaceCaptureConfig._(this.steps);

  const FaceCaptureConfig.allProfiles()
      : steps = const <FaceCaptureStep>[
          FaceCaptureStep.left,
          FaceCaptureStep.front,
          FaceCaptureStep.right,
        ];

  factory FaceCaptureConfig.single(FaceCaptureStep profile) {
    return FaceCaptureConfig._(<FaceCaptureStep>[profile]);
  }

  static const FaceCaptureConfig attendanceFront =
      FaceCaptureConfig._(<FaceCaptureStep>[FaceCaptureStep.front]);
}
