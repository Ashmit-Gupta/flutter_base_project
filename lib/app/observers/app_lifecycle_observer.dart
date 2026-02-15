import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';
import '../../core/di/di.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  final AppLogger _logger = getIt<AppLogger>();

  void register() {
    WidgetsBinding.instance.addObserver(this);
  }

  void unregister() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info('App lifecycle changed: $state');
  }
}
