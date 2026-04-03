import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:basic_project_setup/core/feedback/app_snackbar.dart';
import 'package:basic_project_setup/features/face_detection/presentation/controller/face_capture_controller.dart';
import 'package:basic_project_setup/features/face_detection/presentation/model/face_capture_config.dart';
import 'package:basic_project_setup/features/face_detection/presentation/provider/face_capture_provider.dart';
import 'package:basic_project_setup/features/face_detection/widgets/face_overlay_painter.dart';
import 'package:basic_project_setup/features/face_detection/widgets/face_overlay_widget.dart';
import 'package:basic_project_setup/features/module/mark_attendance/presentation/controller/mark_attendance_controller.dart';

class MarkAttendanceScreen extends HookConsumerWidget {
  const MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(markAttendanceControllerProvider);
    final attendanceController = ref.read(markAttendanceControllerProvider.notifier);

    final captureState = ref.watch(
      faceCaptureControllerProvider(FaceCaptureConfig.attendanceFront),
    );
    final faceCaptureController = ref.read(
      faceCaptureControllerProvider(FaceCaptureConfig.attendanceFront).notifier,
    );

    final lastFeedbackSnackAt = useRef<DateTime?>(null);

    useEffect(() {
      Future.microtask(
        () => faceCaptureController.initialize(
          config: FaceCaptureConfig.attendanceFront,
        ),
      );
      return null;
    }, const []);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.paused ||
          current == AppLifecycleState.hidden ||
          current == AppLifecycleState.detached) {
        faceCaptureController.disposeCamera();
      } else if (current == AppLifecycleState.resumed) {
        faceCaptureController.initialize(config: FaceCaptureConfig.attendanceFront);
      }
    });

    ref.listen<FaceCaptureState>(
      faceCaptureControllerProvider(FaceCaptureConfig.attendanceFront),
      (previous, next) {
        final msg = next.feedbackMessage;
        if (msg.isEmpty || msg == previous?.feedbackMessage) return;

        final now = DateTime.now();
        final last = lastFeedbackSnackAt.value;
        if (last != null && now.difference(last) < const Duration(seconds: 4)) {
          return;
        }
        lastFeedbackSnackAt.value = now;
        if (!context.mounted) return;

        final severe = msg.contains('only one face') ||
            msg.contains('Only one face') ||
            msg.startsWith('Uncover') ||
            msg.startsWith('Do not cover') ||
            msg.startsWith('Keep your face visible') ||
            msg.startsWith('Something may be blocking');
        if (severe) {
          AppSnackbar.warning(context, msg);
        } else {
          AppSnackbar.info(context, msg);
        }
      },
    );

    Future<void> handleCaptureComplete(
      Map<String, String> capturedPhotoByProfile,
    ) async {
      final faceImagePath = capturedPhotoByProfile['front_profile'] ??
          (capturedPhotoByProfile.isNotEmpty
              ? capturedPhotoByProfile.values.first
              : '');

      if (faceImagePath.isEmpty) {
        if (!context.mounted) return;
        AppSnackbar.error(context, 'Face capture photo missing.');
        return;
      }

      try {
        if (attendanceState.location == null) {
          if (!context.mounted) return;
          AppSnackbar.warning(context, 'Location not available. Please enable GPS and try again.');
          await attendanceController.loadLocation();
          faceCaptureController.rearmCaptureFlow();
          return;
        }

        final response = await attendanceController.markAttendance(
          faceImagePath: faceImagePath,
        );
        if (!context.mounted) return;

        if (response == null) {
          AppSnackbar.error(context, 'Failed to mark attendance. Please try again.');
          faceCaptureController.rearmCaptureFlow();
          return;
        }
        if (!response.success) {
          AppSnackbar.warning(context, response.message);
          faceCaptureController.rearmCaptureFlow();
          return;
        }

        final employee = response.data.employee;
        final empCode = employee?.empCode ?? '-';
        final empName = employee?.name ?? '-';

        final createdAt = DateTime.tryParse(response.data.createdAt);
        final dateText = createdAt == null
            ? response.data.createdAt
            : '${createdAt.year}-${_twoDigits(createdAt.month)}-${_twoDigits(createdAt.day)}';
        final timeText = createdAt == null
            ? ''
            : '${_twoDigits(createdAt.hour)}:${_twoDigits(createdAt.minute)}:${_twoDigits(createdAt.second)}';

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return _MarkAttendanceSuccessDialog(
              locationName: attendanceState.location?.name ?? 'Unknown location',
              empCode: empCode,
              empName: empName,
              dateText: dateText,
              timeText: timeText,
              onClose: () {
                Navigator.of(dialogContext).pop();
                faceCaptureController.rearmCaptureFlow();
              },
            );
          },
        );
      } finally {
      }
    }

    ref.listen<FaceCaptureState>(
      faceCaptureControllerProvider(FaceCaptureConfig.attendanceFront),
      (previous, next) async {
        final completedNow =
            next.isCaptureComplete && !(previous?.isCaptureComplete ?? false);
        if (!completedNow) return;
        await handleCaptureComplete(next.capturedPhotoByProfile);
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCaptureBody(
            context: context,
            captureState: captureState,
            faceCaptureController: faceCaptureController,
          ),
          if (attendanceState.isLoadingLocation || attendanceState.isMarkingAttendance)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCaptureBody({
    required BuildContext context,
    required FaceCaptureState captureState,
    required FaceCaptureController faceCaptureController,
  }) {
    switch (captureState.status) {
      case CameraStatus.idle:
      case CameraStatus.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      case CameraStatus.permissionDenied:
        return _PermissionDeniedView(
          onRetry: () => faceCaptureController.initialize(
            config: FaceCaptureConfig.attendanceFront,
          ),
        );
      case CameraStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Camera error:\n${captureState.errorMessage}',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case CameraStatus.ready:
        return _CameraReadyView(
          controller: captureState.cameraController!,
          alignState: captureState.alignState,
          progress: captureState.progress,
          currentStep: captureState.currentStep,
          onManualCapture: faceCaptureController.captureCurrentStepManually,
          onBack: () => Navigator.of(context).pop(),
        );
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _CameraReadyView extends StatelessWidget {
  const _CameraReadyView({
    required this.controller,
    required this.alignState,
    required this.progress,
    required this.currentStep,
    required this.onManualCapture,
    required this.onBack,
  });

  final CameraController controller;
  final FaceAlignState alignState;
  final double progress;
  final FaceCaptureStep currentStep;
  final Future<void> Function() onManualCapture;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _SafeCameraPreview(controller: controller),
        FaceOverlayWidget(
          alignState: alignState,
          progress: progress,
          currentStep: currentStep,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: onBack,
            ),
          ),
        ),
        Positioned(
          bottom: 72,
          left: 0,
          right: 0,
          child: const _StepHintText(
            label: 'Look Straight',
            stepText: 'Mark Attendance',
          ),
        ),
        Positioned(
          bottom: 22,
          left: 24,
          right: 24,
          child: FilledButton.icon(
            onPressed: () => onManualCapture(),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Capture Manually'),
          ),
        ),
      ],
    );
  }
}

