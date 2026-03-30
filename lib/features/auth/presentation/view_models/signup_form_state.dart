/// UI state for the signup form.
///
/// Synchronous, deterministic, UI-driven. Exists even if backend is mocked/removed.
enum SignupFormStatus {
  idle,
  submitting,
  success,
  failure,
}

class SignupFormState {
  const SignupFormState({
    this.status = SignupFormStatus.idle,
    this.errorMessage,
  });

  final SignupFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == SignupFormStatus.submitting;
  bool get isSuccess => status == SignupFormStatus.success;
  bool get isFailure => status == SignupFormStatus.failure;
  bool get canSubmit => status != SignupFormStatus.submitting;

  SignupFormState copyWith({
    SignupFormStatus? status,
    String? errorMessage,
  }) {
    return SignupFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
