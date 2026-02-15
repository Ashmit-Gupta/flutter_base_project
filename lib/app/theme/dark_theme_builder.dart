import 'package:flutter/material.dart';

import '../../core/design/app_radius.dart';
import 'app_button_theme.dart';
import 'app_snackbar_theme.dart';
import 'app_theme.dart';
import 'dark_colors.dart';

/// Builds the dark theme for the app.
ThemeData buildDarkTheme({
  required String fontFamily,
}) {
  final colors = DarkAppColors();
  final baseTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: colors.background,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.border),
      ),
        focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.primary),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: colors.error),
      ),
    ),
  );

  return baseTheme.copyWith(
    extensions: [
      AppTheme(colors: colors, fontFamily: fontFamily),
      buildAppButtonTheme(colors: colors, textTheme: baseTheme.textTheme),
      buildAppSnackbarTheme(colors: colors),
    ],
  );
}
