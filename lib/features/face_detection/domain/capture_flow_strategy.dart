import 'package:basic_project_setup/features/face_detection/presentation/controller/face_capture_controller.dart';

class CaptureFlowEvaluation {
  final double progress;
  final bool shouldCapture;

  const CaptureFlowEvaluation({
    required this.progress,
    required this.shouldCapture,
  });
}

abstract class CaptureFlowStrategy {
  void reset();

  CaptureFlowEvaluation evaluate({
    required bool isAligned,
    required DateTime now,
  });

  (FaceCaptureStep, bool) onCaptureSuccess({
    required FaceCaptureStep currentStep,
    required List<FaceCaptureStep> steps,
  });
}

