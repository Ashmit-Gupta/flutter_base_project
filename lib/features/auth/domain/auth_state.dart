sealed class AuthState {
  const AuthState();
}

final class AuthChecking extends AuthState {
  const AuthChecking();
}

final class Authenticated extends AuthState {
  final String email;

  const Authenticated({required this.email});
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}
