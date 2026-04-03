import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

/// Provider observer for metrics collection
final class MetricsProviderObserver extends ProviderObserver {
  MetricsProviderObserver(this.logger);

  final AppLogger logger;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final provider = context.provider;
    logger.debug(
      'Provider updated: ${provider.name ?? provider.runtimeType} '
      'previous=${previousValue?.toString()} new=${newValue?.toString()}',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final provider = context.provider;
    logger.debug(
      'Provider disposed: ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final provider = context.provider;
    logger.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
