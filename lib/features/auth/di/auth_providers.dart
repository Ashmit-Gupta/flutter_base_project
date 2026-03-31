import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/data_source/local_data_source/auth_local_data_source.dart';
import '../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../data/repo/auth_repo.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(appStorageProvider);
  return AuthLocalDataSource(storage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(appLoggerProvider);
  return AuthRemoteDataSource(dio: dio, logger: logger);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final local = ref.watch(authLocalDataSourceProvider);
  return AuthRepository(remote, local);
});
