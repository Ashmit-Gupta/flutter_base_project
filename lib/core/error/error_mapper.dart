
import 'app_exceptions.dart';
import 'app_failure.dart';

Failure mapExceptionToFailure(Object exception) {
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
  return UnexpectedFailure('Unexpected error: $exception');
}

extension AppExceptionX on Object {
  Failure toFailure() => mapExceptionToFailure(this);
}