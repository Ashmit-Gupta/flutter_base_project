import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'core/di/di.dart';
import 'core/error/config_exception.dart';
import 'core/logging/bootstrap_logger.dart';

Future<void> main() async {
  runZonedGuarded(
        () async {
          WidgetsFlutterBinding.ensureInitialized();

          /// 1️⃣ Flutter framework errors (build/layout/render)
          FlutterError.onError = (FlutterErrorDetails details) {
            bootstrapLogger.fatal(
              'Flutter framework error',
              error: details.exception,
              stackTrace: details.stack,
            );

            // Keep default Flutter behavior (red screen in debug)
            FlutterError.presentError(details);
          };

          await _bootstrap();
    },
        (error, stackTrace) {
      bootstrapLogger.fatal(
        'Uncaught zone error',
        error: error,
        stackTrace: stackTrace,
      );

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          context: ErrorDescription('runZonedGuarded'),
        ),
      );
    },
  );
}

/// ------------------------------------------------------------
/// Bootstrap (env, config, DI) — fail fast, log loudly
/// ------------------------------------------------------------
Future<void> _bootstrap() async {
  try {
    const envFile = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: 'env/dev.env',
    );

    if (envFile.isEmpty) {
      throw const MissingEnvFileException('');
    }

    if (kReleaseMode && envFile.contains('dev')) {
      throw StateError('❌ Dev env used in release build');
    }

    await dotenv.load(fileName: envFile);

    final appConfig = AppConfigFactory.fromDotEnv();

    await setupDI(appConfig);

    runApp(const ProviderScope(child: App()));
  } on BootstrapException  catch (e, st) {
    _handleFatalBootstrapError(e, st);
  } catch (e, st) {
    _handleFatalBootstrapError(
        UnexpectedConfigException(
        'Unexpected bootstrap error',
        cause: e,
        stackTrace: st,
      ),
      st,
    );
  }
}

/// ------------------------------------------------------------
/// Fatal bootstrap handling (single exit point)
/// ------------------------------------------------------------
void _handleFatalBootstrapError(
    BootstrapException error,
    StackTrace stackTrace,
    ) {
  bootstrapLogger.fatal(
    '🔥 Fatal bootstrap error',
    error: error,
    stackTrace: stackTrace,
  );

  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'bootstrap',
      context: ErrorDescription('during app startup'),
    ),
  );

  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Text(
          'App failed to start',
        ),
      ),
    ),
  );
}
