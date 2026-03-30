import 'package:basic_project_setup/app/theme/dark_theme_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_routes.dart';
import 'observers/app_lifecycle_observer.dart';
import 'theme/theme_provider.dart';
import 'theme/light_theme_builder.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final _lifecycleObserver = AppLifecycleObserver();

  @override
  void initState() {
    super.initState();
    _lifecycleObserver.register();
  }

  @override
  void dispose() {
    _lifecycleObserver.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouter.createRouter();

    final themeState = ref.watch(themeProvider);
    final themeMode = ref.watch(materialThemeModeProvider);

    return MaterialApp.router(
      routerConfig: router,
      themeMode: themeMode,
      theme: buildLightTheme(
        fontFamily: themeState.fontFamily,
      ),
      darkTheme: buildDarkTheme(
        fontFamily: themeState.fontFamily,
      ),
    );
  }
}
