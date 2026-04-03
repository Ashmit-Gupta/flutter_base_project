import 'package:flutter/material.dart';

import '../model/face_capture_config.dart';
import '../widgets/face_capture_widget.dart';

class FaceCaptureScreen extends StatelessWidget {
  const FaceCaptureScreen({
    super.key,
    this.config = const FaceCaptureConfig.allProfiles(),
  });

  final FaceCaptureConfig config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FaceCaptureWidget(
        config: config,
        showBackButton: true,
        onBack: () => Navigator.of(context).pop(),
        showManualCaptureButton: true,
        onCaptureComplete: (capturedPhotoByProfile) {
          Navigator.of(context).pop(capturedPhotoByProfile);
        },
      ),
    );
  }
}
