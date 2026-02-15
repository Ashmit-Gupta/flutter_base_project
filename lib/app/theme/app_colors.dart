import 'package:flutter/material.dart';

/// Contract for all app colors.
///
/// ❌ Widgets must NEVER use [Color] directly.
/// ✅ Widgets must ONLY depend on [AppColors].
///
/// This enables:
/// - Centralized theming
/// - Light / Dark mode
/// - Brand refresh without refactors
/// - Backend / remote theming
/// - Consistent UX across features
abstract class AppColors {
  /* ───────────────── Brand Colors ───────────────── */

  /// Primary brand color.
  ///
  /// Usage:
  /// - Primary CTA buttons (Redeem, Transfer, Pay)
  /// - Active navigation items
  /// - QR code highlights
  /// - Success emphasis
  Color get primary;

  /// Darker shade of primary color.
  ///
  /// Usage:
  /// - Pressed button states
  /// - Active icons
  /// - Emphasized UI elements
  Color get primaryDark;

  /// Light tint of primary color.
  ///
  /// Usage:
  /// - Button backgrounds (low emphasis)
  /// - Success containers
  /// - Highlighted cards
  Color get primaryLight;

  /// Content color on primary/error backgrounds.
  ///
  /// Usage:
  /// - Primary button label
  /// - Danger button label
  /// - Icons on filled CTAs
  Color get onPrimary;

  /// Secondary color for trust & finance.
  ///
  /// Usage:
  /// - Wallet balance
  /// - Links
  /// - Informational UI
  /// - Transfers
  Color get secondary;

  /* ───────────────── Backgrounds ───────────────── */

  /// Main app background color.
  ///
  /// Usage:
  /// - Scaffold background
  /// - Page backgrounds
  Color get background;

  /// Card / surface background.
  ///
  /// Usage:
  /// - Cards
  /// - Bottom sheets
  /// - Dialogs
  Color get surface;

  /// Divider & border color.
  ///
  /// Usage:
  /// - List separators
  /// - Input borders
  /// - Card outlines
  Color get border;

  /* ───────────────── Text Colors ───────────────── */

  /// Primary text color.
  ///
  /// Usage:
  /// - Headings
  /// - Important values
  Color get textPrimary;

  /// Secondary text color.
  ///
  /// Usage:
  /// - Body text
  /// - Labels
  /// - Descriptions
  Color get textSecondary;

  /// Muted / disabled text color.
  ///
  /// Usage:
  /// - Placeholders
  /// - Disabled buttons
  /// - Hint text
  Color get textMuted;

  /* ───────────────── Status Colors ───────────────── */

  /// Success color.
  ///
  /// Usage:
  /// - Successful redemption
  /// - Active coupons
  /// - Positive confirmations
  Color get success;

  /// Warning color.
  ///
  /// Usage:
  /// - Pending actions
  /// - Low balance
  /// - Attention required
  Color get warning;

  /// Error color.
  ///
  /// Usage:
  /// - Failed transactions
  /// - Expired coupons
  /// - Validation errors
  Color get error;

  /* ───────────────── Transaction Semantics ───────────────── */

  /// Credit color (money received).
  ///
  /// Usage:
  /// - Incoming transfers
  /// - Coupon allocations
  Color get credit;

  /// Debit color (money spent).
  ///
  /// Usage:
  /// - Fuel redemption
  /// - Purchases
  Color get debit;

  /// Neutral transaction color.
  ///
  /// Usage:
  /// - Fees
  /// - System adjustments
  Color get neutral;
}
