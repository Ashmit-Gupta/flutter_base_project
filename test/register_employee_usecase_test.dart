import 'package:basic_project_setup/core/error/app_failure.dart';
import 'package:basic_project_setup/core/results/result.dart';
import 'package:basic_project_setup/features/employee/domain/entities/employee_registration_photos.dart';
import 'package:basic_project_setup/features/employee/domain/entities/employee_summary.dart';
import 'package:basic_project_setup/features/employee/domain/repositories/employee_repository.dart';
import 'package:basic_project_setup/features/employee/domain/usecases/register_employee_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

/// Fake repository — no network; verifies use case orchestration.
class _FakeEmployeeRepository implements EmployeeRepository {
  String? lastRegisteredCode;
  EmployeeRegistrationPhotos? lastPhotos;

  @override
  AsyncResult<List<EmployeeSummary>> getAllEmployee({
    int? page,
    int? limit,
    bool? registered,
    String? name,
  }) {
    return TaskEither(() async => const Right(<EmployeeSummary>[]));
  }

  @override
  AsyncResult<void> registerEmployee({
    required String employeeCode,
    required EmployeeRegistrationPhotos photos,
  }) {
    lastRegisteredCode = employeeCode;
    lastPhotos = photos;
    return TaskEither(() async => const Right(null));
  }
}

void main() {
  group('RegisterEmployeeUseCase', () {
    test('rejects empty employee code', () async {
      final repo = _FakeEmployeeRepository();
      final useCase = RegisterEmployeeUseCase(repo);

      final result = await useCase
          .call(
            employeeCode: '   ',
            photos: const EmployeeRegistrationPhotos(
              leftProfilePath: '/a',
              frontProfilePath: '/b',
              rightProfilePath: '/c',
            ),
          )
          .run();

      expect(result.isLeft(), isTrue);
      result.match(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected failure'),
      );
      expect(repo.lastRegisteredCode, isNull);
    });

    test('delegates to repository when valid', () async {
      final repo = _FakeEmployeeRepository();
      final useCase = RegisterEmployeeUseCase(repo);
      const photos = EmployeeRegistrationPhotos(
        leftProfilePath: '/l',
        frontProfilePath: '/f',
        rightProfilePath: '/r',
      );

      final result = await useCase
          .call(employeeCode: ' E001 ', photos: photos)
          .run();

      expect(result.isRight(), isTrue);
      expect(repo.lastRegisteredCode, 'E001');
      expect(repo.lastPhotos, photos);
    });
  });
}
