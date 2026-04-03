import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';
import 'package:dio/dio.dart';

import '../history_endpoints.dart';
import '../model/get_history_model.dart';

class HistoryDataSource {
  HistoryDataSource({
    required this.dio,
    required this.logger,
  });

  final Dio dio;
  final AppLogger logger;

  Future<GetHistoryModel> getHistory({
    String? startDate,
    String? endDate,
    int? employeeId,
    String? employeeCode,
    String? status,
    int? page,
    int? limit,
  }) {
    final queryParameters = <String, dynamic>{};
    if (startDate != null) queryParameters['start_date'] = startDate;
    if (endDate != null) queryParameters['end_date'] = endDate;
    if (employeeId != null) queryParameters['employee_id'] = employeeId;
    if (employeeCode != null) queryParameters['employee_code'] = employeeCode;
    if (status != null) queryParameters['status'] = status;
    if (page != null) queryParameters['page'] = page;
    if (limit != null) queryParameters['limit'] = limit;

    return safeRequest<GetHistoryModel>(
      request: dio.get<dynamic>(
        HistoryEndpoints.getHistory,
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      ),
      source: HistoryEndpoints.getHistory,
      logger: logger,
      fromJson: (json) => GetHistoryModel.fromJson(json),
    );
  }
}