/// Centralized spacing scale for the entire app.
///
/// Mobile-first, 8-pt inspired spacing system.
/// Use these values instead of raw numbers to ensure
/// visual consistency and easy global tuning.
class AppSpacing {
  AppSpacing._();

  /// Extra-small spacing — **4px**
  ///
  /// Use for:
  /// • Very tight gaps
  /// • Icon padding
  /// • Divider spacing
  static const double xs = 4;

  /// Small spacing — **8px**
  ///
  /// Use for:
  /// • Inner padding
  /// • Small gaps between elements
  /// • Compact layouts
  static const double sm = 8;

  /// Medium spacing — **16px**
  ///
  /// Use for:
  /// • Default padding
  /// • Section separation
  /// • Form field spacing
  static const double md = 16;

  /// Large spacing — **24px**
  ///
  /// Use for:
  /// • Card padding
  /// • Major section gaps
  /// • Vertical rhythm
  static const double lg = 24;

  /// Extra-large spacing — **32px**
  ///
  /// Use for:
  /// • Screen margins
  /// • Large layout separation
  static const double xl = 32;

  /// Double extra-large spacing — **48px**
  ///
  /// Use for:
  /// • Page-level separation
  /// • Hero sections
  /// • Empty state layouts
  static const double xxl = 48;
}
