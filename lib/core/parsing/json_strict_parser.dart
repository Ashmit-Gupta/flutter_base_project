import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../error/app_exceptions.dart';
import '../logging/app_logger.dart';

/// Holds the current JSON parsing context for field-level tracking.
///
/// `path` acts as a prefix so that helpers can build full paths like:
/// - `user.profile.age`
/// - `items[0].price`
class JsonParseContext {
  final String source;
  final String path;

  const JsonParseContext({
    required this.source,
    required this.path,
  });
}

/// Strict JSON parsing boundary with field-level path tracking.
///
/// This is intended to be used at the "deserialization boundary"
/// (e.g. DataSource -> Repository) so that:
/// - invalid JSON fails fast
/// - each parsing error is tied to an exact JSON field path
/// - parsing issues are traceable in logs and exceptions
class JsonStrictParser {
  JsonStrictParser._();

  static const Object _zoneKey = Object();

  static JsonParseContext get _currentContext {
    final ctx = Zone.current[_zoneKey] as JsonParseContext?;
    return ctx ?? const JsonParseContext(source: '<unknown>', path: '<root>');
  }

  static String _fullPath(String currentContextPath, String relativeOrFullPath) {
    final trimmed = relativeOrFullPath.trim();
    if (trimmed.isEmpty) return currentContextPath;

    if (currentContextPath == '<root>' || currentContextPath.isEmpty) {
      return trimmed;
    }

    // If caller already provided a full path, keep it.
    if (trimmed.startsWith(currentContextPath)) return trimmed;

    // If caller is providing something like `[0]`, don't add '.'.
    if (trimmed.startsWith('[')) return '$currentContextPath$trimmed';

    return '$currentContextPath.$trimmed';
  }

  /// A safe request wrapper that deserializes using [fromJson].
  ///
  /// Responsibilities:
  /// - Await request
  /// - Extract `response.data`
  /// - Parse using [parseStrict]
  /// - Catch parsing errors, log detailed field-level info, and rethrow
  ///
  /// Notes:
  /// - Dio/network errors are expected to already be mapped by the interceptor
  ///   layer; they are not swallowed here.
  static Future<T> safeRequest<T>({
    required Future<Response<dynamic>> request,
    required T Function(dynamic json) fromJson,
    required String source,
    required AppLogger logger,
  }) async {
    final response = await request;
    final data = response.data;

    try {
      return parseStrict<T>(
        data,
        fromJson,
        source: source,
        logger: logger,
      );
    } on ParsingException catch (e) {
      _logParsingFailure(
        logger,
        exception: e,
      );
      throw e;
    }
  }

  /// Strict parsing entry point that wraps unexpected exceptions in
  /// a [ParsingException].
  ///
  /// Field-level errors should be thrown by helpers like [requireField]
  /// or [parseListStrict] so the exact path is always available.
  static T parseStrict<T>(
    dynamic json,
    T Function(dynamic json) fromJson, {
    required String source,
    required AppLogger logger,
  }) {
    // Logging itself is done in [safeRequest] to avoid double-logging.
    // ignore: unused_parameter
    final _ = logger;

    if (json == null) {
      throw ParsingException(
        'Failed at field: <root>',
        source: source,
        rawData: json,
        path: '<root>',
      );
    }

    return runZoned(
      () => _parseInContext<T>(
        json,
        fromJson,
        source: source,
      ),
      zoneValues: {
        _zoneKey: JsonParseContext(source: source, path: '<root>'),
      },
    );
  }

