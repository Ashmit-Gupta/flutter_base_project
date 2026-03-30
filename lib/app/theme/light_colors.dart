import 'dart:ui';

import 'app_colors.dart';

/// Light theme color implementation for the Electric Fuel Coupon App.
///
/// Design principles:
/// - Green = money, fuel, success
/// - Blue = trust, finance, info
/// - Neutral grays = readability & hierarchy
class LightAppColors implements AppColors {
  /* ───────────────── Brand ───────────────── */

  @override
  Color get primary => const Color(0xFF1B8F4C); // Core green (actions, balance)

  @override
  Color get primaryDark => const Color(0xFF14703C); // Pressed / emphasized state

  @override
  Color get primaryLight => const Color(0xFFE6F4EC); // Soft green backgrounds

  @override
  Color get onPrimary => const Color(0xFFFFFFFF); // Content on primary/error

  @override
  Color get secondary => const Color(0xFF1F6AE1); // Trust / finance blue

  /* ───────────────── Backgrounds ───────────────── */

  @override
  Color get background => const Color(0xFFF7F9FC); // App background

  @override
  Color get surface => const Color(0xFFFFFFFF); // Cards, sheets

  @override
  Color get border => const Color(0xFFE5E7EB); // Borders & dividers

  /* ───────────────── Text ───────────────── */

  @override
  Color get textPrimary => const Color(0xFF111827); // Headings, values

  @override
  Color get textSecondary => const Color(0xFF4B5563); // Body text

  @override
  Color get textMuted => const Color(0xFF9CA3AF); // Disabled / hints

  /* ───────────────── Status ───────────────── */

  @override
  Color get success => const Color(0xFF16A34A); // Success confirmations

  @override
  Color get warning => const Color(0xFFF59E0B); // Pending / warning

  @override
  Color get error => const Color(0xFFDC2626); // Errors / failures

  /* ───────────────── Transactions ───────────────── */

  @override
  Color get credit => const Color(0xFF15803D); // Money received

  @override
  Color get debit => const Color(0xFFB91C1C); // Money spent

  @override
  Color get neutral => const Color(0xFF6B7280); // Fees / system entries
}
