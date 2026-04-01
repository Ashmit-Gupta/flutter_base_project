import 'package:shared_preferences/shared_preferences.dart';

import 'theme_mode.dart';

/// SharedPreferences keys and helpers for persisted theme settings.
class ThemePreferences {
  ThemePreferences._();

  static const String themeModeKey = 'app_theme_mode';
  static const String fontFamilyKey = 'app_font_family';

  static AppThemeMode? readMode(SharedPreferences prefs) {
    final raw = prefs.getString(themeModeKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppThemeMode.values.byName(raw);
    } catch (_) {
      return null;
    }
  }

  static String readFontFamily(SharedPreferences prefs) {
    return prefs.getString(fontFamilyKey) ?? 'Roboto';
  }

  static Future<void> saveMode(
    SharedPreferences prefs,
    AppThemeMode mode,
  ) =>
      prefs.setString(themeModeKey, mode.name);

  static Future<void> saveFontFamily(
    SharedPreferences prefs,
    String font,
  ) =>
      prefs.setString(fontFamilyKey, font);
}
