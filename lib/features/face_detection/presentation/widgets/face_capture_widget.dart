import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/feedback/app_snackbar.dart';
import '../../widgets/face_overlay_painter.dart';
import '../../widgets/face_overlay_widget.dart';
import '../controller/face_capture_controller.dart';
import '../model/face_capture_config.dart';
import '../provider/face_capture_provider.dart';

class FaceCaptureWidget extends HookConsumerWidget {
  const FaceCaptureWidget({
    super.key,
    required this.config,
    required this.onCaptureComplete,
    this.onMetrics,
    this.onFeedbackMessage,
    this.showBackButton = false,
    this.onBack,
    this.showManualCaptureButton = true,
    this.backgroundColor = Colors.black,
    this.showFeedbackSnackbars = true,
    this.showCaptureSuccessSnackbars = true,
  });

  final FaceCaptureConfig config;

  /// Called when the capture sequence completes.
  /// The map contains profile-key -> captured photo path.
  final void Function(Map<String, String> capturedPhotoByProfile) onCaptureComplete;

  /// Optional real-time metrics callback (throttled).
  final void Function(FaceCaptureState state)? onMetrics;

  /// Optional feedback-message callback. When provided, snackbars are suppressed.
  final void Function(String message)? onFeedbackMessage;

  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showManualCaptureButton;
  final Color backgroundColor;

  final bool showFeedbackSnackbars;
  final bool showCaptureSuccessSnackbars;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureState = ref.watch(faceCaptureControllerProvider(config));
    final controller = ref.read(faceCaptureControllerProvider(config).notifier);

    final lastFeedbackSnackAt = useRef<DateTime?>(null);
    final lastMetricsAt = useRef<DateTime?>(null);

    // ── Init camera on mount ──────────────────────────────────────
    useEffect(() {
      Future.microtask(() => controller.initialize(config: config));
      return null;
    }, [config]);

