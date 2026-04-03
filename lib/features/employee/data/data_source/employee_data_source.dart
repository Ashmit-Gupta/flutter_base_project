import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

import '../../../shared/models/app_file_model.dart';
import '../employee_endpoints.dart';
import '../model/get_all_employee_model.dart';
import '../model/register_employee_face_detection_images_model.dart';

class EmployeeDataSource {
  final Dio dio;
  final AppLogger logger;

  EmployeeDataSource({required this.dio, required this.logger});

  Future<GetAllEmployeeModel> getAllEmployee({
    int? page,
    int? limit,
    bool? registered,
    String? name,
  }) {
    final queryParameters = <String, dynamic>{};
    if (page != null) queryParameters['page'] = page;
    if (limit != null) queryParameters['limit'] = limit;
    if (registered != null) queryParameters['registered'] = registered;
    if (name != null) queryParameters['name'] = name;

    return safeRequest<GetAllEmployeeModel>(
      request: dio.get<dynamic>(
        EmployeeEndpoints.getAllEmployee,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      ),
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
      EmployeeEndpoints.registerEmployeeFace(employeeCode),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> updateEmployeeFaceImages({
    required String employeeCode,
    AppFileModel? leftProfile,
    AppFileModel? frontProfile,
    AppFileModel? rightProfile,
  }) async {
    final payload = <String, dynamic>{};

    if (leftProfile != null) {
      payload['left'] = await MultipartFile.fromFile(
        leftProfile.path,
        filename: leftProfile.name,
      );
    }
    if (frontProfile != null) {
      payload['center'] = await MultipartFile.fromFile(
        frontProfile.path,
        filename: frontProfile.name,
      );
    }
    if (rightProfile != null) {
      payload['right'] = await MultipartFile.fromFile(
        rightProfile.path,
        filename: rightProfile.name,
      );
    }

    if (payload.isEmpty) {
      logger.info(
        '[EmployeeDataSource] updateEmployeeFaceImages skipped: no updated files for employeeCode=$employeeCode',
      );
      return;
    }

    logger.info(
      '[EmployeeDataSource] updateEmployeeFaceImages multipart keys=${payload.keys.toList()} employeeCode=$employeeCode',
    );

    final formData = FormData.fromMap(payload);
    await dio.patch<dynamic>(
      EmployeeEndpoints.registerEmployeeFace(employeeCode),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
