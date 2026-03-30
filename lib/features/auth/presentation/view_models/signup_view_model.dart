import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'signup_form_state.dart';

/// Signup form ViewModel — UI state + event handlers.
///
/// Uses [Notifier] with [SignupFormState]. State is UI-driven.
/// Async work is an implementation detail; only state transitions are emitted.
class SignupViewModel extends Notifier<SignupFormState> {
  @override
  SignupFormState build() {
    return const SignupFormState();
  }

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates name field. Returns error message or null if valid.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  /// Validates email field. Returns error message or null if valid.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates password field. Returns error message or null if valid.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Event: user pressed submit. Triggers async work; emits state transitions.
  ///
  /// UI must NOT await this. UI watches state and reacts to success/failure.
  void onSubmitPressed({
    required String name,
    required String email,
    required String password,
  }) {
    if (validateName(name) != null ||
        validateEmail(email) != null ||
        validatePassword(password) != null) {
      return;
    }
    state = state.copyWith(status: SignupFormStatus.submitting);
    _performSubmit(name, email, password);
  }

  void _performSubmit(String name, String email, String password) async {
    try {
      // Placeholder: would call auth repository
      await Future<void>.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(status: SignupFormStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: SignupFormStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  /// Event: UI has handled success (e.g. shown snackbar). Resets to idle.
  void onSuccessHandled() {
    state = state.copyWith(status: SignupFormStatus.idle, errorMessage: null);
  }

  /// Event: UI has handled failure. Resets to idle.
  void onFailureHandled() {
    state = state.copyWith(status: SignupFormStatus.idle, errorMessage: null);
  }
}
