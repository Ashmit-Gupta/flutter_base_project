import 'package:dio/dio.dart';
import 'package:basic_project_setup/core/logging/app_logger.dart';
import 'package:basic_project_setup/core/parsing/json_strict_parser.dart';

import '../mark_attendance_endpoint.dart';
import '../models/mark_attendance_payload_model.dart';
import '../models/mark_attendance_response_model.dart';

class MarkAttendanceDataSource {
  final Dio dio;
  final AppLogger logger;

  MarkAttendanceDataSource({
    required this.dio,
    required this.logger,
  });

  Future<MarkAttendanceResponseModel> markAttendance({
    required MarkAttendancePayloadModel payload,
  }) {
    return safeRequest<MarkAttendanceResponseModel>(
      request: () async {
        final formData = FormData.fromMap(<String, dynamic>{
          MarkAttendancePayloadModel.fieldFaceImage: await MultipartFile.fromFile(
            payload.faceImagePath,
          ),
          ...payload.toTextFields(),
        });
        return dio.post<dynamic>(
          MarkAttendanceEndpoint.markAttendance,
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );
      }(),
      source: MarkAttendanceEndpoint.markAttendance,
      logger: logger,
      fromJson: (json) => MarkAttendanceResponseModel.fromJson(json),
    );
  }
}