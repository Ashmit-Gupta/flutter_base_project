import 'package:equatable/equatable.dart';

/// Domain-level failures (what the Repo returns to the UI/VM).
/// These should be presentation-friendly and contain only what the UI needs.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ---- Network / Transport ----
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// ---- HTTP / Status ----
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}

class RateLimitFailure extends Failure {
  final Duration? retryAfter;

  const RateLimitFailure(super.message, {this.retryAfter});
}

// ---- Request / Body ----
class ValidationFailure extends Failure {
  final Map<String, dynamic>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors});
}

// ---- Parsing / Business status ----
class ParsingFailure extends Failure {
  const ParsingFailure(super.message);
}

class StatusFailure extends Failure {
  final int? statusCode;
  final Map<String, Object?>? meta;

  const StatusFailure(super.message, {this.statusCode, this.meta});
}

// ---- Local storage ----
class CacheFailure extends Failure {
  const  CacheFailure(super.message);
}

// ---- Catch-all ----
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}