    // ── App lifecycle: pause/resume camera ────────────────────────
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.paused || current == AppLifecycleState.hidden || current == AppLifecycleState.detached) {
        controller.disposeCamera();
      } else if (current == AppLifecycleState.resumed) {
        controller.initialize(config: config);
      }
    });

    // ── Optional metrics callback (throttled) ─────────────────────
    if (onMetrics != null) {
      ref.listen<FaceCaptureState>(faceCaptureControllerProvider(config), (previous, next) {
        final now = DateTime.now();
        final last = lastMetricsAt.value;
        if (last != null && now.difference(last) < const Duration(milliseconds: 100)) return;
        lastMetricsAt.value = now;
        onMetrics!(next);
      });
    }

    // ── Feedback messages (multi-face / occlusion / pose) ─────────
    ref.listen<FaceCaptureState>(faceCaptureControllerProvider(config), (previous, next) {
      final msg = next.feedbackMessage;
      if (msg.isEmpty || msg == previous?.feedbackMessage) return;

      final now = DateTime.now();
      final last = lastFeedbackSnackAt.value;
      if (last != null && now.difference(last) < const Duration(seconds: 4)) {
        return;
      }
      lastFeedbackSnackAt.value = now;
      if (!context.mounted) return;

      if (onFeedbackMessage != null) {
        onFeedbackMessage!(msg);
        return;
      }

      if (!showFeedbackSnackbars) return;

      final severe = msg.contains('only one face') ||
          msg.contains('Only one face') ||
          msg.startsWith('Uncover') ||
          msg.startsWith('Do not cover') ||
          msg.startsWith('Keep your face visible') ||
          msg.startsWith('Something may be blocking');

      if (severe) {
        AppSnackbar.warning(context, msg);
      } else {
        AppSnackbar.info(context, msg);
      }
    });

    // ── Capture success: step-by-step + final completion ─────────
    ref.listen<FaceCaptureState>(faceCaptureControllerProvider(config), (previous, next) {
      final previousKey = previous?.lastCapturedStepKey ?? '';
      final nextKey = next.lastCapturedStepKey;
      if (nextKey.isEmpty || nextKey == previousKey) return;

      if (showCaptureSuccessSnackbars) {
        final message = switch (nextKey) {
          'left' => 'Left face captured successfully',
          'front' => 'Front face captured successfully',
          'right' => 'Right face captured successfully',
          _ => 'Photo captured successfully',
        };
        AppSnackbar.success(context, message);
      }

      final completedNow = next.isCaptureComplete && !(previous?.isCaptureComplete ?? false);
      if (completedNow) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (!context.mounted) return;
          onCaptureComplete(next.capturedPhotoByProfile);
        });
      }
    });

    return ColoredBox(
      color: backgroundColor,
      child: _buildBody(context, captureState, controller, config),
    );
  }

  Widget _buildBody(
    BuildContext context,
    FaceCaptureState state,
    FaceCaptureController controller,
    FaceCaptureConfig config,
  ) {
    switch (state.status) {
      case CameraStatus.idle:
      case CameraStatus.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.white));

      case CameraStatus.permissionDenied:
        return _PermissionDeniedView(onRetry: () => controller.initialize(config: config));

      case CameraStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Camera error:\n${state.errorMessage}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        );

      case CameraStatus.ready:
        final totalSteps = config.steps.length;
        return _CameraReadyView(
          controller: state.cameraController!,
          alignState: state.alignState,
          progress: state.progress,
          stepLabel: _stepLabel(state),
          stepText: 'Step ${_currentStepNumber(state.completedSteps, totalSteps)} of $totalSteps',
          currentStep: state.currentStep,
          isCaptureComplete: state.isCaptureComplete,
          showBackButton: showBackButton,
          onBack: onBack,
          showManualCaptureButton: showManualCaptureButton,
          onManualCapture: controller.captureCurrentStepManually,
        );
    }
  }

  int _currentStepNumber(int completed, int total) {
    if (completed >= total) return total;
    return completed + 1;
  }

  String _stepLabel(FaceCaptureState state) {
    if (state.isCaptureComplete) return 'Completed';
    return switch (state.currentStep) {
      FaceCaptureStep.left => 'Turn Left',
      FaceCaptureStep.front => 'Look Straight',
      FaceCaptureStep.right => 'Turn Right',
    };
  }
}

class _CameraReadyView extends StatelessWidget {
  final CameraController controller;
  final FaceAlignState alignState;
  final double progress;
  final String stepLabel;
  final String stepText;
  final FaceCaptureStep currentStep;
  final bool isCaptureComplete;

  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showManualCaptureButton;
  final Future<void> Function() onManualCapture;

  const _CameraReadyView({
    required this.controller,
    required this.alignState,
    required this.progress,
    required this.stepLabel,
    required this.stepText,
    required this.currentStep,
    required this.isCaptureComplete,
    required this.showBackButton,
    required this.onBack,
    required this.showManualCaptureButton,
    required this.onManualCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!controller.value.isInitialized)
          const Center(child: CircularProgressIndicator(color: Colors.white))
        else
          CameraPreview(controller),
        FaceOverlayWidget(
          alignState: alignState,
          progress: progress,
          currentStep: currentStep,
        ),

        if (showBackButton)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              ),
            ),
          ),

        Positioned(
          bottom: 72,
          left: 0,
          right: 0,
          child: _StepHintText(label: stepLabel, stepText: stepText),
        ),

        if (showManualCaptureButton)
          Positioned(
            bottom: 22,
            left: 24,
            right: 24,
            child: FilledButton.icon(
              onPressed: isCaptureComplete ? null : () => onManualCapture(),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Capture Manually'),
            ),
          ),
      ],
    );
  }
}

class _StepHintText extends StatelessWidget {
  final String label;
  final String stepText;

  const _StepHintText({required this.label, required this.stepText});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(stepText, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 72),
            const SizedBox(height: 20),
            const Text(
              'Camera access is needed\nto capture your face photos.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

