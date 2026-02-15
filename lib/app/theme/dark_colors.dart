import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Default dark theme colors.
///
/// Used when:
/// - User selects dark mode
/// - System theme is dark (if themeMode = system)
class DarkColors implements AppColors {
  @override
  Color get primary => const Color(0xFF7C3AED);

  @override
  Color get background => const Color(0xFF0F172A);

  @override
  Color get textPrimary => const Color(0xFFE5E7EB);
}
