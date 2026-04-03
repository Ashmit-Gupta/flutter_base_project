import '../../../../core/results/result.dart';
import '../entities/employee_registration_photos.dart';
import '../entities/employee_summary.dart';

/// Employee feature contract — [data] layer provides implementation.
abstract class EmployeeRepository {
  AsyncResult<List<EmployeeSummary>> getAllEmployee({
    int? page,
    int? limit,
    bool? registered,
    String? name,
  });

  AsyncResult<void> registerEmployee({
    required String employeeCode,
    required EmployeeRegistrationPhotos photos,
  });
}
