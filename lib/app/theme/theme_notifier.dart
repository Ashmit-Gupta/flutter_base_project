import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import 'theme_mode.dart';
import 'theme_preferences.dart';
import 'theme_state.dart';

/// Controls app theme state.
///
/// This is the ONLY place allowed
/// to modify theme-related values.
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.read(sharedPreferencesSyncProvider);
    final mode = ThemePreferences.readMode(prefs) ?? AppThemeMode.system;
    final font = ThemePreferences.readFontFamily(prefs);
    return ThemeState(mode: mode, fontFamily: font);
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
    unawaited(
      ThemePreferences.saveMode(ref.read(sharedPreferencesSyncProvider), mode),
    );
  }

  void setFontFamily(String font) {
    state = state.copyWith(fontFamily: font);
    unawaited(
      ThemePreferences.saveFontFamily(ref.read(sharedPreferencesSyncProvider), font),
    );
  }
}
