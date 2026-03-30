import 'package:dio/dio.dart';

import '../error/app_exceptions.dart';
import '../logging/app_logger.dart';

class DioAppInterceptor extends Interceptor {
  final AppLogger logger;

  DioAppInterceptor(this.logger);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) {
    logger.debug(
      '➡️ ${options.method} ${options.uri}',
    );

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    logger.debug(
      '⬅️ ${response.statusCode} ${response.requestOptions.uri}',
    );

    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    logger.error(
      '❌ ${err.requestOptions.uri}',
      error: err,
      stackTrace: err.stackTrace,
    );

    handler.reject(
      err.copyWith(
        error: _mapDioError(err),
      ),
    );
  }

  AppException _mapDioError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionTimeoutException(
          'Request timed out',
          cause: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection',
          cause: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;

        if (status == 401) {
          return UnauthorizedException(
            'Unauthorized',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 403) {
          return ForbiddenException(
            'Forbidden',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 404) {
          return NotFoundException(
            'Not found',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 429) {
          return RateLimitException(
            'Too many requests',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status != null && status >= 500) {
          return ServerException(
            'Server error',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        return StatusException(
          'Request failed',
          statusCode: status,
          meta: err.response?.data is Map
              ? Map<String, Object?>.from(err.response!.data)
              : null,
          cause: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.cancel:
        return UnexpectedException(
          'Request cancelled',
          cause: err,
          stackTrace: err.stackTrace,
        );

      case DioExceptionType.unknown:
      default:
        return UnexpectedException(
          'Unexpected network error',
          cause: err,
          stackTrace: err.stackTrace,
        );
    }
  }
}

extension DioX on Dio {
  Future<Response<T>> getRequest<T>(
      String path, {
        Map<String, dynamic>? query,
      }) =>
      get<T>(path, queryParameters: query);

  Future<Response<T>> postRequest<T>(
      String path, {
        Object? body,
      }) =>
      post<T>(path, data: body);

  Future<Response<T>> putRequest<T>(
      String path, {
        Object? body,
      }) =>
      put<T>(path, data: body);

  Future<Response<T>> patchRequest<T>(
      String path, {
        Object? body,
      }) =>
      patch<T>(path, data: body);

  Future<Response<T>> deleteRequest<T>(
      String path, {
        Object? body,
      }) =>
      delete<T>(path, data: body);
}
