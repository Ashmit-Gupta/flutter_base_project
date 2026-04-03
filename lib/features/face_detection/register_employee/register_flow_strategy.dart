import '../domain/capture_flow_strategy.dart';
import '../presentation/controller/face_capture_controller.dart';

class RegisterFlowStrategy implements CaptureFlowStrategy {
  RegisterFlowStrategy({this.holdDuration = const Duration(milliseconds: 1500)});

  final Duration holdDuration;
  DateTime? _alignedSince;

  @override
  void reset() {
    _alignedSince = null;
  }

  @override
  CaptureFlowEvaluation evaluate({
    required bool isAligned,
    required DateTime now,
  }) {
    if (!isAligned) {
      _alignedSince = null;
      return const CaptureFlowEvaluation(progress: 0.0, shouldCapture: false);
    }

    _alignedSince ??= now;
    final elapsed = now.difference(_alignedSince!);
    final progress = (elapsed.inMilliseconds / holdDuration.inMilliseconds).clamp(0.0, 1.0);
    if (progress >= 1.0) {
      _alignedSince = null;
      return const CaptureFlowEvaluation(progress: 0.0, shouldCapture: true);
    }
    return CaptureFlowEvaluation(progress: progress, shouldCapture: false);
  }

  @override
  (FaceCaptureStep, bool) onCaptureSuccess({
    required FaceCaptureStep currentStep,
    required List<FaceCaptureStep> steps,
  }) {
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex < 0) {
      return (steps.first, false);
    }
    final nextIndex = currentIndex + 1;
    if (nextIndex >= steps.length) {
      return (currentStep, true);
    }
    return (steps[nextIndex], false);
  }
}

