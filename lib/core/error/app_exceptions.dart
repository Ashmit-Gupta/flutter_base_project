import 'package:equatable/equatable.dart';

/// Base exception for the data layer (DataSource, API, decoding).
/// Throw these from DS; the repo will catch and convert to Failures.
sealed class AppException extends Equatable implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  List<Object?> get props => [message, cause, stackTrace];

  @override
  String toString() => '$runtimeType: $message';
}

/// Server returned a 5xx or similar server-side problem.
class ServerException extends AppException {
  const ServerException(super.message, {super.cause, super.stackTrace});
}

/// Device/network connectivity or client transport failure (DNS, socket, etc.)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

/// Resource not found (HTTP 404 or equivalent).
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause, super.stackTrace});
}

/// Unauthorized (HTTP 401). Often triggers token refresh or logout.
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.cause, super.stackTrace});
}

/// Forbidden (HTTP 403). Authenticated but not allowed.
class ForbiddenException extends AppException {
  const ForbiddenException(super.message, {super.cause, super.stackTrace});
}

/// Request timed out (client-side or gateway timeout).
class ConnectionTimeoutException extends AppException {
  const ConnectionTimeoutException(super.message, {super.cause, super.stackTrace});
}

/// Rate-limited (HTTP 429) or similar throttling.
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException(super.message, {
    this.retryAfter,
    super.cause,
    super.stackTrace,
  });
}

/// Request payload or query rejected (HTTP 400 / 422 etc.)
class ValidationException extends AppException {
  final Map<String, dynamic>? fieldErrors;

  const ValidationException(super.message, {
    this.fieldErrors,
    super.cause,
    super.stackTrace,
  });
}

/// We got a 2xx-ish response but parsing/decoding failed.
class ParsingException extends AppException {
  final String source;
  final Object? rawData;

  const ParsingException(
      super.message, {
        required this.source,
        this.rawData,
        super.cause,
        super.stackTrace,
      });

  @override
  List<Object?> get props => [
    ...super.props,
    source,
    rawData,
  ];
}



/// Non-2xx “business failure” indicated in body (e.g. success:false).
class StatusException extends AppException {
  final int? statusCode;
  final Map<String, Object?>? meta;

  const StatusException(super.message, {
    this.statusCode,
    this.meta,
    super.cause,
    super.stackTrace,
  });
}

/// Local cache/storage issue (Hive/Isar/SharedParefs).
class CacheException extends AppException {
  const CacheException(super.message, {super.cause, super.stackTrace});
}

/// Fallback for anything unexpected that we didn’t categorize.
class UnexpectedException extends AppException {
  const UnexpectedException(super.message, {super.cause, super.stackTrace});
}
