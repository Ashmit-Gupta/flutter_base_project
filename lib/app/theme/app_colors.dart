import 'package:flutter/material.dart';

/// Contract for all app colors in OneAttendance.
///
/// ❌ Widgets must NEVER use [Color] directly.
/// ✅ Widgets must ONLY depend on [AppColors].
///
/// This enables:
/// - Centralized theming
/// - Light / Dark mode switching
/// - Brand refresh without widget refactors
/// - Remote / backend theming support
/// - Consistent UX across admin & employee flows
abstract class AppColors {
  /* ───────────────── Brand Colors ───────────────── */

  /// Primary brand color (Indigo).
  ///
  /// Usage:
  /// - Admin CTA buttons (Add Employee, Export, Save)
  /// - Active navigation / bottom bar items
  /// - Selected states & focus rings
  /// - Primary action emphasis
  Color get primary;

  /// Darker shade of primary — pressed & emphasized states.
  ///
  /// Usage:
  /// - Button press/ripple target color
  /// - Active icon fills
  /// - Emphasized headers or banners
  Color get primaryDark;

  /// Light tint of primary — low-emphasis containers.
  ///
  /// Usage:
  /// - Admin badge backgrounds
  /// - Role pill containers
  /// - Highlighted filter chips
  /// - Selected row tint in data tables
  Color get primaryLight;

  /// Content color rendered on primary-colored surfaces.
  ///
  /// Usage:
  /// - Label text on filled indigo buttons
  /// - Icons inside primary FABs
  /// - Text on admin header bars
  Color get onPrimary;

  /// Secondary brand color (Teal) — biometric & tech feel.
  ///
  /// Usage:
  /// - Face scan ring / pulse animation
  /// - Verification checkmarks
  /// - Camera overlay guides
  /// - "Scan Now" CTA variant
  Color get secondary;

  /// Content color rendered on secondary-colored surfaces.
  ///
  /// Usage:
  /// - Icons/labels on teal-filled chips or badges
  /// - Text inside scan confirmation overlays
  Color get onSecondary;

  /* ───────────────── Backgrounds ───────────────── */

  /// Main app / scaffold background.
  ///
  /// Usage:
  /// - Scaffold background color
  /// - Tablet idle screen background
  /// - Page root backgrounds
  Color get background;

  /// Primary surface color — cards, panels, dialogs.
  ///
  /// Usage:
  /// - Employee profile cards
  /// - Bottom sheets
  /// - Alert dialogs
  /// - Admin dashboard panels
  Color get surface;

  /// Elevated surface — cards on top of other cards.
  ///
  /// Usage:
  /// - Nested containers (stats inside dashboard cards)
  /// - Highlighted rows inside a panel
  /// - Summary chips on overview screens
  Color get surfaceElevated;

  /// Divider & border color.
  ///
  /// Usage:
  /// - List item separators
  /// - Text field borders
  /// - Card outlines
  /// - Section dividers in attendance logs
  Color get border;

  /* ───────────────── Text Colors ───────────────── */

  /// Primary text — highest emphasis.
  ///
  /// Usage:
  /// - Employee names
  /// - Section headings
  /// - Large time displays (check-in clock)
  Color get textPrimary;

  /// Secondary text — medium emphasis.
  ///
  /// Usage:
  /// - Job title / department
  /// - Timestamps & dates
  /// - Table column values
  Color get textSecondary;

  /// Muted / disabled text — lowest emphasis.
  ///
  /// Usage:
  /// - Input placeholder text
  /// - Empty state descriptions
  /// - Disabled button labels
  /// - "No data" indicators
  Color get textMuted;

  /* ───────────────── Status Colors ───────────────── */

  /// Success — positive confirmations.
  ///
  /// Usage:
  /// - Face recognition verified toast
  /// - Employee onboarded successfully
  /// - Export completed
  Color get success;

  /// Warning — requires attention.
  ///
  /// Usage:
  /// - Late check-in badge
  /// - Unreviewed log flag
  /// - Low-recognition-confidence alert
  Color get warning;

  /// Error — failures & rejections.
  ///
  /// Usage:
  /// - Face scan failed
  /// - Unrecognized employee
  /// - Form validation errors
  /// - Absent status indicator
  Color get error;

  /* ───────────────── Attendance Semantics ───────────────── */

  /// Present color — employee successfully checked in.
  ///
  /// Usage:
  /// - "Present" badge / chip
  /// - Check-in confirmation ring
  /// - Attendance log row tint
  /// - Daily summary present count
  Color get present;

  /// Absent color — employee did not check in.
  ///
  /// Usage:
  /// - "Absent" badge / chip
  /// - Missing log row indicator
  /// - Attendance summary absent count
  Color get absent;

  /// Late color — employee checked in after scheduled time.
  ///
  /// Usage:
  /// - "Late" badge / chip
  /// - Late arrival flag in logs
  /// - Attendance summary late count
  Color get late;

  /// On-leave color — approved leave / holiday / day off.
  ///
  /// Usage:
  /// - "On Leave" badge / chip
  /// - Leave calendar day tint
  /// - Approved leave log entries
  Color get onLeave;

  /* ───────────────── Role & Access ───────────────── */

  /// Admin role accent color.
  ///
  /// Usage:
  /// - "Admin" role badge
  /// - Admin-only action buttons
  /// - Admin drawer header accent
  Color get adminAccent;

  /// Employee role accent color.
  ///
  /// Usage:
  /// - "Employee" role badge
  /// - Employee profile avatar ring
  /// - Employee list row accent
  Color get employeeAccent;
}