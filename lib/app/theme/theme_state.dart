import 'theme_mode.dart';
/// Immutable theme state controlled by Riverpod.
///
/// Extend this later for:
/// - Remote colors
/// - Font scaling
/// - High contrast
class ThemeState {
  final AppThemeMode mode;
  final String fontFamily;

  const ThemeState({
    required this.mode,
    required this.fontFamily,
  });

  ThemeState copyWith({
    AppThemeMode? mode,
    String? fontFamily,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
