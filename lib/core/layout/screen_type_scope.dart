import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Provides [ScreenType] and [textScaler] to the subtree.
///
/// Layout layer (e.g. [AdaptiveLayoutBuilder]) sets this so UI never
/// reads [MediaQuery] directly. Defaults to [ScreenType.mobile] and identity scaler
/// when not found.
class ScreenTypeScope extends InheritedWidget {
  const ScreenTypeScope({
    super.key,
    required this.screenType,
    required this.textScaler,
    required super.child,
  });

  final ScreenType screenType;
  final TextScaler textScaler;

  static ScreenType screenTypeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScreenTypeScope>();
    return scope?.screenType ?? ScreenType.mobile;
  }

  static TextScaler textScalerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScreenTypeScope>();
    return scope?.textScaler ?? TextScaler.noScaling;
  }

  @override
  bool updateShouldNotify(ScreenTypeScope oldWidget) =>
      screenType != oldWidget.screenType ||
      textScaler != oldWidget.textScaler;
}
