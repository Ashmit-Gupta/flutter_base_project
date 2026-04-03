import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/edit_admin_pin_form_state.dart';
import '../view_models/edit_admin_pin_view_model.dart';

final editAdminPinViewModelProvider =
    NotifierProvider<EditAdminPinViewModel, EditAdminPinFormState>(
  EditAdminPinViewModel.new,
);

