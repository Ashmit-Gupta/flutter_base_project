import 'package:dio/dio.dart';

import '../../../../../core/parsing/json_strict_parser.dart';
import '../../../../../core/logging/app_logger.dart';
import '../../auth_endpoints.dart';
import '../../model/login_response_model.dart';

class AuthRemoteDataSource {
  final Dio dio;
  final AppLogger logger;

  AuthRemoteDataSource({
    required this.dio,
    required this.logger,
  });

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };

    return safeRequest<LoginResponseModel>(
      request: dio.post<dynamic>(
        AuthEndpoints.login,
        data: body,
      ),
      source: AuthEndpoints.login,
      logger: logger,
      fromJson: (json) => LoginResponseModel.fromJson(json),
    );
  }
}