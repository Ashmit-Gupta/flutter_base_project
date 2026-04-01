import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../pin/data/data_source/pin_local_data_source.dart';
import '../pin/data/repo_impl/pin_repo_impl.dart';
import '../pin/domain/repo_contract/pin_repo.dart';
import '../pin/domain/usecases/set_pin_usecase.dart';
import '../pin/domain/usecases/update_pin_usecase.dart';
import '../pin/domain/usecases/verify_pin_usecase.dart';

final pinLocalDataSourceProvider = Provider<PinLocalDataSource>((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return PinLocalDataSourceImpl(secureStorageService);
});

final pinRepositoryProvider = Provider<PinRepositoryContract>((ref) {
  final local = ref.watch(pinLocalDataSourceProvider);
  final hasher = ref.watch(pinHasherProvider);
  return PinRepositoryImpl(local: local, hasher: hasher);
});

final setPinUseCaseProvider = Provider<SetPinUseCase>((ref) {
  final repo = ref.watch(pinRepositoryProvider);
  return SetPinUseCase(repo);
});

final verifyPinUseCaseProvider = Provider<VerifyPinUseCase>((ref) {
  final repo = ref.watch(pinRepositoryProvider);
  return VerifyPinUseCase(repo);
});

final updatePinUseCaseProvider = Provider<UpdatePinUseCase>((ref) {
  final repo = ref.watch(pinRepositoryProvider);
  return UpdatePinUseCase(repo);
});
