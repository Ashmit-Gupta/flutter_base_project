import 'package:flutter/material.dart';

/// Contract for all app colors.
///
/// Widgets should NEVER use [Color] directly.
/// They must use colors from this abstraction.
///
/// This allows:
/// - Easy theme changes
/// - Backend-driven theming
/// - Zero widget refactors
abstract class AppColors {
  Color get primary;
  Color get background;
  Color get textPrimary;
}
