import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/edit_admin_pin_form_state.dart';
import '../view_models/edit_admin_pin_view_model.dart';
import '../view_models/pin_setup_viewmodel.dart';

final editAdminPinViewModelProvider =
    NotifierProvider<EditAdminPinViewModel, EditAdminPinFormState>(
  EditAdminPinViewModel.new,
);

final pinSetupProvider =
NotifierProvider<PinSetupViewModel, PinSetupState>(
  PinSetupViewModel.new,
);