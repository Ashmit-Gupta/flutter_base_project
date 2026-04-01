import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/auth_providers.dart';
import '../../domain/auth_state.dart';

final authSessionProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.getToken();
    if (token == null || token.trim().isEmpty) {
      return const Unauthenticated();
    }

    final email = await repo.getUserEmail();
    return Authenticated(email: email ?? '');
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password).run();
    result.match(
      (failure) {
        state = AsyncError<AuthState>(
          Exception(failure.message),
          StackTrace.current,
        );
      },
      (_) {
        state = AsyncData<AuthState>(
          Authenticated(email: email.trim()),
        );
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData<AuthState>(Unauthenticated());
  }

  Future<void> updateEmail(String email) async {
    await ref.read(authRepositoryProvider).updateUserEmail(email.trim());
    final current = state;
    if (current is AsyncData<AuthState> && current.value is Authenticated) {
      state = AsyncData<AuthState>(Authenticated(email: email.trim()));
    }
  }
}
