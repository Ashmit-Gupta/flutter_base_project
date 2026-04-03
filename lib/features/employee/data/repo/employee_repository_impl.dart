import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/results/result.dart';
import '../../domain/entities/employee_registration_photos.dart';
import '../../domain/entities/employee_summary.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../../shared/models/app_file_model.dart';
import '../data_source/employee_data_source.dart';
import '../model/register_employee_face_detection_images_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl({required this.dataSource});

  final EmployeeDataSource dataSource;

  @override
  AsyncResult<List<EmployeeSummary>> getAllEmployee({
    int? page,
    int? limit,
    bool? registered,
    String? name,
  }) {
    return TaskEither.tryCatch(
      () async {
        final model = await dataSource.getAllEmployee(
          page: page,
          limit: limit,
          registered: registered,
          name: name,
        );
        return model.data
            .map(
              (e) => EmployeeSummary(
                employeeId: e.employeeId,
                empCode: e.empCode,
                name: e.name,
              ),
            )
            .toList(growable: false);
      },
      (error, _) => error.toFailure(),
    );
  }

  @override
  AsyncResult<void> registerEmployee({
    required String employeeCode,
    required EmployeeRegistrationPhotos photos,
  }) {
    final images = RegisterEmployeeFaceDetectionImagesModel(
      leftProfile: _toAppFile(photos.leftProfilePath, 'left_profile'),
      frontProfile: _toAppFile(photos.frontProfilePath, 'front_profile'),
      rightProfile: _toAppFile(photos.rightProfilePath, 'right_profile'),
    );

    return TaskEither.tryCatch(
      () => dataSource.registerEmployee(
        employeeCode: employeeCode,
        images: images,
      ),
      (error, _) => error.toFailure(),
    );
  }

  AppFileModel _toAppFile(String path, String profileKey) {
    final f = File(path);
    final baseName = path.split(Platform.pathSeparator).last;
    return AppFileModel(
      name: '${profileKey}_$baseName',
      path: path,
      size: f.lengthSync(),
    );
  }
}
