import 'dart:ui';
import 'app_colors.dart';

/// Dark theme color implementation for OneAttendance.
///
/// Dark theme principles:
/// - Deep navy backgrounds   → reduce glare on tablet in dim office lobbies
/// - Soft indigo / violet    → brand stays vivid without being harsh
/// - Teal glow               → biometric scan ring pulse feel
/// - Status colors softened  → readable without being aggressive on dark
/// - Attendance semantics preserved — green / red / amber / violet contrast retained
class DarkAppColors implements AppColors {
  /* ───────────────── Brand ───────────────── */

  @override
  Color get primary => const Color(0xFF818CF8); // Indigo 400 — readable on dark

  @override
  Color get primaryDark => const Color(0xFF6366F1); // Indigo 500 — pressed / active

  @override
  Color get primaryLight => const Color(0xFF1E1B4B); // Indigo 950 — deep container tint

  @override
  Color get onPrimary => const Color(0xFFF8FAFC); // Slate 50 — content on indigo

  @override
  Color get secondary => const Color(0xFF2DD4BF); // Teal 400 — scan ring glow

  @override
  Color get onSecondary => const Color(0xFF042F2E); // Teal 950 — content on teal

  /* ───────────────── Backgrounds ───────────────── */

  @override
  Color get background => const Color(0xFF0B1120); // Near-black navy — idle screen

  @override
  Color get surface => const Color(0xFF131E30); // Dark navy — cards, sheets, dialogs

  @override
  Color get surfaceElevated => const Color(0xFF1A2740); // Lighter navy — nested containers

  @override
  Color get border => const Color(0xFF1E293B); // Slate 800 — subtle dividers

  /* ───────────────── Text ───────────────── */

  @override
  Color get textPrimary => const Color(0xFFF1F5F9); // Slate 100 — names, headings

  @override
  Color get textSecondary => const Color(0xFFCBD5E1); // Slate 300 — timestamps, roles

  @override
  Color get textMuted => const Color(0xFF64748B); // Slate 500 — hints, disabled

  /* ───────────────── Status ───────────────── */

  @override
  Color get success => const Color(0xFF4ADE80); // Green 400 — verified, onboarded

  @override
  Color get warning => const Color(0xFFFBBF24); // Amber 400 — late, pending review

  @override
  Color get error => const Color(0xFFF87171); // Red 400 — scan fail, absent

  /* ───────────────── Attendance Semantics ───────────────── */

  @override
  Color get present => const Color(0xFF4ADE80); // Green 400 — checked in ✅

  @override
  Color get absent => const Color(0xFFF87171); // Red 400 — did not check in ❌

  @override
  Color get late => const Color(0xFFFBBF24); // Amber 400 — late arrival 🕐

  @override
  Color get onLeave => const Color(0xFFA78BFA); // Violet 400 — approved leave 🏖️

  /* ───────────────── Role & Access ───────────────── */

  @override
  Color get adminAccent => const Color(0xFF818CF8); // Indigo 400 — admin badge

  @override
  Color get employeeAccent => const Color(0xFF38BDF8); // Sky 400 — employee badge
}