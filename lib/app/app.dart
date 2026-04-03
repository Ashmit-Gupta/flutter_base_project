import 'package:basic_project_setup/app/theme/dark_theme_builder.dart';
import 'package:basic_project_setup/app/theme/light_theme_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/layout/breakpoints.dart';
import '../core/layout/screen_type_scope.dart';
import '../core/di/core_providers.dart';
import '../features/auth/presentation/providers/auth_session_provider.dart';
import 'app_routes.dart';
import 'observers/app_lifecycle_observer.dart';
import 'theme/theme_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppLifecycleObserver _lifecycleObserver;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final logger = ref.read(appLoggerProvider);
    _lifecycleObserver = AppLifecycleObserver(logger);
    _lifecycleObserver.register();
    _router = AppRouter.createRouter(
      logger,
      () => ref.read(authSessionProvider),
    );
  }

  @override
  void dispose() {
    _lifecycleObserver.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final themeMode = ref.watch(materialThemeModeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      themeMode: themeMode,
      theme: buildLightTheme(
        fontFamily: themeState.fontFamily,
      ),
      darkTheme: buildDarkTheme(
        fontFamily: themeState.fontFamily,
      ),
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;
        final screenType = Breakpoints.resolve(width);
        final textScaler = MediaQuery.textScalerOf(context);
        return ScreenTypeScope(
          screenType: screenType,
          textScaler: textScaler,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
