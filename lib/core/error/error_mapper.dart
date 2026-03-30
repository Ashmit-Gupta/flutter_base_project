
import 'package:dio/dio.dart';

import 'app_exceptions.dart';
import 'app_failure.dart';

Failure mapExceptionToFailure(Object exception) {
  // If the data-source throws DioException, try to extract the mapped AppException
  // (set by Dio interceptor), otherwise map it to a short friendly Failure.
  if (exception is DioException) {
    final inner = exception.error;
    if (inner is AppException) {
      return mapExceptionToFailure(inner);
    }

    final status = exception.response?.statusCode;
    if (status == 401) return const UnauthorizedFailure('Unauthorized');
    if (status == 403) return const ForbiddenFailure('Forbidden');
    if (status == 404) return const NotFoundFailure('Not found');
    if (status == 429) return const RateLimitFailure('Too many requests');
    if (status != null && status >= 500) {
      return const ServerFailure('Server error');
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('Request timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');
      case DioExceptionType.badResponse:
        return StatusFailure('Request failed', statusCode: status);
      case DioExceptionType.cancel:
        return const UnexpectedFailure('Request cancelled');
      case DioExceptionType.unknown:
      default:
        return const UnexpectedFailure('Unexpected network error');
    }
  }

  if (exception is AppException) {
    return switch (exception) {
      NetworkException _ => NetworkFailure(exception.message),
      ServerException _ => ServerFailure(exception.message),
      NotFoundException _ => NotFoundFailure(exception.message),
      UnauthorizedException _ => UnauthorizedFailure(exception.message),
      ForbiddenException _ => ForbiddenFailure(exception.message),
      ConnectionTimeoutException _ => TimeoutFailure(exception.message),
      RateLimitException re =>
          RateLimitFailure(
            exception.message,
            retryAfter: re.retryAfter,
          ),
      ValidationException ve =>
          ValidationFailure(
            ve.message,
            fieldErrors: ve.fieldErrors,
          ),
      ParsingException _ => ParsingFailure(exception.message),
      StatusException se =>
          StatusFailure(
            exception.message,
            statusCode: se.statusCode,
            meta: se.meta,
          ),
      CacheException _ => CacheFailure(exception.message),
      UnexpectedException _ => UnexpectedFailure(exception.message),

    };
  }
  return const UnexpectedFailure('Something went wrong');
}

extension AppExceptionX on Object {
  Failure toFailure() => mapExceptionToFailure(this);
}