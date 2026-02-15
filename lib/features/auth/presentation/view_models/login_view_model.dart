/// ViewModel for login form.
///
/// Holds validation and submit logic. No UI dependencies.
/// Screens pass form values and handle success/failure (snackbar, navigation).
class LoginViewModel {
  LoginViewModel();

  /// Validates name field. Returns error message or null if valid.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
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

  /// Submits login form. Returns true if valid and "successful".
  ///
  /// In a real app, this would call a repository/API. For now, it only
  /// validates and returns true when valid.
  Future<bool> submit({
    required String name,
    required String password,
  }) async {
    if (validateName(name) != null || validatePassword(password) != null) {
      return false;
    }
    // Placeholder: would call auth repository
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
