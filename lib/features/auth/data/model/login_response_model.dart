import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

/// Data-layer model for the `/auth/login` response.
///
/// Expected JSON:
/// {
///   "success": true,
///   "message": "Login success",
///   "data": {
///     "token": "...",
///     "orgId": 4,
///     "employeeRole": "employee"
///   }
/// }
class LoginResponseModel {
  final bool success;
  final String message;
  final LoginDataModel data;

  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponseModel.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;

    final success = requireField<bool>(map, 'success', 'success');
    final message = requireField<String>(map, 'message', 'message');

    // Nested object, but we pass full error paths like `data.token`.
    final dataMap = requireField<Map<String, dynamic>>(
      map,
      'data',
      'data',
    );

    final token = requireField<String>(dataMap, 'token', 'data.token');
    final orgId = requireField<int>(dataMap, 'orgId', 'data.orgId');
    final employeeRole =
        requireField<String>(dataMap, 'employeeRole', 'data.employeeRole');

    return LoginResponseModel(
      success: success,
      message: message,
      data: LoginDataModel(
        token: token,
        orgId: orgId,
        employeeRole: employeeRole,
      ),
    );
  }
}

class LoginDataModel {
  final String token;
  final int orgId;
  final String employeeRole;

  const LoginDataModel({
    required this.token,
    required this.orgId,
    required this.employeeRole,
  });
}

