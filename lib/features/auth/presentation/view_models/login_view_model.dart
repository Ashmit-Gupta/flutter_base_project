import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:basic_project_setup/features/auth/presentation/providers/auth_session_provider.dart';
import 'login_form_state.dart';

/// Login form ViewModel — UI state + event handlers.
///
/// Uses [Notifier] with [LoginFormState]. State is UI-driven.
/// Async work is an implementation detail; only state transitions are emitted.
class LoginViewModel extends Notifier<LoginFormState> {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  /// Validates Email field. Returns error message or null if valid.
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
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
    required String email,
    required String password,
  }) {
    if (state.isSubmitting) return;
    if (validateEmail(email) != null || validatePassword(password) != null) {
      return;
    }
    state = state.copyWith(status: LoginFormStatus.submitting);
    _performSubmit(email, password);
  }

  Future<void> _performSubmit(String email, String password) async {
    try {
      await ref.read(authSessionProvider.notifier).login(
            email: email.trim(),
            password: password,
          );

      final authState = ref.read(authSessionProvider);
      if (authState.hasError) {
        state = state.copyWith(
          status: LoginFormStatus.failure,
          errorMessage: authState.error.toString(),
        );
        return;
      }

      state = state.copyWith(
        status: LoginFormStatus.success,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: LoginFormStatus.failure,
        errorMessage: 'Something went wrong',
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
