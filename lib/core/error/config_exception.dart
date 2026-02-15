import 'package:equatable/equatable.dart';

sealed class BootstrapException extends Equatable implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const BootstrapException(
      this.message, {
        this.cause,
        this.stackTrace,
      });

  @override
  List<Object?> get props => [message, cause, stackTrace];
}


// --- Bootstrap / environment exceptions ---

/// Thrown when the .env file is missing or cannot be loaded during app bootstrap.
class MissingEnvFileException extends BootstrapException {
  final String attemptedPath;

  const MissingEnvFileException(this.attemptedPath, {super.cause, super.stackTrace})
      : super('Environment file not found or could not be loaded: $attemptedPath. '
      'Ensure the file exists and is listed under flutter.assets in pubspec.yaml.');

  @override
  List<Object?> get props => [...super.props, attemptedPath];
}

/// Thrown when a required environment variable is missing or empty.
class MissingEnvVarException extends BootstrapException {
  final String key;
  final List<String>? allMissingKeys;

  MissingEnvVarException(
      this.key, {
        this.allMissingKeys,
        Object? cause,
        StackTrace? stackTrace,
      }) : super(
    _message(key, allMissingKeys),
    cause: cause,
    stackTrace: stackTrace,
  );

  static String _message(String key, List<String>? allMissingKeys) {
    if (allMissingKeys != null && allMissingKeys.isNotEmpty) {
      return 'Missing or empty required env key(s): ${allMissingKeys.join(', ')}';
    }
    return 'Missing or empty required env key: $key';
  }

  @override
  List<Object?> get props => [...super.props, key, allMissingKeys];
}

/// Thrown when a required environment variable is missing or empty.
class UnexpectedConfigException extends BootstrapException {
  const UnexpectedConfigException(
      String message, {
        Object? cause,
        StackTrace? stackTrace,
      }) : super(
    message,
    cause: cause,
    stackTrace: stackTrace,
  );

  /// Convenience factory for truly unknown errors
  factory UnexpectedConfigException.fromError(
      Object error, {
        StackTrace? stackTrace,
      }) {
    return UnexpectedConfigException(
      'Unexpected error occurred during app bootstrap',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}

