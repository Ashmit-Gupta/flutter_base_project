import 'package:fpdart/fpdart.dart';
import '../error/app_failure.dart';

typedef Result<T> = Either<Failure, T>;
typedef AsyncResult<T> = TaskEither<Failure, T>;


// usage
//import 'package:fpdart/fpdart.dart';
//
// class UserRepository {
//   UserRepository(this._remote);
//
//   final UserRemoteDataSource _remote;
//
//   AsyncResult<String> getUserName() {
//     return TaskEither.tryCatch(
//       () async => _remote.fetchUserName(),
//       (error, _) => mapExceptionToFailure(error as AppException),
//     );
//   }
// }