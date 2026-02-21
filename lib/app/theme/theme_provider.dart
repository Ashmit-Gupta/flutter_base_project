import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'theme_notifier.dart';
import 'theme_state.dart';
import 'theme_mode.dart';

/// Exposes [ThemeState] to the app.
final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

/// Converts [AppThemeMode] to Flutter [ThemeMode].
final materialThemeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(themeProvider).mode;

  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});
