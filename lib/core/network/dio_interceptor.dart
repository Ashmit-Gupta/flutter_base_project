import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../error/app_exceptions.dart';
import '../../features/auth/constants/auth_constants.dart';
import '../logging/app_logger.dart';

class DioAppInterceptor extends Interceptor {
  final AppLogger logger;
  late final Future<SharedPreferences> _prefsFuture;

  DioAppInterceptor(this.logger) {
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final redactedHeaders = Map<String, dynamic>.from(options.headers);
    if (redactedHeaders.containsKey('Authorization')) {
      redactedHeaders['Authorization'] = 'Bearer ***';
    }

    logger.debug('➡️ ${options.method} ${options.uri}\n'
        'headers: ${_pretty(redactedHeaders)}\n'
        'query: ${_pretty(options.queryParameters)}\n'
        'body: ${_pretty(options.data)}');

    final prefs = await _prefsFuture;
    final token = prefs.getString(AuthConstants.tokenKey);

    // Only attach bearer token when we actually have one.
    final headers = options.headers;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers.remove('Authorization');
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    logger.debug('⬅️ ${response.statusCode} ${response.requestOptions.uri}\n'
        'response: ${_pretty(response.data)}');

    handler.next(response);
  }

  @override
  void onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) {
    final status = err.response?.statusCode;
    final data = err.response?.data;
    logger.error(
      '❌ ${err.requestOptions.uri}'
      '${status != null ? ' (HTTP $status)' : ''}\n'
      'response: ${_pretty(data)}',
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
        final apiMessage = _extractApiMessage(err.response?.data);

        if (status == 401) {
          return UnauthorizedException(
            apiMessage ?? 'Unauthorized',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 403) {
          return ForbiddenException(
            apiMessage ?? 'Forbidden',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 404) {
          return NotFoundException(
            apiMessage ?? 'Not found',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status == 429) {
          return RateLimitException(
            apiMessage ?? 'Too many requests',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        if (status != null && status >= 500) {
          return ServerException(
            apiMessage ?? 'Server error',
            cause: err,
            stackTrace: err.stackTrace,
          );
        }

        return StatusException(
          apiMessage ?? 'Request failed',
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

String? _extractApiMessage(Object? data) {
  if (data is Map) {
    final message = data['message'];
    if (message is String) {
      final trimmed = message.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

String _pretty(Object? value) {
  if (value == null) return 'null';

  // Truncate huge payloads to avoid flooding logs/snackbars.
  const maxLen = 3000;

  try {
    if (value is Map || value is List) {
      final encoded = const JsonEncoder.withIndent('  ').convert(value);
      return encoded.length > maxLen
          ? '${encoded.substring(0, maxLen)}…(truncated)'
          : encoded;
    }
  } catch (_) {
    // fall through
  }

  final s = value.toString();
  return s.length > maxLen ? '${s.substring(0, maxLen)}…(truncated)' : s;
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
