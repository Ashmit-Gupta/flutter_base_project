import 'package:flutter/foundation.dart';

import '../../core/logging/app_logger.dart';
import '../../core/di/di.dart';

void registerGlobalErrorObserver() {
  FlutterError.onError = (details) {
    getIt<AppLogger>().error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
}
