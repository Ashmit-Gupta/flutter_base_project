import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import 'dio_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient._(this.dio);

  factory DioClient(
      AppConfig config,
      AppLogger logger,
      Future<String?> Function() readToken,
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
      DioAppInterceptor(logger, readToken: readToken),
    ]);

    // Dev-only: allow self-signed / invalid certificates (common on local envs).
    // Prod: keep default certificate validation.
    if (config.environment == AppEnvironment.dev &&
        dio.httpClientAdapter is IOHttpClientAdapter) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }
    return DioClient._(dio);
  }
}
