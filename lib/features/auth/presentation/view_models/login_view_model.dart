import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'login_form_state.dart';

/// Login form ViewModel — UI state + event handlers.
///
/// Uses [Notifier] with [LoginFormState]. State is UI-driven.
/// Async work is an implementation detail; only state transitions are emitted.
class LoginViewModel extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  /// Validates name field. Returns error message or null if valid.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  /// Validates password field. Returns error message or null if valid.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// Event: user pressed submit. Triggers async work; emits state transitions.
  ///
  /// UI must NOT await this. UI watches state and reacts to success/failure.
  void onSubmitPressed({
    required String name,
    required String password,
  }) {
    if (validateName(name) != null || validatePassword(password) != null) {
      return;
    }
    state = state.copyWith(status: LoginFormStatus.submitting);
    _performSubmit(name, password);
  }

  Future<void> _performSubmit(String name, String password) async {
    try {
      if (state.isSubmitting) return;
      // Placeholder: would call auth repository
      await Future<void>.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(status: LoginFormStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: LoginFormStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Event: UI has handled success (e.g. shown snackbar). Resets to idle.
  void onSuccessHandled() {
    state = state.copyWith(status: LoginFormStatus.idle, errorMessage: null);
  }

  /// Event: UI has handled failure. Resets to idle.
  void onFailureHandled() {
    state = state.copyWith(status: LoginFormStatus.idle, errorMessage: null);
  }
}
