import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App-wide design tokens injected into [ThemeData].
/// Typography comes from [context.text] (core/design); colors here.
@immutable
class AppTheme extends ThemeExtension<AppTheme> {
  const AppTheme({
    required this.colors,
    required this.fontFamily,
  });

  final AppColors colors;
  final String fontFamily;

  @override
  AppTheme copyWith({
    AppColors? colors,
    String? fontFamily,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    return this;
  }
}
