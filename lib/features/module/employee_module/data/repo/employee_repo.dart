import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/error_mapper.dart';
import '../../../../../core/results/result.dart';
import '../../../../shared/models/app_file_model.dart';
import '../data_source/employee_data_source.dart';
import '../model/get_all_employee_model.dart';
import '../model/register_employee_face_detection_images_model.dart';

class EmployeeRepo {
  EmployeeRepo({required this.dataSource});

  final EmployeeDataSource dataSource;

  AsyncResult<GetAllEmployeeModel> getAllEmployee({
    int? page,
    int? limit,
    bool? registered,
    String? name,
  }) {
    return TaskEither.tryCatch(
      () => dataSource.getAllEmployee(
        page: page,
        limit: limit,
        registered: registered,
        name: name,
      ),
      (error, _) => error.toFailure(),
    );
  }

  AsyncResult<void> registerEmployee({
    required String employeeCode,
    required RegisterEmployeeFaceDetectionImagesModel images,
  }) {
    return TaskEither.tryCatch(
      () => dataSource.registerEmployee(
        employeeCode: employeeCode,
        images: images,
      ),
      (error, _) => error.toFailure(),
    );
  }

  AsyncResult<void> updateEmployeeFaceImages({
    required String employeeCode,
    AppFileModel? leftProfile,
    AppFileModel? frontProfile,
    AppFileModel? rightProfile,
  }) {
    return TaskEither.tryCatch(
      () => dataSource.updateEmployeeFaceImages(
        employeeCode: employeeCode,
        leftProfile: leftProfile,
        frontProfile: frontProfile,
        rightProfile: rightProfile,
      ),
      (error, _) => error.toFailure(),
    );
  }
}
