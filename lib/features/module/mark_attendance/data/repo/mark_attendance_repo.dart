import 'package:basic_project_setup/features/module/mark_attendance/data/data_source/mark_attendance_data_source.dart';
import 'package:basic_project_setup/features/module/mark_attendance/data/models/mark_attendance_payload_model.dart';
import 'package:basic_project_setup/features/module/mark_attendance/data/models/mark_attendance_response_model.dart';
import 'package:basic_project_setup/core/error/error_mapper.dart';
import 'package:basic_project_setup/core/results/result.dart';
import 'package:fpdart/fpdart.dart';

class MarkAttendanceRepo {
  final MarkAttendanceDataSource dataSource;
  MarkAttendanceRepo({required this.dataSource});

  AsyncResult<MarkAttendanceResponseModel> markAttendance({
    required MarkAttendancePayloadModel payload,
  }) {
    return TaskEither.tryCatch(
      () => dataSource.markAttendance(payload: payload),
      (error, _) => error.toFailure(),
    );
  }
}