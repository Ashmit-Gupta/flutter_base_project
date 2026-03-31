import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  final AppLogger _logger;

  AppLifecycleObserver(this._logger);

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
