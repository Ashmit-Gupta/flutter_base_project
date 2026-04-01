import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

class GetAllEmployeeModel {
  const GetAllEmployeeModel({
    required this.data,
  });

  final GetAllEmployeeDataModel data;

  factory GetAllEmployeeModel.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;

    final dataMap = requireField<Map<String, dynamic>>(
      map,
      'data',
      'data',
    );

    final totalUsers = requireField<int>(
      dataMap,
      'total_users',
      'data.total_users',
    );

    final usersRaw = requireField<List<dynamic>>(
      dataMap,
      'users',
      'data.users',
    );
    final users = usersRaw
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return GetAllEmployeeUserModel.fromJson(item);
        })
        .toList(growable: false);

    return GetAllEmployeeModel(
      data: GetAllEmployeeDataModel(
        totalUsers: totalUsers,
        users: users,
      ),
    );
  }
}

class GetAllEmployeeDataModel {
  const GetAllEmployeeDataModel({
    required this.totalUsers,
    required this.users,
  });

  final int totalUsers;
  final List<GetAllEmployeeUserModel> users;
}

class GetAllEmployeeUserModel {
  const GetAllEmployeeUserModel({
    required this.empCode,
    required this.name,
  });

  final String empCode;
  final String name;

  factory GetAllEmployeeUserModel.fromJson(Map<String, dynamic> json) {
    final empCode = requireField<String>(json, 'emp_code', 'emp_code');
    final name = requireField<String>(json, 'name', 'name');

    return GetAllEmployeeUserModel(
      empCode: empCode,
      name: name,
    );
  }
}

