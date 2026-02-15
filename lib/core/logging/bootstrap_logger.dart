import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error, fatal }

class BootstrapLogger {
  const BootstrapLogger();

  void log(
      String message, {
        LogLevel level = LogLevel.info,
        Object? error,
        StackTrace? stackTrace,
      }) {
    final buffer = StringBuffer()
      ..write('[BOOTSTRAP][${level.name.toUpperCase()}] ')
      ..write(message);

    if (error != null) {
      buffer.write(' | error: $error');
    }

    debugPrint(buffer.toString());

    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  void fatal(
      String message, {
        Object? error,
        StackTrace? stackTrace,
      }) {
    log(
      message,
      level: LogLevel.fatal,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

const bootstrapLogger = BootstrapLogger();
