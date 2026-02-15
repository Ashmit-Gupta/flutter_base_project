import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_models/login_view_model.dart';
import '../view_models/signup_view_model.dart';

final loginViewModelProvider = Provider<LoginViewModel>((ref) {
  return LoginViewModel();
});

final signupViewModelProvider = Provider<SignupViewModel>((ref) {
  return SignupViewModel();
});
