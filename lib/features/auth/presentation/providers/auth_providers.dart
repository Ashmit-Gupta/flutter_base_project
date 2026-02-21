import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_models/login_form_state.dart';
import '../view_models/login_view_model.dart';
import '../view_models/signup_form_state.dart';
import '../view_models/signup_view_model.dart';

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginFormState>(LoginViewModel.new);

final signupViewModelProvider =
    NotifierProvider<SignupViewModel, SignupFormState>(SignupViewModel.new);

