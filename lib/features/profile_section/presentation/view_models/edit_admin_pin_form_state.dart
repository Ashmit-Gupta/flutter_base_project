enum EditAdminPinFormStatus {
  idle,
  submitting,
  success,
  failure,
}

class EditAdminPinFormState {
  const EditAdminPinFormState({
    this.status = EditAdminPinFormStatus.idle,
    this.errorMessage,
  });

  final EditAdminPinFormStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == EditAdminPinFormStatus.submitting;
  bool get isSuccess => status == EditAdminPinFormStatus.success;
  bool get isFailure => status == EditAdminPinFormStatus.failure;

  EditAdminPinFormState copyWith({
    EditAdminPinFormStatus? status,
    String? errorMessage,
  }) {
    return EditAdminPinFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
