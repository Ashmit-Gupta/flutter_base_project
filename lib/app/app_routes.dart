import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/face_detection/presentation/screens/face_capture_screen.dart';
import '../features/face_detection/presentation/model/face_capture_config.dart';
import '../features/module/employee_module/data/model/get_all_employee_model.dart';
import '../features/module/employee_module/presentation/screens/employee_list_screen.dart';
import '../features/module/employee_module/presentation/screens/register_employee_screen.dart';
import '../features/profile_section/presentation/screens/edit_admin_pin_screen.dart';
import '../features/profile_section/presentation/screens/edit_email_password_screen.dart';
import '../features/profile_section/presentation/screens/edit_password_screen.dart';
import '../features/profile_section/presentation/screens/profile_screen.dart';
import '../features/design_system_screen.dart';
import '../features/shared/screens/image_preview_screen.dart';
import '../features/module/mark_attendance/presentation/screens/mark_attendance_screen.dart';
import '../home_screen.dart';
import '../core/logging/app_logger.dart';
import '../features/auth/domain/auth_state.dart';
import 'observers/route_observer.dart';
import 'routes.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

// Screens (placeholders for now)

class AppRouter {
  static GoRouter createRouter(
    AppLogger logger,
    AsyncValue<AuthState> Function() readAuthState,
  ) {
    final routeObserver = AppRouteObserver(logger);
    return GoRouter(
      observers: [routeObserver],
      initialLocation: AppRoutes.splash,
      // initialLocation: AppRoutes.designSystemScreen,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final authState = readAuthState();
        final location = state.matchedLocation;
        final isAuthRoute =
            location == AppRoutes.login ||
            location == AppRoutes.signup ||
            location == AppRoutes.forgotPassword;

        if (authState.isLoading) {
          return null;
        }

        return switch (authState) {
          AsyncData(:final value) when value is Unauthenticated =>
            (isAuthRoute ? null : AppRoutes.login),
          AsyncData(:final value) when value is Authenticated =>
            (location == AppRoutes.splash || isAuthRoute
                ? AppRoutes.home
                : null),
          _ => null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.designSystemScreen,
          builder: (context, state) => const DesignSystemScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.employeeList,
          builder: (context, state) => const EmployeeListScreen(),
        ),
        GoRoute(
          path: AppRoutes.registerEmployee,
          builder: (context, state) {
            final extra = state.extra;
            final employee = extra is GetAllEmployeeUserModel ? extra : null;
            return RegisterEmployeeScreen(initialEmployee: employee);
          },
        ),
        GoRoute(
          path: AppRoutes.faceCapture,
          builder: (context, state) {
            final extra = state.extra;
            final config = extra is FaceCaptureConfig
                ? extra
                : const FaceCaptureConfig.allProfiles();
            return FaceCaptureScreen(config: config);
          },
        ),
        GoRoute(
          path: AppRoutes.markAttendance,
          builder: (context, state) {
            // Location details can be provided via `state.extra` later if needed.
            return const MarkAttendanceScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.employeeImagePreview,
          builder: (context, state) {
            final file = state.extra;
            if (file is! PlatformFile) {
              return const _ErrorScreen(error: 'Missing preview file');
            }
            return ImagePreviewScreen(file: file);
          },
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.editEmailPassword,
          builder: (context, state) => const EditEmailPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.editPassword,
          builder: (context, state) => const EditPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.editAdminPin,
          builder: (context, state) => const EditAdminPinScreen(),
        ),
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
      child: Text('Something went wrong', textDirection: TextDirection.ltr),
    );
  }
}
