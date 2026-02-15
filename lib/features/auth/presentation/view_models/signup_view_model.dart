/// ViewModel for signup form.
///
/// Holds validation and submit logic. No UI dependencies.
/// Screens pass form values and handle success/failure (snackbar, navigation).
class SignupViewModel {
  SignupViewModel();

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

  /// Submits signup form. Returns true if valid and "successful".
  ///
  /// In a real app, this would call a repository/API. For now, it only
  /// validates and returns true when valid.
  Future<bool> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (validateName(name) != null ||
        validateEmail(email) != null ||
        validatePassword(password) != null) {
      return false;
    }
    // Placeholder: would call auth repository
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
