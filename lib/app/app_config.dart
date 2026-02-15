import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/error/config_exception.dart';


enum AppEnvironment { dev, prod }

@immutable
class AppConfig {
  // Environment
  final AppEnvironment environment;

  // Networking
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  // Observability
  final bool enableLogging;
  final bool enableCrashlytics;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
    required this.enableCrashlytics,
    required this.sendTimeout,
  });
}

/// Required env keys. All must be present and non-empty.
const _requiredEnvKeys = [
  'ENV',
  'API_BASE_URL',
  'CONNECT_TIMEOUT',
  'RECEIVE_TIMEOUT',
  'SEND_TIMEOUT',
  'ENABLE_LOGS',
  'ENABLE_CRASHLYTICS',
];

class AppConfigFactory {
  AppConfigFactory._();

  /// Builds [AppConfig] from the currently loaded dotenv map.
  ///
  /// Call only after [dotenv.load] has been successfully run (e.g. from [main]).
  /// Throws [MissingEnvVarException] if any required key is missing or empty.
  static AppConfig fromDotEnv() {
    final raw = dotenv.env;
    if (raw.isEmpty) {
      throw MissingEnvVarException(
        'ENV',
        allMissingKeys: List.from(_requiredEnvKeys),
      );
    }

    final env = _trimmedMap(raw);
    final missing = _missingOrEmptyKeys(env, _requiredEnvKeys);
    if (missing.isNotEmpty) {
      throw MissingEnvVarException(
        missing.first,
        allMissingKeys: missing,
      );
    }

    final environment = _parseEnvironment(env['ENV']!);
    final connectTimeout = _parsePositiveInt(
      env['CONNECT_TIMEOUT']!,
      key: 'CONNECT_TIMEOUT',
    );
    final receiveTimeout = _parsePositiveInt(
      env['RECEIVE_TIMEOUT']!,
      key: 'RECEIVE_TIMEOUT',
    );
    final sendTimeout = _parsePositiveInt(
      env['SEND_TIMEOUT']!,
      key: 'SEND_TIMEOUT',
    );

    return AppConfig(
      environment: environment,
      apiBaseUrl: env['API_BASE_URL']!,
      connectTimeout: Duration(seconds: connectTimeout),
      sendTimeout: Duration(seconds: sendTimeout),
      receiveTimeout: Duration(seconds: receiveTimeout),
      enableLogging: env['ENABLE_LOGS']!.toLowerCase() == 'true',
      enableCrashlytics: env['ENABLE_CRASHLYTICS']!.toLowerCase() == 'true',
    );
  }

  static Map<String, String> _trimmedMap(Map<String, String> raw) {
    return raw.map(
      (k, v) => MapEntry(k, v.trim()),
    );
  }

  static List<String> _missingOrEmptyKeys(
    Map<String, String> env,
    List<String> keys,
  ) {
    return keys.where((key) {
      final value = env[key];
      return value == null || value.isEmpty;
    }).toList();
  }

  static AppEnvironment _parseEnvironment(String value) {
    final trimmed = value.trim().toLowerCase();
    try {
      return AppEnvironment.values.firstWhere(
        (e) => e.name == trimmed,
        orElse: () => throw ArgumentError(trimmed),
      );
    } catch (_) {
      throw Exception(
        'Invalid ENV value "$value". '
        'Allowed values: ${AppEnvironment.values.map((e) => e.name).join(', ')}',
      );
    }
  }

  static int _parsePositiveInt(String value, {required String key}) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1) {
      throw Exception(
        'Invalid $key: "$value". Must be a positive integer.',
      );
    }
    return parsed;
  }
}
