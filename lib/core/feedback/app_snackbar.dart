import 'package:flutter/material.dart';

import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../../app/theme/app_snackbar_theme.dart';
import 'app_snackbar_type.dart';

/// Reusable snackbar feedback helper.
///
/// - Uses [AppSnackbarTheme] for all styling — no hard-coded colors or text.
/// - Prevents stacking: clears current snackbar before showing.
/// - Floating at bottom, adapts to light/dark theme.
/// - Duration varies by type (success ~2.5s, warning/error longer).
class AppSnackbar {
  AppSnackbar._();

  /// Shows a snackbar with the given [message] and [type].
  ///
  /// Call from any widget with [BuildContext]. Prevents multiple snackbars
  /// by clearing the current one before showing.
  static void show(
    BuildContext context, {
    required String message,
    required AppSnackbarType type,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final snackbarTheme = theme.extension<AppSnackbarTheme>()!;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: snackbarTheme.contentStyle(theme.textTheme),
        ),
        backgroundColor: snackbarTheme.backgroundColorFor(type),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: durationForType(type)),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  /// Convenience: success (e.g. login, save).
  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.success);
  }

  /// Convenience: warning (e.g. low balance, pending).
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.warning);
  }

  /// Convenience: error (e.g. network failure, validation).
  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.error);
  }

  /// Convenience: info (e.g. tip, status).
  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.info);
  }
}
