import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/face_capture_controller.dart';
import '../model/face_capture_config.dart';

final faceCaptureControllerProvider =
    NotifierProvider.autoDispose.family<
        FaceCaptureController, FaceCaptureState, FaceCaptureConfig>(
  FaceCaptureController.new,
);


