/// UI state for the login form.
///
/// Synchronous, deterministic, UI-driven. Exists even if backend is mocked/removed.
enum LoginFormStatus {
  idle,
  submitting,
  success,
  failure,
}

class LoginFormState {
  const LoginFormState({
    this.status = LoginFormStatus.idle,
    this.errorMessage,
  });

  final LoginFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == LoginFormStatus.submitting;
  bool get isSuccess => status == LoginFormStatus.success;
  bool get isFailure => status == LoginFormStatus.failure;
  bool get canSubmit => status != LoginFormStatus.submitting;

  LoginFormState copyWith({
    LoginFormStatus? status,
    String? errorMessage,
  }) {
    return LoginFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
