import 'package:flutter/material.dart';

import '../../core/design/app_radius.dart';
import '../../core/design/app_spacing.dart';
import 'app_colors.dart';

/// Button styling for [AppButton] variants.
///
/// All visual responsibility lives here — widgets must not override
/// colors, text styles, or dimensions. Populated by theme builders
/// using [AppColors] and design tokens.
@immutable
class AppButtonTheme extends ThemeExtension<AppButtonTheme> {
  const AppButtonTheme({
    required this.primaryStyle,
    required this.secondaryStyle,
    required this.dangerStyle,
  });

  final ButtonStyle primaryStyle;
  final ButtonStyle secondaryStyle;
  final ButtonStyle dangerStyle;

  @override
  AppButtonTheme copyWith({
    ButtonStyle? primaryStyle,
    ButtonStyle? secondaryStyle,
    ButtonStyle? dangerStyle,
  }) {
    return AppButtonTheme(
      primaryStyle: primaryStyle ?? this.primaryStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
      dangerStyle: dangerStyle ?? this.dangerStyle,
    );
  }

  @override
  AppButtonTheme lerp(ThemeExtension<AppButtonTheme>? other, double t) {
    if (other is! AppButtonTheme) return this;
    return AppButtonTheme(
      primaryStyle: ButtonStyle.lerp(primaryStyle, other.primaryStyle, t)!,
      secondaryStyle: ButtonStyle.lerp(secondaryStyle, other.secondaryStyle, t)!,
      dangerStyle: ButtonStyle.lerp(dangerStyle, other.dangerStyle, t)!,
    );
  }
}

/// Builds [AppButtonTheme] from [AppColors] and [TextTheme].
///
/// Call from theme builders — styling must NOT live in widget code.
AppButtonTheme buildAppButtonTheme({
  required AppColors colors,
  required TextTheme textTheme,
}) {
  final textStyle = textTheme.labelLarge;
  const size = Size(double.infinity, 48);
  const padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
  );

  return AppButtonTheme(
    primaryStyle: FilledButton.styleFrom(
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      disabledBackgroundColor: colors.border,
      disabledForegroundColor: colors.textMuted,
      minimumSize: size,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
    ),
    secondaryStyle: OutlinedButton.styleFrom(
      foregroundColor: colors.primary,
      disabledForegroundColor: colors.textMuted,
      side: BorderSide(color: colors.border),

      minimumSize: size,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
    ),
    dangerStyle: FilledButton.styleFrom(
      backgroundColor: colors.error,
      foregroundColor: colors.onPrimary,
      disabledBackgroundColor: colors.border,
      disabledForegroundColor: colors.textMuted,
      minimumSize: size,
      padding: padding,
      shape: shape,
      textStyle: textStyle,
    ),
  );
}
