import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:basic_project_setup/core/di/core_providers.dart';
import 'package:basic_project_setup/core/services/location_service.dart';
import 'package:basic_project_setup/core/services/permission_service.dart';
import 'package:basic_project_setup/features/module/mark_attendance/data/models/mark_attendance_payload_model.dart';
import 'package:basic_project_setup/features/module/mark_attendance/data/models/mark_attendance_response_model.dart';
import 'package:basic_project_setup/features/module/mark_attendance/di/mark_attendance_di.dart';

class MarkAttendanceState {
  final bool isLoadingLocation;
  final AppLocation? location;
  final String? locationError;

  final bool isMarkingAttendance;

  const MarkAttendanceState({this.isLoadingLocation = false, this.location, this.locationError, this.isMarkingAttendance = false});

  MarkAttendanceState copyWith({bool? isLoadingLocation, AppLocation? location, String? locationError, bool? isMarkingAttendance}) {
    return MarkAttendanceState(isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation, location: location ?? this.location, locationError: locationError, isMarkingAttendance: isMarkingAttendance ?? this.isMarkingAttendance);
  }
}

final markAttendanceControllerProvider = NotifierProvider.autoDispose<MarkAttendanceController, MarkAttendanceState>(MarkAttendanceController.new);

class MarkAttendanceController extends Notifier<MarkAttendanceState> {
  @override
  MarkAttendanceState build() {
    Future.microtask(loadLocation);
    return const MarkAttendanceState(isLoadingLocation: true);
  }

  Future<void> loadLocation() async {
    state = state.copyWith(isLoadingLocation: true, locationError: null);

    final permissionHandler = ref.read(locationPermissionHandlerProvider);
    final permission = await permissionHandler.ensureAlwaysLocationAccess();
    if (permission != PermissionResult.granted) {
      final msg = switch (permission) {
        PermissionResult.denied => 'Location permission denied',
        PermissionResult.permanentlyDenied => 'Location permission permanently denied. Please enable it from Settings.',
        PermissionResult.granted => '',
      };
      state = state.copyWith(isLoadingLocation: false, locationError: msg);
      return;
    }

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      state = state.copyWith(isLoadingLocation: false, location: location, locationError: null);
    } catch (e) {
      state = state.copyWith(isLoadingLocation: false, locationError: e.toString());
    }
  }

  Future<MarkAttendanceResponseModel?> markAttendance({required String faceImagePath}) async {
    final location = state.location;
    if (location == null) return null;
    final logger = ref.read(appLoggerProvider);

    state = state.copyWith(isMarkingAttendance: true);
    try {
      final payload = MarkAttendancePayloadModel(
        faceImagePath: faceImagePath,
        location: MarkAttendanceLocationPayload(latitude: location.latitude, longitude: location.longitude, locationName: location.name),
      );
      logger.info(
        '[MarkAttendance] sending location '
        'name="${payload.location.locationName}" '
        'lat=${payload.location.latitude} '
        'long=${payload.location.longitude}',
      );

      final result = await ref.read(markAttendanceRepoProvider).markAttendance(payload: payload).run();

      return result.match((_) => null, (ok) => ok);
    } finally {
      state = state.copyWith(isMarkingAttendance: false);
    }
  }
}
