import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:dio/dio.dart';

import '../employee_endpoints.dart';
import '../model/get_all_employee_model.dart';

class EmployeeDataSource {
  final Dio dio;
  final AppLogger logger;

  EmployeeDataSource({
    required this.dio,
    required this.logger,
  });

  Future<GetAllEmployeeModel> getAllEmployee() {
    return safeRequest<GetAllEmployeeModel>(
      request: dio.get<dynamic>(
        EmployeeEndpoints.getAllEmployee,
        options: Options(
          headers: const {
            'x-device-id': 'DEV_123',
            'x-device-pin': '123456',
          },
        ),
      ),
      source: EmployeeEndpoints.getAllEmployee,
      logger: logger,
      fromJson: (json) => GetAllEmployeeModel.fromJson(json),
    );
  }

}