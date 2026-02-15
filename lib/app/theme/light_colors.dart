import 'package:flutter/material.dart';
import 'app_colors.dart';


/// Default light theme colors.
///
/// Used as:
/// - App fallback
/// - First launch theme
/// - When backend theme fails
class LightColors implements AppColors {
  @override
  Color get primary => const Color(0xFF2563EB);

  @override
  Color get background => Colors.white;

  @override
  Color get textPrimary => const Color(0xFF111827);
}
