import 'package:fpdart/fpdart.dart';

import '../../../../core/error/app_exceptions.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/results/result.dart';
import '../data_source/local_data_source/auth_local_data_source.dart';
import '../data_source/remote_data_source/auth_remote_data_source.dart';
import '../model/login_response_model.dart';

class AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepository(this.remote, this.local);

  AsyncResult<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    return TaskEither.tryCatch(
      () async {
        final response = await remote.login(
          email: email,
          password: password,
        );

        // If the API indicates a business failure (success: false),
        // convert it into a typed exception so it maps to Failure.
        if (!response.success) {
          throw StatusException(response.message);
        }

        // On success, persist auth session locally.
        await local.saveAuthSession(
          token: response.data.token,
          orgId: response.data.orgId,
        );

        return response;
      },
      (error, _) => error.toFailure(),
    );
  }
}