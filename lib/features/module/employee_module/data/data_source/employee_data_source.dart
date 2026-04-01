import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

import '../employee_endpoints.dart';
import '../model/get_all_employee_model.dart';
import '../model/register_employee_face_detection_images_model.dart';

class EmployeeDataSource {
  final Dio dio;
  final AppLogger logger;

  EmployeeDataSource({
    required this.dio,
    required this.logger,
  });

  Future<GetAllEmployeeModel> getAllEmployee() {
    return safeRequest<GetAllEmployeeModel>(
      request: dio.get<dynamic>(EmployeeEndpoints.getAllEmployee),
      source: EmployeeEndpoints.getAllEmployee,
      logger: logger,
      fromJson: (json) => GetAllEmployeeModel.fromJson(json),
    );
  }

  Future<void> registerEmployee({
    required String employeeCode,
    required RegisterEmployeeFaceDetectionImagesModel images,
  }) async {
    final payload = <String, dynamic>{
      'left': await MultipartFile.fromFile(
        images.leftProfile.path,
        filename: images.leftProfile.name,
      ),
      'center': await MultipartFile.fromFile(
        images.frontProfile.path,
        filename: images.frontProfile.name,
      ),
      'right': await MultipartFile.fromFile(
        images.rightProfile.path,
        filename: images.rightProfile.name,
      ),
    };
    logger.info(
      '[EmployeeDataSource] registerEmployee multipart keys=${payload.keys.toList()} '
      'left=${images.leftProfile.path} center=${images.frontProfile.path} right=${images.rightProfile.path}',
    );
    final formData = FormData.fromMap(payload);

    await dio.post<dynamic>(
      EmployeeEndpoints.registerEmployee(employeeCode),
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

}