  static T _parseInContext<T>(
    dynamic json,
    T Function(dynamic json) fromJson, {
    required String source,
  }) {
    try {
      return fromJson(json);
    } on ParsingException {
      rethrow;
    } catch (e, st) {
      // Unknown parsing failure (e.g. a bad cast inside fromJson).
      // Still wrapped so callers get a deterministic ParsingException.
      throw ParsingException(
        'Failed at field: ${_currentContext.path}',
        source: source,
        rawData: json,
        path: _currentContext.path,
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Required field extraction with strict type checks and path tracking.
  ///
  /// Validates:
  /// - the key exists
  /// - the value is non-null
  /// - the runtime type matches `T` via `value is T`
  ///
  /// On failure:
  /// - throws [ParsingException] including [path], [expectedType], [actualType], and [value]
  static T requireField<T>(
    Map<String, dynamic> json,
    String key, {
    required String path,
  }) {
    final ctx = _currentContext;
    final fullPath = _fullPath(ctx.path, path);

    if (!json.containsKey(key) || json[key] == null) {
      throw ParsingException(
        'Failed at field: $fullPath',
        source: ctx.source,
        rawData: json,
        path: fullPath,
        expectedType: T.toString(),
        actualType: 'null',
        value: null,
      );
    }

    final value = json[key];
    if (value is! T) {
      throw ParsingException(
        'Failed at field: $fullPath',
        source: ctx.source,
        rawData: value,
        path: fullPath,
        expectedType: T.toString(),
        actualType: value.runtimeType.toString(),
        value: value,
        cause: StateError(
          'Expected ${T.toString()} but found ${value.runtimeType.toString()}',
        ),
      );
    }
    return value;
  }

  /// Parses a strict list of objects while tracking the index in the path.
  ///
  /// `path` is used as a prefix and the resulting element paths are:
  /// - `${path}[0]`
  /// - `${path}[1]`
  /// ...
  static List<T> parseListStrict<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson, {
    required String source,
    required AppLogger logger,
    String path = 'items',
  }) {
    // ignore: unused_parameter
    final _ = logger;

    final ctx = _currentContext;
    final listPath = _fullPath(ctx.path, path);

    if (json is! List) {
      throw ParsingException(
        'Failed at field: $listPath',
        source: source,
        rawData: json,
        path: listPath,
        expectedType: 'List',
        actualType: json.runtimeType.toString(),
        value: json,
        cause: StateError('Expected List but found ${json.runtimeType}'),
      );
    }

    final list = json;
    final results = <T>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final itemPath = '$listPath[$i]';

      if (item is! Map<String, dynamic>) {
        throw ParsingException(
          'Failed at field: $itemPath',
          source: source,
          rawData: item,
          path: itemPath,
          expectedType: 'Map<String, dynamic>',
          actualType: item.runtimeType.toString(),
          value: item,
          cause: StateError('Expected Map at $itemPath'),
        );
      }

      try {
        results.add(
          runZoned(
            () => fromJson(item),
            zoneValues: {
              _zoneKey: JsonParseContext(
                source: source,
                path: itemPath,
              ),
            },
          ),
        );
      } on ParsingException {
        rethrow;
      } catch (e, st) {
        throw ParsingException(
          'Failed at field: $itemPath',
          source: source,
          rawData: item,
          path: itemPath,
          cause: e,
          stackTrace: st,
        );
      }
    }

    return results;
  }

  /// Parses a strict list of primitives while tracking the index in the path.
  ///
  /// Use this when the API returns something like:
  /// - `{"items": [1, 2, 3]}`
  /// - `{"tags": ["a", "b"]}`
  ///
  /// Resulting element paths are:
  /// - `${path}[0]`
  /// - `${path}[1]`
  /// ...
  ///
  /// Notes:
  /// - This is strict: it requires runtime type compatibility via `item is T`.
  ///   If your backend returns `10.0` but you expect `int`, it will fail
  ///   with a path-tracked [ParsingException].
  static List<T> parsePrimitiveListStrict<T>(
    dynamic json, {
    required String source,
    required AppLogger logger,
    String path = 'items',
  }) {
    // ignore: unused_parameter
    final _ = logger;

    final ctx = _currentContext;
    final listPath = _fullPath(ctx.path, path);

    if (json is! List) {
      throw ParsingException(
        'Failed at field: $listPath',
        source: source,
        rawData: json,
        path: listPath,
        expectedType: 'List<$T>',
        actualType: json.runtimeType.toString(),
        value: json,
        cause: StateError('Expected List at $listPath'),
      );
    }

    final list = json;
    final results = <T>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final itemPath = '$listPath[$i]';

      results.add(
        runZoned(
          () {
            final current = _currentContext;
            if (item is! T) {
              throw ParsingException(
                'Failed at field: ${current.path}',
                source: current.source,
                rawData: item,
                path: current.path,
                expectedType: T.toString(),
                actualType: item.runtimeType.toString(),
                value: item,
                cause: StateError(
                  'Expected ${T.toString()} but found ${item.runtimeType.toString()}',
                ),
              );
            }

            return item;
          },
          zoneValues: {
            _zoneKey: JsonParseContext(
              source: source,
              path: itemPath,
            ),
          },
        ),
      );
    }

    return results;
  }

