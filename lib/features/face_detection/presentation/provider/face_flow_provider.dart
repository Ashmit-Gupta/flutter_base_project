import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../attendance/attendance_flow_strategy.dart';
import '../../domain/capture_flow_strategy.dart';
import '../model/face_capture_config.dart';
import '../controller/face_capture_controller.dart';
import '../../register_employee/register_flow_strategy.dart';

final captureFlowStrategyProvider =
    Provider.family<CaptureFlowStrategy, FaceCaptureConfig>((ref, config) {
  final isAttendance = config.steps.length == 1 && config.steps.first == FaceCaptureStep.front;
  return isAttendance ? AttendanceFlowStrategy() : RegisterFlowStrategy();
});

