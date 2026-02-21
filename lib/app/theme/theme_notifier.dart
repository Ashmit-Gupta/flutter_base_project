import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_state.dart';
import 'theme_mode.dart';

/// Controls app theme state.
///
/// This is the ONLY place allowed
/// to modify theme-related values.
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() => const ThemeState(
        mode: AppThemeMode.system,
        fontFamily: 'Roboto',
      );

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setFontFamily(String font) {
    state = state.copyWith(fontFamily: font);
  }
}
