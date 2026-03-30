import 'package:basic_project_setup/core/error/app_exceptions.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const source = '/login';
  final logger = AppLogger(enableLogging: false);

  test('requireField throws with missing key path + types', () {
    final json = <String, dynamic>{};

    final result = () => JsonStrictParser.parseStrict<int>(
          json,
          (j) {
            final map = j as Map<String, dynamic>;
            return JsonStrictParser.requireField<int>(
              map,
              'age',
              path: 'user.profile.age',
            );
          },
          source: source,
          logger: logger,
        );

    expect(
      result,
      throwsA(
        predicate<ParsingException>(
          (e) =>
              e.source == source &&
              e.path == 'user.profile.age' &&
              e.expectedType == 'int' &&
              e.actualType == 'null' &&
              e.value == null,
        ),
      ),
    );
  });

  test('requireField throws with type mismatch details', () {
    final json = <String, dynamic>{
      'age': 'twenty',
    };

    final result = () => JsonStrictParser.parseStrict<int>(
          json,
          (j) {
            final map = j as Map<String, dynamic>;
            return JsonStrictParser.requireField<int>(
              map,
              'age',
              path: 'user.profile.age',
            );
          },
          source: source,
          logger: logger,
        );

    expect(
      result,
      throwsA(
        predicate<ParsingException>(
          (e) =>
              e.source == source &&
              e.path == 'user.profile.age' &&
              e.expectedType == 'int' &&
              e.actualType == 'String' &&
              e.value == 'twenty',
        ),
      ),
    );
  });

  test('parseListStrict tracks index path for nested fields', () {
    final json = <String, dynamic>{
      'items': [
        {'price': 10},
        {'price': 'twenty'},
      ],
    };

    final result = () => JsonStrictParser.parseStrict<List<int>>(
          json,
          (j) {
            final map = j as Map<String, dynamic>;
            return JsonStrictParser.parseListStrict<int>(
              map['items'],
              (item) => JsonStrictParser.requireField<int>(
                item,
                'price',
                path: 'price', // relative -> becomes items[i].price
              ),
              source: source,
              logger: logger,
              path: 'items',
            );
          },
          source: source,
          logger: logger,
        );

    expect(
      result,
      throwsA(
        predicate<ParsingException>(
          (e) =>
              e.source == source &&
              e.path == 'items[1].price' &&
              e.expectedType == 'int' &&
              e.actualType == 'String' &&
              e.value == 'twenty',
        ),
      ),
    );
  });

  test('safeRequest rethrows ParsingException with path info', () async {
    final json = <String, dynamic>{
      'age': 'twenty',
    };

    Future<Response<dynamic>> request() {
      return Future.value(
        Response<dynamic>(
          data: json,
          statusCode: 200,
          requestOptions: RequestOptions(path: source),
        ),
      );
    }

    final result = () async {
      return JsonStrictParser.safeRequest<int>(
        request: request(),
        fromJson: (j) {
          final map = j as Map<String, dynamic>;
          return JsonStrictParser.requireField<int>(
            map,
            'age',
            path: 'user.profile.age',
          );
        },
        source: source,
        logger: logger,
      );
    };

    expect(
      result,
      throwsA(
        predicate<ParsingException>(
          (e) =>
              e.source == source &&
              e.path == 'user.profile.age' &&
              e.expectedType == 'int' &&
              e.actualType == 'String',
        ),
      ),
    );
  });

  test('parsePrimitiveListStrict tracks index path for primitive values', () {
    final json = <String, dynamic>{
      'items': [
        1,
        'twenty',
      ],
    };

    final result = () => JsonStrictParser.parseStrict<List<int>>(
          json,
          (j) {
            final map = j as Map<String, dynamic>;
            return JsonStrictParser.parsePrimitiveListStrict<int>(
              map['items'],
              source: source,
              logger: logger,
              path: 'items',
            );
          },
          source: source,
          logger: logger,
        );

    expect(
      result,
      throwsA(
        predicate<ParsingException>(
          (e) =>
              e.source == source &&
              e.path == 'items[1]' &&
              e.expectedType == 'int' &&
              e.actualType == 'String' &&
              e.value == 'twenty',
        ),
      ),
    );
  });
}

