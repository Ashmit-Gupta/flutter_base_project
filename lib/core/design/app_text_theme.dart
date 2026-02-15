import 'package:flutter/material.dart';

import '../layout/breakpoints.dart';
import 'app_typography.dart';
import 'typography_scale.dart';

/// Builds a [TextTheme] from design tokens ([AppTextTokens] via [AppTypography]).
///
/// Used by theme builders so that [ThemeData.textTheme] is the single source
/// of typography for components (buttons, snackbars, text fields). Uses
/// mobile baseline (scale 1.0) and a permissive [maxFontSize] so token sizes
/// are not clamped at theme build time (no [ScreenTypeScope] available).
///
/// Adaptive typography for free-form UI remains via [context.text].
TextTheme buildAppTextTheme({
  required Color color,
  required String fontFamily,
}) {
  final ts = TypographyScale.fromScreen(ScreenType.mobile);
  final typography = AppTypography(
    color: color,
    fontFamily: fontFamily,
    scale: ts.factor,
    maxFontSize: 48,
    textScaleFactor: 1.0,
  );

  final display = typography.display();
  final headline = typography.headline();
  final title = typography.title();
  final body = typography.body();
  final label = typography.label();
  final caption = typography.caption();

  return TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: headline,
    headlineLarge: headline,
    headlineMedium: headline,
    headlineSmall: title,
    titleLarge: title,
    titleMedium: title,
    titleSmall: label,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: label,
    labelMedium: label,
    labelSmall: caption,
  );
}
