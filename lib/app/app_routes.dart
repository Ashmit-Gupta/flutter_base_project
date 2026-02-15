import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/design_system_screen.dart';
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
      // initialLocation: AppRoutes.home,
      initialLocation: AppRoutes.designSystemScreen,
      debugLogDiagnostics: true,
      routes: [
        // GoRoute(
        //   path: AppRoutes.splash,
        //   // builder: (context, state) => const SplashScreen(),
        // ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.designSystemScreen,
          builder: (context, state) => const DesignSystemScreen(),
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

