import 'package:flutter/widgets.dart';

import 'breakpoints.dart';
import 'screen_type_scope.dart';

/// Reusable adaptive layout with central breakpoints.
/// Uses [LayoutBuilder] internally; no [MediaQuery] in feature UI.
/// Graceful fallbacks: tablet → mobile, desktop → tablet → mobile.
class AdaptiveLayoutBuilder extends StatelessWidget {
  const AdaptiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = Breakpoints.resolve(constraints.maxWidth);
        final child = switch (screenType) {
          ScreenType.mobile => mobile,
          ScreenType.tablet => tablet ?? mobile,
          ScreenType.desktop => desktop ?? tablet ?? mobile,
        };
        final textScaleFactor = MediaQuery.textScaleFactorOf(context);
        return ScreenTypeScope(
          screenType: screenType,
          textScaleFactor: textScaleFactor,
          child: child,
        );
      },
    );
  }
}

/// Builder variant that receives [ScreenType] for custom layout logic.
class AdaptiveLayoutBuilderX extends StatelessWidget {
  const AdaptiveLayoutBuilderX({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext context, ScreenType screenType) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenType = Breakpoints.resolve(constraints.maxWidth);
        final textScaleFactor = MediaQuery.textScaleFactorOf(context);
        return ScreenTypeScope(
          screenType: screenType,
          textScaleFactor: textScaleFactor,
          child: builder(context, screenType),
        );
      },
    );
  }
}
