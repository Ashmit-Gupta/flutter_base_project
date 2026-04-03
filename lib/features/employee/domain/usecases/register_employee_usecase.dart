import 'package:fpdart/fpdart.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/results/result.dart';
import '../entities/employee_registration_photos.dart';
import '../repositories/employee_repository.dart';

/// Registration rules live here — not in the ViewModel.
class RegisterEmployeeUseCase {
  RegisterEmployeeUseCase(this._repository);

  final EmployeeRepository _repository;

  AsyncResult<void> call({
    required String employeeCode,
    required EmployeeRegistrationPhotos photos,
  }) {
    final msg = photos.validate();
    if (msg != null) {
      return TaskEither(() async => Left<Failure, void>(ValidationFailure(msg)));
    }

    final code = employeeCode.trim();
    if (code.isEmpty) {
      return TaskEither(
        () async => const Left<Failure, void>(
          ValidationFailure('Please select an employee.'),
        ),
      );
    }

    return _repository.registerEmployee(
      employeeCode: code,
      photos: photos,
    );
  }
}
