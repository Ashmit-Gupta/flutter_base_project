// import 'package:flutter/material.dart';
// import 'face_overlay_painter.dart';
//
// class FaceOverlayWidget extends StatelessWidget {
//   final FaceAlignState alignState;
//   final double progress;
//
//   const FaceOverlayWidget({
//     super.key,
//     this.alignState = FaceAlignState.idle,
//     this.progress = 0.0,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: FaceOverlayPainter(
//         alignState: alignState,
//         progress: progress,
//       ),
//       // ← Must fill the entire Stack
//       child: const SizedBox.expand(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../presentation/controller/face_capture_controller.dart';
import 'face_overlay_painter.dart';

class FaceOverlayWidget extends HookWidget {
  final FaceAlignState alignState;
  final double progress;
  final FaceCaptureStep currentStep;

  const FaceOverlayWidget({
    super.key,
    required this.alignState,
    required this.progress,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = Theme.of(context).colorScheme.primary;

    // ── Scan line animation: 0→1→0 pingpong, 1.8s per sweep ─────
    final scanController = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );

    useEffect(() {
      scanController.repeat(reverse: true);
      return null;
    }, const []);

    final scanAnim = CurvedAnimation(
      parent: scanController,
      curve: Curves.easeInOut,
    );

    // AnimatedBuilder: only the CustomPaint repaints on each tick,
    // not the entire overlay widget tree.
    return AnimatedBuilder(
      animation: scanAnim,
      builder: (context, child) {
        return CustomPaint(
          painter: FaceFramePainter(
            alignState: alignState,
            progress: progress,
            scanY: scanAnim.value,
            brandColor: brandColor,
          ),
          child: child,
        );
      },
      // child is stable — only rebuilds when step/alignState changes
      child: SizedBox.expand(
        child: _DirectionArrow(
          step: currentStep,
          alignState: alignState,
          brandColor: brandColor,
        ),
      ),
    );
  }
}

// ── Direction arrow ───────────────────────────────────────────────
// Shows which way to turn. Hidden when already aligned.
class _DirectionArrow extends StatelessWidget {
  final FaceCaptureStep step;
  final FaceAlignState alignState;
  final Color brandColor;

  const _DirectionArrow({
    required this.step,
    required this.alignState,
    required this.brandColor,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show arrow when face is already aligned
    if (alignState == FaceAlignState.aligned) return const SizedBox.shrink();

    return Align(
      // Position near the lower-center of the shield frame
      alignment: const Alignment(0, 0.28),
      child: _buildArrowContent(brandColor),
    );
  }

  Widget _buildArrowContent(Color color) {
    return switch (step) {
    // ── Left: two chevrons bouncing left ────────────────────────
      FaceCaptureStep.left => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left_rounded, color: color, size: 36)
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 300.ms)
              .then()
              .moveX(
            begin: 4,
            end: -6,
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
              .then()
              .moveX(
            begin: -6,
            end: 4,
            duration: 600.ms,
            curve: Curves.easeInOut,
          ),

          Icon(Icons.chevron_left_rounded, color: color.withValues(alpha: 0.45), size: 36)
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 300.ms, delay: 150.ms)
              .then()
              .moveX(
            begin: 4,
            end: -6,
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
              .then()
              .moveX(
            begin: -6,
            end: 4,
            duration: 600.ms,
            curve: Curves.easeInOut,
          ),
        ],
      ),

    // ── Front: circular arrows pulse (hold still) ────────────────
      FaceCaptureStep.front => Icon(
        Icons.filter_center_focus_rounded,
        color: color,
        size: 40,
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.1, 1.1),
        duration: 900.ms,
        curve: Curves.easeInOut,
      )
          .then()
          .scale(
        begin: const Offset(1.1, 1.1),
        end: const Offset(0.9, 0.9),
        duration: 900.ms,
        curve: Curves.easeInOut,
      ),

    // ── Right: two chevrons bouncing right ───────────────────────
      FaceCaptureStep.right => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.45), size: 36)
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 300.ms, delay: 150.ms)
              .then()
              .moveX(
            begin: -4,
            end: 6,
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
              .then()
              .moveX(
            begin: 6,
            end: -4,
            duration: 600.ms,
            curve: Curves.easeInOut,
          ),

          Icon(Icons.chevron_right_rounded, color: color, size: 36)
              .animate(onPlay: (c) => c.repeat())
              .fadeIn(duration: 300.ms)
              .then()
              .moveX(
            begin: -4,
            end: 6,
            duration: 600.ms,
            curve: Curves.easeInOut,
          )
              .then()
              .moveX(
            begin: 6,
            end: -4,
            duration: 600.ms,
            curve: Curves.easeInOut,
          ),
        ],
      ),
    };
  }
}