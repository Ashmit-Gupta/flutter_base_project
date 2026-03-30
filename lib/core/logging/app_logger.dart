import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class AppLogger {
  final bool enableLogging;
  late final Logger _logger;

  AppLogger({
    required this.enableLogging,
  }) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 12,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
      output: _FlutterOutput(),
    );
  }

  void log(
      String message, {
        LogLevel level = LogLevel.info,
        Object? error,
        StackTrace? stackTrace,
      }) {
    if (!enableLogging) return;

    final msg = message;
    switch (level) {
      case LogLevel.debug:
        _logger.d(msg);
        break;
      case LogLevel.info:
        _logger.i(msg);
        break;
      case LogLevel.warning:
        _logger.w(msg);
        break;
      case LogLevel.error:
        _logger.e(msg, error: error, stackTrace: stackTrace);
        break;
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

class _FlutterOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}
