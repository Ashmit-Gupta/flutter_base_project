import 'package:flutter/material.dart';
import 'face_overlay_painter.dart';

class FaceOverlayWidget extends StatelessWidget {
  final FaceAlignState alignState;
  final double progress;

  const FaceOverlayWidget({
    super.key,
    this.alignState = FaceAlignState.idle,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceOverlayPainter(
        alignState: alignState,
        progress: progress,
      ),
      // ← Must fill the entire Stack
      child: const SizedBox.expand(),
    );
  }
}