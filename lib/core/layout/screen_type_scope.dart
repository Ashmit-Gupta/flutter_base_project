import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

/// Provides [ScreenType] and [textScaleFactor] to the subtree.
///
/// Layout layer (e.g. [AdaptiveLayoutBuilder]) sets this so UI never
/// reads [MediaQuery] directly. Defaults to [ScreenType.mobile] and 1.0
/// when not found.
class ScreenTypeScope extends InheritedWidget {
  const ScreenTypeScope({
    super.key,
    required this.screenType,
    required this.textScaleFactor,
    required super.child,
  });

  final ScreenType screenType;
  final double textScaleFactor;

  static ScreenType screenTypeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScreenTypeScope>();
    assert(() {
      if (scope == null) {
        debugPrint(
          '⚠️ ScreenTypeScope not found. '
              'Defaulting to ScreenType.mobile.',
        );
      }
      return true;
    }());
    return scope?.screenType ?? ScreenType.mobile;
  }

  static double textScaleFactorOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScreenTypeScope>();
    return scope?.textScaleFactor ?? 1.0;
  }

  @override
  bool updateShouldNotify(ScreenTypeScope oldWidget) =>
      screenType != oldWidget.screenType ||
      textScaleFactor != oldWidget.textScaleFactor;
}
