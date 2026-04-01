import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../security/di/security_providers.dart';

enum PinSetupStatus {
  loading,
  hasPin,
  noPin,
}

class PinSetupState {
  final PinSetupStatus status;

  const PinSetupState({this.status = PinSetupStatus.loading});

  PinSetupState copyWith({PinSetupStatus? status}) {
    return PinSetupState(
      status: status ?? this.status,
    );
  }
}


class PinSetupViewModel extends Notifier<PinSetupState> {
  Future<void>? _initFuture;

  @override
  PinSetupState build() {
    _initFuture ??= _init();

    return const PinSetupState();
  }

  Future<void> _init() async {
    final hasPin = await ref.read(pinRepositoryProvider).hasPin();
    if (hasPin) {
      state = state.copyWith(status: PinSetupStatus.hasPin);
    } else {
      state = state.copyWith(status: PinSetupStatus.noPin);
    }
  }
}