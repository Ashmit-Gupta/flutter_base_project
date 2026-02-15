/// Semantic types for [AppSnackbar] feedback.
enum AppSnackbarType {
  /// Successful completion (e.g. login, save, redeem).
  success,

  /// Non-blocking attention (e.g. low balance, pending action).
  warning,

  /// Failure or validation error (e.g. network error, invalid input).
  error,

  /// Informational (e.g. tip, status update).
  info,
}
