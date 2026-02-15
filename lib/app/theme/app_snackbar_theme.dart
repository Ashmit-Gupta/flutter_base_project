import 'package:flutter/material.dart';

import '../../core/feedback/app_snackbar_type.dart';
import 'app_colors.dart';

/// Snackbar styling per [AppSnackbarType].
///
/// All visual styling is centralized here — no hard-coded colors
/// or text styles in the snackbar widget or helper.
@immutable
class AppSnackbarTheme extends ThemeExtension<AppSnackbarTheme> {
  const AppSnackbarTheme({
    required this.successBackgroundColor,
    required this.warningBackgroundColor,
    required this.errorBackgroundColor,
    required this.infoBackgroundColor,
    required this.contentColor,
  });

  final Color successBackgroundColor;
  final Color warningBackgroundColor;
  final Color errorBackgroundColor;
  final Color infoBackgroundColor;
  final Color contentColor;

  Color backgroundColorFor(AppSnackbarType type) {
    return switch (type) {
      AppSnackbarType.success => successBackgroundColor,
      AppSnackbarType.warning => warningBackgroundColor,
      AppSnackbarType.error => errorBackgroundColor,
      AppSnackbarType.info => infoBackgroundColor,
    };
  }

  /// Text style for snackbar content. Derived from [TextTheme], not inline.
  TextStyle contentStyle(TextTheme textTheme) {
    return (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: contentColor,
    );
  }

  @override
  AppSnackbarTheme copyWith({
    Color? successBackgroundColor,
    Color? warningBackgroundColor,
    Color? errorBackgroundColor,
    Color? infoBackgroundColor,
    Color? contentColor,
  }) {
    return AppSnackbarTheme(
      successBackgroundColor: successBackgroundColor ?? this.successBackgroundColor,
      warningBackgroundColor: warningBackgroundColor ?? this.warningBackgroundColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      infoBackgroundColor: infoBackgroundColor ?? this.infoBackgroundColor,
      contentColor: contentColor ?? this.contentColor,
    );
  }

  @override
  AppSnackbarTheme lerp(ThemeExtension<AppSnackbarTheme>? other, double t) {
    if (other is! AppSnackbarTheme) return this;
    return AppSnackbarTheme(
      successBackgroundColor:
          Color.lerp(successBackgroundColor, other.successBackgroundColor, t)!,
      warningBackgroundColor:
          Color.lerp(warningBackgroundColor, other.warningBackgroundColor, t)!,
      errorBackgroundColor:
          Color.lerp(errorBackgroundColor, other.errorBackgroundColor, t)!,
      infoBackgroundColor:
          Color.lerp(infoBackgroundColor, other.infoBackgroundColor, t)!,
      contentColor: Color.lerp(contentColor, other.contentColor, t)!,
    );
  }
}

/// Builds [AppSnackbarTheme] from [AppColors].
///
/// Call from theme builders — styling must NOT live in widget/helper code.
AppSnackbarTheme buildAppSnackbarTheme({required AppColors colors}) {
  return AppSnackbarTheme(
    successBackgroundColor: colors.success,
    warningBackgroundColor: colors.warning,
    errorBackgroundColor: colors.error,
    infoBackgroundColor: colors.secondary,
    contentColor: colors.onPrimary,
  );
}

/// Default durations per snackbar type.
///
/// Success: quick dismiss (~2.5s). Warning/Error: longer for readability.
int durationForType(AppSnackbarType type) {
  return switch (type) {
    AppSnackbarType.success => 2500,
    AppSnackbarType.warning => 4000,
    AppSnackbarType.error => 4500,
    AppSnackbarType.info => 3000,
  };
}