  static void _logParsingFailure(
    AppLogger logger, {
    required ParsingException exception,
  }) {
    final path = exception.path ?? '<unknown>';
    final expected = exception.expectedType ?? '<unknown>';
    final actual = exception.actualType ?? '<unknown>';
    final value = _formatValue(exception.value ?? exception.rawData);

    logger.error(
      '[ParsingError]\n'
      'source: ${exception.source}\n'
      'path: $path\n'
      'expected: $expected\n'
      'actual: $actual\n'
      'value: $value',
      error: exception,
    );
  }

  static String _formatValue(Object? value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';

    // Best effort: try JSON encoding for lists/maps.
    if (value is Map || value is List) {
      try {
        return jsonEncode(value);
      } catch (_) {
        // Fall through to toString()
      }
    }

    return value.toString();
  }
}

// -----------------------------------------------------------------------------
// Top-level helpers (match requested signatures for easier reuse)
// -----------------------------------------------------------------------------

Future<T> safeRequest<T>({
  required Future<Response<dynamic>> request,
  required T Function(dynamic json) fromJson,
  required String source,
  required AppLogger logger,
}) =>
    JsonStrictParser.safeRequest<T>(
      request: request,
      fromJson: fromJson,
      source: source,
      logger: logger,
    );

T parseStrict<T>(
  dynamic json,
  T Function(dynamic json) fromJson, {
  required String source,
  required AppLogger logger,
}) =>
    JsonStrictParser.parseStrict<T>(
      json,
      fromJson,
      source: source,
      logger: logger,
    );

T requireField<T>(
  Map<String, dynamic> json,
  String key,
  String path,
) =>
    JsonStrictParser.requireField<T>(
      json,
      key,
      path: path,
    );

List<T> parseListStrict<T>(
  dynamic json,
  T Function(Map<String, dynamic>) fromJson, {
  required String source,
  required AppLogger logger,
  String path = 'items',
}) =>
    JsonStrictParser.parseListStrict<T>(
      json,
      fromJson,
      source: source,
      logger: logger,
      path: path,
    );

List<T> parsePrimitiveListStrict<T>(
  dynamic json, {
  required String source,
  required AppLogger logger,
  String path = 'items',
}) =>
    JsonStrictParser.parsePrimitiveListStrict<T>(
      json,
      source: source,
      logger: logger,
      path: path,
    );


// -----------------------------------------------------------------------------
// Sample usage (from a Riverpod context using `ref`)
// -----------------------------------------------------------------------------
//
// Example: inside a Riverpod Notifier/Provider method you have `ref`.
//
// final dio = getIt<Dio>();
// final logger = getIt<AppLogger>();
//
// Future<User> login({
//   required String username,
//   required String password,
// }) async {
//   return safeRequest<User>(
//     request: dio.postRequest(
//       '/login',
//       body: {'username': username, 'password': password},
//     ),
//     source: '/login',
//     logger: logger,
//     fromJson: (json) {
//       final map = json as Map<String, dynamic>;
//       // Primitive field example:
//       final age = requireField<int>(map, 'age', 'user.profile.age');
//
//       // Primitive list example (paths like items[0], items[1]...):
//       final ids = parsePrimitiveListStrict<int>(
//         map['items'],
//         source: '/login',
//         logger: logger,
//         path: 'items',
//       );
//
//       // Object list example:
//       // final items = parseListStrict<Item>(
//       //   map['items'],
//       //   (itemJson) => requireField<String>(itemJson, 'name', 'name'),
//       //   source: '/login',
//       //   logger: logger,
//       //   path: 'items',
//       // );
//
//       return User(age: age, ids: ids);
//     },
//   );
// }

//usage (object list + relative field path example)
// return parseListStrict<int>(
//   json['items'],
//   (item) => requireField<int>(item, 'price', 'price'), // -> items[0].price
//   source: '/login',
//   logger: logger,
//   path: 'items',
// );