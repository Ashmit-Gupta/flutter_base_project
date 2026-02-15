/// Centralized border-radius scale for the entire app.
///
/// Mobile-first radius system to ensure consistent
/// shape language across buttons, cards, sheets,
/// and interactive elements.
class AppRadius {
  AppRadius._();

  /// Small radius — **6px**
  ///
  /// Use for:
  /// • Chips
  /// • Tags
  /// • Subtle rounding
  static const double sm = 6;

  /// Medium radius — **12px**
  ///
  /// Use for:
  /// • Buttons
  /// • Text fields
  /// • Default cards
  static const double md = 12;

  /// Large radius — **20px**
  ///
  /// Use for:
  /// • Modals
  /// • Bottom sheets
  /// • Prominent containers
  static const double lg = 20;

  /// Pill / fully rounded radius — **999px**
  ///
  /// Use for:
  /// • Pills
  /// • Avatars
  /// • Fully rounded buttons
  ///
  /// Intentionally large to always exceed
  /// half of the shortest side.
  static const double pill = 999;
}
