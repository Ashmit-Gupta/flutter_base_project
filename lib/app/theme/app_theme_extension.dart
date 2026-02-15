import 'package:flutter/material.dart';

import '../../core/design/app_typography.dart';
import '../../core/layout/screen_type_scope.dart';
import 'app_theme.dart';

/// Convenient access to [AppTheme] and unified typography from [BuildContext].
///
/// Usage:
/// ```dart
/// context.theme.colors.primary;
/// context.text.headline();
/// context.text.body();
/// ```
extension AppThemeX on BuildContext {
  AppTheme get theme => Theme.of(this).extension<AppTheme>()!;

  /// Single typography system; adaptive by layout (no MediaQuery in UI).
  AppTypography get text {
    final t = theme;
    return typographyForScreen(
      ScreenTypeScope.screenTypeOf(this),
      t.colors.textPrimary,
      t.fontFamily,
      textScaleFactor: ScreenTypeScope.textScaleFactorOf(this),
    );
  }
}
