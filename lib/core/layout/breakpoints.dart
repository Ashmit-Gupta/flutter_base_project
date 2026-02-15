enum ScreenType {
  mobile,
  tablet,
  desktop,
}

class Breakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static ScreenType resolve(double width) {
    if (width < mobileMax) return ScreenType.mobile;
    if (width < tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}
