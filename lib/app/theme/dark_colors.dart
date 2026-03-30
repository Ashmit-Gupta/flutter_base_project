import 'dart:ui';

import 'app_colors.dart';

/// Dark theme color implementation for the Electric Fuel Coupon App.
///
/// Dark theme principles:
/// - Reduce eye strain in low-light environments
/// - Preserve financial semantics (green = value, red = spend)
/// - Avoid neon / oversaturated colors
/// - Maintain strong contrast & hierarchy
class DarkAppColors implements AppColors {
  /* ───────────────── Brand ───────────────── */

  @override
  Color get primary =>
      const Color(0xFF22C55E); // Softer green for actions & balance

  @override
  Color get primaryDark =>
      const Color(0xFF16A34A); // Pressed / emphasized state

  @override
  Color get primaryLight =>
      const Color(0xFF052E1B); // Subtle green tint for containers

  @override
  Color get onPrimary => const Color(0xFFF9FAFB); // Content on primary/error

  @override
  Color get secondary =>
      const Color(0xFF60A5FA); // Muted blue for trust & info

  /* ───────────────── Backgrounds ───────────────── */

  @override
  Color get background =>
      const Color(0xFF0F172A); // Main app background (deep navy)

  @override
  Color get surface =>
      const Color(0xFF111827); // Cards, sheets, dialogs

  @override
  Color get border =>
      const Color(0xFF1F2933); // Borders & dividers (low contrast)

  /* ───────────────── Text ───────────────── */

  @override
  Color get textPrimary =>
      const Color(0xFFF9FAFB); // Headings & primary content

  @override
  Color get textSecondary =>
      const Color(0xFFCBD5E1); // Body text

  @override
  Color get textMuted =>
      const Color(0xFF64748B); // Hints, placeholders, disabled

  /* ───────────────── Status ───────────────── */

  @override
  Color get success =>
      const Color(0xFF22C55E); // Success confirmations

  @override
  Color get warning =>
      const Color(0xFFFBBF24); // Pending / warning states

  @override
  Color get error =>
      const Color(0xFFEF4444); // Errors / failures

  /* ───────────────── Transactions ───────────────── */

  @override
  Color get credit =>
      const Color(0xFF22C55E); // Money received

  @override
  Color get debit =>
      const Color(0xFFF87171); // Money spent (less aggressive red)

  @override
  Color get neutral =>
      const Color(0xFF94A3B8); // Fees / system entries

}
