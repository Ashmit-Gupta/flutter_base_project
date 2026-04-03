import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/attendance_face_validation.dart';
import '../../domain/face_detection_validation_strategy.dart';
import '../model/face_capture_config.dart';
import '../controller/face_capture_controller.dart';
import '../../register_employee/register_employee_face_validation.dart';

final faceValidationStrategyProvider =
    Provider.family<FaceValidationStrategy, FaceCaptureConfig>((ref, config) {
  final isAttendance = config.steps.length == 1 && config.steps.first == FaceCaptureStep.front;
  return isAttendance ? AttendanceFaceValidation() : RegisterEmployeeFaceValidation();
});

