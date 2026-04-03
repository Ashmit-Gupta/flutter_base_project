import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/error_mapper.dart';
import '../../../../../core/results/result.dart';
import '../data_source/history_data_source.dart';
import '../model/get_history_model.dart';

class HistoryRepo {
  HistoryRepo({
    required this.dataSource,
  });

  final HistoryDataSource dataSource;

  AsyncResult<GetHistoryModel> getHistory({
    String? startDate,
    String? endDate,
    int? employeeId,
    String? employeeCode,
    String? status,
    int? page,
    int? limit,
  }) {
    return TaskEither.tryCatch(
      () => dataSource.getHistory(
        startDate: startDate,
        endDate: endDate,
        employeeId: employeeId,
        employeeCode: employeeCode,
        status: status,
        page: page,
        limit: limit,
      ),
      (error, _) => error.toFailure(),
    );
  }
}