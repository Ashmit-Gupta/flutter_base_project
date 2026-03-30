import 'dart:ui';
import 'app_colors.dart';

/// Light theme color implementation for OneAttendance.
///
/// Design principles:
/// - Indigo  = authority, admin, corporate trust
/// - Teal    = biometric scanning, verification, technology
/// - Green   = present, success, checked-in
/// - Red     = absent, failed scan, error
/// - Amber   = late arrival, pending review
/// - Violet  = on leave, approved time off
/// - Cool slate grays = clean tablet readability in bright offices
class LightAppColors implements AppColors {
  /* ───────────────── Brand ───────────────── */

  @override
  Color get primary => const Color(0xFF4338CA); // Indigo 700 — admin authority

  @override
  Color get primaryDark => const Color(0xFF3730A3); // Indigo 800 — pressed state

  @override
  Color get primaryLight => const Color(0xFFEEF2FF); // Indigo 50 — containers & tints

  @override
  Color get onPrimary => const Color(0xFFFFFFFF); // White — text on indigo

  @override
  Color get secondary => const Color(0xFF0D9488); // Teal 600 — scan ring / verify

  @override
  Color get onSecondary => const Color(0xFFFFFFFF); // White — text on teal

  /* ───────────────── Backgrounds ───────────────── */

  @override
  Color get background => const Color(0xFFF1F5F9); // Slate 100 — tablet idle screen

  @override
  Color get surface => const Color(0xFFFFFFFF); // White — cards, dialogs, sheets

  @override
  Color get surfaceElevated => const Color(0xFFF8FAFC); // Slate 50 — nested containers

  @override
  Color get border => const Color(0xFFE2E8F0); // Slate 200 — dividers, input borders

  /* ───────────────── Text ───────────────── */

  @override
  Color get textPrimary => const Color(0xFF0F172A); // Slate 900 — names, headings

  @override
  Color get textSecondary => const Color(0xFF475569); // Slate 600 — timestamps, roles

  @override
  Color get textMuted => const Color(0xFF94A3B8); // Slate 400 — hints, placeholders

  /* ───────────────── Status ───────────────── */

  @override
  Color get success => const Color(0xFF16A34A); // Green 600 — verified, onboarded

  @override
  Color get warning => const Color(0xFFD97706); // Amber 600 — late, pending review

  @override
  Color get error => const Color(0xFFDC2626); // Red 600 — scan fail, absent

  /* ───────────────── Attendance Semantics ───────────────── */

  @override
  Color get present => const Color(0xFF15803D); // Green 700 — checked in ✅

  @override
  Color get absent => const Color(0xFFB91C1C); // Red 700 — did not check in ❌

  @override
  Color get late => const Color(0xFFB45309); // Amber 700 — late arrival 🕐

  @override
  Color get onLeave => const Color(0xFF6D28D9); // Violet 700 — approved leave 🏖️

  /* ───────────────── Role & Access ───────────────── */

  @override
  Color get adminAccent => const Color(0xFF4338CA); // Indigo — admin badge

  @override
  Color get employeeAccent => const Color(0xFF0369A1); // Sky 700 — employee badge
}