import 'package:flutter/material.dart';

enum FaceAlignState { idle, aligned, wrong }

class FaceFramePainter extends CustomPainter {
  final FaceAlignState alignState;
  final double progress;   // 0.0 → 1.0 hold progress
  final double scanY;      // 0.0 → 1.0 animated scan line position
  final Color brandColor;

  const FaceFramePainter({
    required this.alignState,
    required this.progress,
    required this.scanY,
    required this.brandColor,
  });

  // ── Frame geometry ────────────────────────────────────────────
  static const double _widthFactor   = 0.72;
  static const double _heightFactor  = 0.50;
  static const double _yOffset       = -0.03;
  static const double _cornerR       = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final frameRect  = _buildFrameRect(size);
    final shieldPath = _buildShieldPath(frameRect);

    _drawScrim(canvas, size, shieldPath);
    _drawScanLine(canvas, shieldPath, frameRect);

    if (progress > 0.0) {
      _drawProgressFill(canvas, shieldPath);
    }

    _drawBorder(canvas, shieldPath);
    _drawCornerBrackets(canvas, frameRect);
  }

  Path _buildShieldPath(Rect rect) {
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(_cornerR),
        ),
      );
  }
  // ── 2. Dark scrim with shield cutout ──────────────────────────
  void _drawScrim(Canvas canvas, Size size, Path shieldPath) {
    final scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(shieldPath, Offset.zero)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      scrimPath,
      Paint()..color = Colors.black.withValues(alpha: 0.62),
    );
  }

  // ── 3. Scan line (clipped to shield) ──────────────────────────
  void _drawScanLine(Canvas canvas, Path shieldPath, Rect frameRect) {
    if (alignState == FaceAlignState.wrong) return; // hide when wrong

    canvas.save();
    canvas.clipPath(shieldPath); // line stays inside shield

    // scanY 0.0 = top of frame, 1.0 = bottom of frame
    final y = frameRect.top + frameRect.height * scanY;
    // main line gradient
    final lineRect = Rect.fromLTWH(
      frameRect.left, y - 1.5, frameRect.width, 3,
    );
    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            brandColor.withValues(alpha: 0.5),
            brandColor.withValues(alpha: 0.9),
            brandColor.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
        ).createShader(lineRect),
    );

    // soft glow below line
    final glowRect = Rect.fromLTWH(
      frameRect.left, y, frameRect.width, 36,
    );
    canvas.drawRect(
      glowRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [brandColor.withValues(alpha: 0.12), Colors.transparent],
        ).createShader(glowRect),
    );

    canvas.restore();
  }

  // ── 4. Progress fills along the shield border ─────────────────
  // Uses PathMetrics so the fill literally traces the shield outline
  void _drawProgressFill(Canvas canvas, Path shieldPath) {
    final metric = shieldPath.computeMetrics().first;
    final filledPath = metric.extractPath(0, metric.length * progress);

    canvas.drawPath(
      filledPath,
      Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── 5. Shield border ──────────────────────────────────────────
  void _drawBorder(Canvas canvas, Path shieldPath) {
    // Outer glow when aligned
    if (alignState == FaceAlignState.aligned) {
      canvas.drawPath(
        shieldPath,
        Paint()
          ..color = Colors.greenAccent.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  // ── 6. Corner brackets (biometric scanner feel) ────────────────
  // Only draws on the straight top portion of the shield
  void _drawCornerBrackets(Canvas canvas, Rect rect) {
    const len   = 20.0;
    const inset = _cornerR + 2; // aligns with where the shield corner ends

    final paint = Paint()
      ..color       = _borderColor
      ..strokeWidth = 3.0
      ..strokeCap   = StrokeCap.square
      ..style       = PaintingStyle.stroke;

    // top-left horizontal
    canvas.drawLine(
      Offset(rect.left + inset, rect.top),
      Offset(rect.left + inset + len, rect.top),
      paint,
    );
    // top-left vertical
    canvas.drawLine(
      Offset(rect.left, rect.top + inset),
      Offset(rect.left, rect.top + inset + len),
      paint,
    );

    // top-right horizontal
    canvas.drawLine(
      Offset(rect.right - inset - len, rect.top),
      Offset(rect.right - inset, rect.top),
      paint,
    );
    // top-right vertical
    canvas.drawLine(
      Offset(rect.right, rect.top + inset),
      Offset(rect.right, rect.top + inset + len),
      paint,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Rect _buildFrameRect(Size size) {
    final w  = size.width  * _widthFactor;
    final h  = size.height * _heightFactor;
    final cx = size.width  / 2;
    final cy = size.height / 2 + size.height * _yOffset;
    return Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
  }

  Color get _borderColor => switch (alignState) {
    FaceAlignState.idle    => Colors.white.withValues(alpha: 0.65),
    FaceAlignState.aligned => Colors.greenAccent,
    FaceAlignState.wrong   => Colors.redAccent,
  };

  @override
  bool shouldRepaint(FaceFramePainter old) =>
      old.alignState  != alignState  ||
          old.progress    != progress    ||
          old.scanY       != scanY       ||
          old.brandColor  != brandColor;
}