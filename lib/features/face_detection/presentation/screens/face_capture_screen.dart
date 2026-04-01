import 'package:basic_project_setup/core/widgets/app_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/feedback/app_snackbar.dart';
import '../model/face_capture_config.dart';
import '../../widgets/face_overlay_painter.dart';
import '../../widgets/face_overlay_widget.dart';
import '../controller/face_capture_controller.dart';
import '../provider/face_capture_provider.dart';

class FaceCaptureScreen extends HookConsumerWidget {
  const FaceCaptureScreen({super.key, this.config = const FaceCaptureConfig.allProfiles()});

  final FaceCaptureConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureState = ref.watch(faceCaptureControllerProvider);
    final controller = ref.read(faceCaptureControllerProvider.notifier);
    final lastMultiFaceSnackAt = useRef<DateTime?>(null);

    // ── Init camera on mount ──────────────────────────────────────
    useEffect(() {
      Future.microtask(() => controller.initialize(config: config));
      return null; // autoDispose handles cleanup
    }, const []);

    // ── App lifecycle: pause/resume camera ────────────────────────
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.paused || current == AppLifecycleState.hidden || current == AppLifecycleState.detached) {
        controller.disposeCamera();
      } else if (current == AppLifecycleState.resumed) {
        controller.initialize(config: config);
      }
    });

    ref.listen<FaceCaptureState>(faceCaptureControllerProvider, (previous, next) {
      if (next.faceCount <= 1) return;

      final now = DateTime.now();
      final lastShownAt = lastMultiFaceSnackAt.value;
      final isInCooldown = lastShownAt != null && now.difference(lastShownAt) < const Duration(seconds: 3);
      if (isInCooldown) return;

      lastMultiFaceSnackAt.value = now;
      AppSnackbar.warning(context, 'Multiple faces detected. Keep only one face.');
    });

    ref.listen<FaceCaptureState>(faceCaptureControllerProvider, (previous, next) {
      final previousKey = previous?.lastCapturedStepKey ?? '';
      final nextKey = next.lastCapturedStepKey;
      if (nextKey.isEmpty || nextKey == previousKey) return;

      final message = switch (nextKey) {
        'left' => 'Left face captured successfully',
        'front' => 'Front face captured successfully',
        'right' => 'Right face captured successfully',
        _ => 'Photo captured successfully',
      };
      AppSnackbar.success(context, message);

      final completedNow = next.isCaptureComplete && !(previous?.isCaptureComplete ?? false);
      if (completedNow && context.mounted) {
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (context.mounted) {
            Navigator.of(context).pop(next.capturedPhotoByProfile);
          }
        });
      }
    });

    return Scaffold(backgroundColor: Colors.black, body: _buildBody(context, captureState, controller));
  }

  Widget _buildBody(BuildContext context, FaceCaptureState state, FaceCaptureController controller) {
    switch (state.status) {
      case CameraStatus.idle:
      case CameraStatus.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.white));

      case CameraStatus.permissionDenied:
        return _PermissionDeniedView(onRetry: controller.initialize);

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
        return _CameraReadyView(controller: state.cameraController!, alignState: state.alignState, progress: state.progress, stepLabel: _stepLabel(state), stepText: 'Step ${_currentStepNumber(state.completedSteps, config.steps.length)} of ${config.steps.length}', isCaptureComplete: state.isCaptureComplete, onManualCapture: controller.captureCurrentStepManually);
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

// ── Sub-widgets (kept small and focused) ─────────────────────────

class _CameraReadyView extends StatelessWidget {
  final CameraController controller;
  final FaceAlignState alignState;
  final double progress;
  final String stepLabel;
  final String stepText;
  final bool isCaptureComplete;
  final Future<void> Function() onManualCapture;

  const _CameraReadyView({required this.controller, required this.alignState, required this.progress, required this.stepLabel, required this.stepText, required this.isCaptureComplete, required this.onManualCapture});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Live feed ─────────────────────────────────
        CameraPreview(controller),

        // ── Overlay slot (Step 3 — CustomPainter) ─────
        // FaceOverlayPainter will be inserted here
        FaceOverlayWidget(alignState: alignState, progress: progress),

        // ── Top nav ───────────────────────────────────
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        // ── Step hint (Step 7 — will be dynamic) ──────
        Positioned(
          bottom: 72,
          left: 0,
          right: 0,
          child: _StepHintText(label: stepLabel, stepText: stepText),
        ),
        Positioned(
          bottom: 22,
          left: 24,
          right: 24,
          child: AppButton(onPressed: isCaptureComplete ? null : onManualCapture, icon: const Icon(Icons.camera_alt_rounded), label: ('Capture Manually')),
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
            FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Grant Permission')),
          ],
        ),
      ),
    );
  }
}
