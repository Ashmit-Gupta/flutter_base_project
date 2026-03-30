import '../layout/breakpoints.dart';

class TypographyScale {
  final double factor;
  final double maxFontSize;

  const TypographyScale({
    required this.factor,
    required this.maxFontSize,
  });

  static TypographyScale fromScreen(ScreenType type) {
    switch (type) {
      case ScreenType.mobile:
        return const TypographyScale(
          factor: 1.0,
          maxFontSize: 20,
        );
      case ScreenType.tablet:
        return const TypographyScale(
          factor: 1.1,
          maxFontSize: 28,
        );
      case ScreenType.desktop:
        return const TypographyScale(
          factor: 1.2,
          maxFontSize: 36,
        );
    }
  }
}