class _SafeCameraPreview extends StatelessWidget {
  const _SafeCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final value = controller.value;
        if (!value.isInitialized) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        try {
          return controller.buildPreview();
        } on CameraException {
          // Controller may get disposed between frames/lifecycle changes.
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
      },
    );
  }
}

class _StepHintText extends StatelessWidget {
  const _StepHintText({required this.label, required this.stepText});

  final String label;
  final String stepText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          stepText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white38,
              size: 72,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera access is needed\nto mark attendance.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkAttendanceSuccessDialog extends StatefulWidget {
  const _MarkAttendanceSuccessDialog({
    required this.empCode,
    required this.empName,
    required this.locationName,
    required this.dateText,
    required this.timeText,
    required this.onClose,
  });

  final String empCode;
  final String empName;
  final String locationName;
  final String dateText;
  final String timeText;
  final VoidCallback onClose;

  @override
  State<_MarkAttendanceSuccessDialog> createState() => _MarkAttendanceSuccessDialogState();
}

class _MarkAttendanceSuccessDialogState extends State<_MarkAttendanceSuccessDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), widget.onClose);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Attendance marked successfully'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv('Employee Code', widget.empCode),
            _kv('Employee Name', widget.empName),
            _kv('Location', widget.locationName),
            _kv('Date', widget.dateText),
            if (widget.timeText.isNotEmpty) _kv('Time', widget.timeText),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _kv(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$key: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

