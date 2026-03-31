/// SharedPreferences keys and other auth-layer constants.
class AuthConstants {
  /// Stored access token returned by the login API.
  static const String tokenKey = 'authToken';

  /// Stored organization id returned by the login API.
  static const String orgIdKey = 'orgId';

  /// Email used at sign-in (for display and profile; not returned by login API body).
  static const String userEmailKey = 'userEmail';
}

