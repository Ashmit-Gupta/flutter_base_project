import 'package:flutter/material.dart';

/// Alignment state of the face — drives the overlay color.
/// Will be populated from eulerY in Step 4.
enum FaceAlignState { idle, aligned, wrong }

class FaceOverlayPainter extends CustomPainter {
  final FaceAlignState alignState;
  final double progress; // 0.0 → 1.0 for the hold-timer arc (Step 6)

  const FaceOverlayPainter({
    required this.alignState,
    this.progress = 0.0,
  });

  // ── Oval geometry — tweak these to fit your device ───────────
  static const double _ovalWidthFactor = 0.68;   // 68% of screen width
  static const double _ovalHeightFactor = 0.42;  // 42% of screen height
  static const double _ovalYOffset = -0.04;      // slight upward shift

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = _buildOvalRect(size);

    _drawScrim(canvas, size, ovalRect);
    _drawOvalBorder(canvas, ovalRect);
    _drawCornerTicks(canvas, ovalRect);

    if (progress > 0.0) {
      _drawProgressArc(canvas, ovalRect);
    }
  }

  // ── 1. Dark scrim with oval hole ─────────────────────────────
  void _drawScrim(Canvas canvas, Size size, Rect ovalRect) {
    final scrimPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd; // ← punches the hole

    canvas.drawPath(
      scrimPath,
      Paint()..color = Colors.black.withOpacity(0.55),
    );
  }

  // ── 2. Oval border (color reflects alignment) ─────────────────
  void _drawOvalBorder(Canvas canvas, Rect ovalRect) {
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = _borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  // ── 3. Corner tick marks ──────────────────────────────────────
  // Draws 4 L-shaped ticks at top-left, top-right, bottom-left, bottom-right
  void _drawCornerTicks(Canvas canvas, Rect ovalRect) {
    const tickLen = 18.0;
    const tickGap = 10.0; // gap between tick and oval edge

    final paint = Paint()
      ..color = _borderColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final cx = ovalRect.center.dx;
    final cy = ovalRect.center.dy;
    final rx = ovalRect.width / 2 + tickGap;
    final ry = ovalRect.height / 2 + tickGap;

    // top-left
    _drawTick(canvas, paint,
        Offset(cx - rx, cy - ry), tickLen, 1, 1);
    // top-right
    _drawTick(canvas, paint,
        Offset(cx + rx, cy - ry), tickLen, -1, 1);
    // bottom-left
    _drawTick(canvas, paint,
        Offset(cx - rx, cy + ry), tickLen, 1, -1);
    // bottom-right
    _drawTick(canvas, paint,
        Offset(cx + rx, cy + ry), tickLen, -1, -1);
  }

  void _drawTick(
      Canvas canvas,
      Paint paint,
      Offset origin,
      double len,
      double xDir, // +1 right, -1 left
      double yDir, // +1 down,  -1 up
      ) {
    // horizontal arm
    canvas.drawLine(origin, origin.translate(len * xDir, 0), paint);
    // vertical arm
    canvas.drawLine(origin, origin.translate(0, len * yDir), paint);
  }

  // ── 4. Progress arc around oval (Step 6 — just plumbed now) ──
  void _drawProgressArc(Canvas canvas, Rect ovalRect) {
    final arcRect = ovalRect.inflate(6);
    canvas.drawArc(
      arcRect,
      -1.5708, // start at top (−π/2)
      6.2832 * progress, // sweep angle
      false,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────
  Rect _buildOvalRect(Size size) {
    final w = size.width * _ovalWidthFactor;
    final h = size.height * _ovalHeightFactor;
    final cx = size.width / 2;
    final cy = size.height / 2 + size.height * _ovalYOffset;

    return Rect.fromCenter(
      center: Offset(cx, cy),
      width: w,
      height: h,
    );
  }

  Color get _borderColor {
    switch (alignState) {
      case FaceAlignState.idle:
        return Colors.white.withOpacity(0.6);
      case FaceAlignState.aligned:
        return Colors.greenAccent;
      case FaceAlignState.wrong:
        return Colors.redAccent;
    }
  }

  // Only repaint when state or progress changes
  @override
  bool shouldRepaint(FaceOverlayPainter old) =>
      old.alignState != alignState || old.progress != progress;
}