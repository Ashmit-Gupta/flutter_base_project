import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  final bool enableLogging;

  const AppLogger({
    required this.enableLogging,
  });

  void log(
      String message, {
        LogLevel level = LogLevel.info,
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (!enableLogging) return;

    final buffer = StringBuffer()
      ..write('[${level.name.toUpperCase()}] ')
      ..write(message);

    if (error != null) {
      buffer.write(' | error: $error');
    }

    debugPrint(buffer.toString());

    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  void debug(String message) => log(message, level: LogLevel.debug);

  void info(String message) => log(message, level: LogLevel.info);

  void warning(String message) => log(message, level: LogLevel.warning);

  void error(
      String message, {
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(
      message,
      level: LogLevel.error,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
