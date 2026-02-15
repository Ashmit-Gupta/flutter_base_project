import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../layout/breakpoints.dart';
import '../layout/screen_type_scope.dart';
import 'app_text_tokens.dart';
import 'typography_scale.dart';

/// Single adaptive typography system.
///
/// Semantic roles: display, headline, title, body, label, caption.
/// Mobile max font size ≈ 20. Respects accessibility via [textScaleFactor].
/// Use via [context.text] from app layer (no MediaQuery in UI).
class AppTypography {
  AppTypography({
    required this.color,
    required this.fontFamily,
    required this.scale,
    required this.maxFontSize,
    this.textScaleFactor = 1.0,
  });

  final Color color;
  final String fontFamily;
  final double scale;
  final double maxFontSize;
  final double textScaleFactor;

  double _size(double base) {
    final scaled = base * scale * textScaleFactor;
    return math.min(scaled, maxFontSize);
  }

  TextStyle display() => TextStyle(
        fontSize: _size(AppTextTokens.display),
        fontWeight: FontWeight.bold,
        color: color,
        fontFamily: fontFamily,
      );

  TextStyle headline() => TextStyle(
        fontSize: _size(AppTextTokens.headline),
        fontWeight: FontWeight.w600,
        color: color,
        fontFamily: fontFamily,
      );

  TextStyle title() => TextStyle(
        fontSize: _size(AppTextTokens.title),
        fontWeight: FontWeight.w500,
        color: color,
        fontFamily: fontFamily,
      );

  TextStyle body() => TextStyle(
        fontSize: _size(AppTextTokens.body),
        color: color,
        fontFamily: fontFamily,
      );

  TextStyle label() => TextStyle(
        fontSize: _size(AppTextTokens.label),
        fontWeight: FontWeight.w500,
        color: color,
        fontFamily: fontFamily,
      );

  TextStyle caption() => TextStyle(
        fontSize: _size(AppTextTokens.caption),
        color: color.withValues(alpha: 0.7),
        fontFamily: fontFamily,
      );
}

/// Builds [AppTypography] for the given [screenType]. Used by app layer
/// with [ScreenTypeScope]; UI must not call this with [MediaQuery]-derived width.
AppTypography typographyForScreen(
  ScreenType screenType,
  Color color,
  String fontFamily, {
  double textScaleFactor = 1.0,
}) {
  final ts = TypographyScale.fromScreen(screenType);
  return AppTypography(
    color: color,
    fontFamily: fontFamily,
    scale: ts.factor,
    maxFontSize: ts.maxFontSize,
    textScaleFactor: textScaleFactor,
  );
}
