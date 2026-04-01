import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/face_capture_controller.dart';

final faceCaptureControllerProvider =
    NotifierProvider.autoDispose<FaceCaptureController, FaceCaptureState>(
  FaceCaptureController.new,
);


