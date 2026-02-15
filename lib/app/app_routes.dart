import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/home_page.dart';
import 'observers/route_observer.dart';
import 'routes.dart';

// Screens (placeholders for now)

final _routeObserver = AppRouteObserver();

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      observers: [
        _routeObserver,
      ],
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      routes: [
        // GoRoute(
        //   path: AppRoutes.splash,
        //   // builder: (context, state) => const SplashScreen(),
        // ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        // GoRoute(
        //   path: AppRoutes.home,
        //   // builder: (context, state) => const HomeScreen(),
        // ),
      ],

      errorBuilder: (context, state) {
        return _ErrorScreen(error: state.error);
      },
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final Object? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Something went wrong',
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

