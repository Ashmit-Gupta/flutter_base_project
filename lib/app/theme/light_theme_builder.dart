import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'light_colors.dart';

/// Builds the light theme for the app.
ThemeData buildLightTheme({
  required String fontFamily,
}) {
  final colors = LightColors();
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    extensions: [
      AppTheme(colors: colors, fontFamily: fontFamily),
    ],
  );
}
