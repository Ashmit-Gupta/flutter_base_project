import 'package:flutter/foundation.dart';

import '../../core/logging/app_logger.dart';

void registerGlobalErrorObserver(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
}
