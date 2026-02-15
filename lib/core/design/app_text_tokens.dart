/// Centralized typography scale for the app.
///
/// ❌ Widgets must NOT hardcode font sizes.
/// ✅ Widgets must ONLY use semantic text styles built from these tokens.
///
/// This enables:
/// - Consistent typography across features
/// - Easy global re-scaling (accessibility / brand refresh)
/// - Mobile-first responsive scaling (tablet / web multipliers)
/// - Design ↔ Engineering parity (Figma → Flutter)
class AppTextTokens {
  AppTextTokens._();

  /* ───────────────── Base Font Sizes (mobile-first) ───────────────── */

  /// Largest display text — **48px**.
  ///
  /// Usage:
  /// - Splash / hero headings
  /// - Empty state headlines
  /// - Marketing-style emphasis
  /// // maxFontSize intentionally set to AppTextTokens.display (48)to avoid clamping token-defined sizes at theme build time.
  static const double display = 48;

  /// Primary page headline — **32px**.
  ///
  /// Usage:
  /// - Screen titles
  /// - Section headers
  /// - High-importance information
  static const double headline = 32;

  /// Title text for cards and dialogs — **20px**.
  ///
  /// Usage:
  /// - Card titles
  /// - Dialog headers
  /// - Bottom sheet titles
  static const double title = 20;

  /// Primary body text — **16px**.
  ///
  /// Usage:
  /// - Paragraphs
  /// - Form content
  /// - Descriptive text
  static const double body = 16;

  /// Label text for UI controls — **14px**.
  ///
  /// Usage:
  /// - Button labels
  /// - Input labels
  /// - Tabs and chips
  static const double label = 14;

  /// Small supporting or secondary text — **12px**.
  ///
  /// Usage:
  /// - Helper text
  /// - Metadata (dates, hints)
  /// - Legal or footnote content
  static const double caption = 12;
}
