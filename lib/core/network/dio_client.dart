import 'package:dio/dio.dart';

import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import 'dio_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient(
      AppConfig config,
      AppLogger logger,
      ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      DioAppInterceptor(logger),
    ]);

    return DioClient._(dio);
  }
}
