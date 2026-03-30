// auth_di.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/storage/shared_pref_storage.dart';
import '../data/repo/auth_repo.dart';
import '../data/data_source/remote_data_source/auth_remote_data_source.dart';
import '../data/data_source/local_data_source/auth_local_data_source.dart';

final getIt = GetIt.instance;

void registerAuthFeature() {
  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
          () => AuthLocalDataSource(getIt<AppStorage>()),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        dio: getIt<Dio>(),
        logger: getIt<AppLogger>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        getIt<AuthRemoteDataSource>(),
        getIt<AuthLocalDataSource>(),
      ),
    );
  }
}