import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import '../network/dio_client.dart';
import '../storage/shared_pref_storage.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI(AppConfig config) async {
  if (getIt.isRegistered<AppConfig>()) return;

  _registerConfig(config);
  _registerLogging(config);
  _registerNetwork(config);
  await _registerStorage();

  // Features should be initialized outside (important)
}


void _registerConfig(AppConfig config) {
  getIt.registerSingleton<AppConfig>(config);
}


void _registerLogging(AppConfig config) {
  getIt.registerSingleton<AppLogger>(
    AppLogger(enableLogging: config.enableLogging),
  );
}

void _registerNetwork(AppConfig config) {
  getIt.registerLazySingleton<DioClient>(
        () => DioClient(
      config,
      getIt<AppLogger>(),
    ),
  );

  getIt.registerLazySingleton<Dio>(
        () => getIt<DioClient>().dio,
  );
}

Future<void> _registerStorage() async {
  final prefs = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<AppStorage>(
        () => AppStorage(getIt<SharedPreferences>()),
  );
}