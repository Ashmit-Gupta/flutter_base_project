import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'dark_colors.dart';

/// Builds the dark theme for the app.
ThemeData buildDarkTheme({
  required String fontFamily,
}) {
  final colors = DarkColors();
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    extensions: [
      AppTheme(colors: colors, fontFamily: fontFamily),
    ],
  );
}
