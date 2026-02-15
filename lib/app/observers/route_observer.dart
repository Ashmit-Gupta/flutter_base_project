import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';
import '../../core/di/di.dart';

class AppRouteObserver extends NavigatorObserver {
  final AppLogger _logger = getIt<AppLogger>();

  @override
  void didPush(Route route, Route? previousRoute) {
    _logger.info(
      'Route pushed: ${route.settings.name}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _logger.info(
      'Route popped: ${route.settings.name}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _logger.info(
      'Route replaced: ${oldRoute?.settings.name} → ${newRoute?.settings.name}',
    );
  }
}
