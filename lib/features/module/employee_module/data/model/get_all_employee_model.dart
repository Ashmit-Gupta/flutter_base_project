import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

class GetAllEmployeeModel {
  const GetAllEmployeeModel({
    required this.data,
  });

  final List<GetAllEmployeeUserModel> data;

  factory GetAllEmployeeModel.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;

    final dataRaw = requireField<List<dynamic>>(
      map,
      'data',
      'data',
    );

    final users = dataRaw
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return GetAllEmployeeUserModel.fromJson(item);
        })
        .toList(growable: false);

    return GetAllEmployeeModel(
      data: users,
    );
  }
}

class GetAllEmployeeUserModel {
  const GetAllEmployeeUserModel({
    required this.employeeId,
    required this.empCode,
    required this.name,
  });

  final int employeeId;
  final String empCode;
  final String name;

  factory GetAllEmployeeUserModel.fromJson(Map<String, dynamic> json) {
    final employeeId = requireField<int>(json, 'employee_id', 'employee_id');
    final empCode =
        requireField<String>(json, 'employee_code', 'employee_code');
    final name = requireField<String>(json, 'name', 'name');

    return GetAllEmployeeUserModel(
      employeeId: employeeId,
      empCode: empCode,
      name: name,
    );
  }
}

