import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import '../network/dio_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI(AppConfig config) async {
  if (getIt.isRegistered<AppConfig>()) return;

  // 1️⃣ AppConfig (read-only, foundational)
  getIt.registerSingleton<AppConfig>(config);

  // 2️⃣ Logger (needed by networking)
  getIt.registerSingleton<AppLogger>(
    AppLogger(enableLogging: config.enableLogging),
  );

  // 3️⃣ Dio (SINGLE instance, via DioClient)
  final dioClient = DioClient(
    config,
    getIt<AppLogger>(),
  );

  getIt.registerSingleton<Dio>(dioClient.dio);

  // 4️⃣ Core / feature registrations come AFTER this
  // getIt.registerLazySingleton<AuthApi>(
  //   () => AuthApi(getIt<Dio>()),
  // );
}
