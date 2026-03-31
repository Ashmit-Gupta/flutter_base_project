import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_admin_pin_form_state.dart';

class EditAdminPinViewModel extends Notifier<EditAdminPinFormState> {
  @override
  EditAdminPinFormState build() {
    return const EditAdminPinFormState();
  }

  void onSubmitPressed({
    required String pin,
    required String confirmPin,
  }) {
    if (state.isSubmitting) return;

    final normalizedPin = pin.trim();
    final normalizedConfirmPin = confirmPin.trim();

    if (normalizedPin.isEmpty || normalizedConfirmPin.isEmpty) {
      state = state.copyWith(
        status: EditAdminPinFormStatus.failure,
        errorMessage: 'Please enter and confirm PIN',
      );
      return;
    }

    if (normalizedPin != normalizedConfirmPin) {
      state = state.copyWith(
        status: EditAdminPinFormStatus.failure,
        errorMessage: 'PIN and confirm PIN must match',
      );
      return;
    }

    state = state.copyWith(
      status: EditAdminPinFormStatus.submitting,
      errorMessage: null,
    );
    _performSubmit();
  }

  Future<void> _performSubmit() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(
      status: EditAdminPinFormStatus.success,
      errorMessage: null,
    );
  }

  void onSuccessHandled() {
    state = state.copyWith(
      status: EditAdminPinFormStatus.idle,
      errorMessage: null,
    );
  }

  void onFailureHandled() {
    state = state.copyWith(
      status: EditAdminPinFormStatus.idle,
      errorMessage: null,
    );
  }
}
