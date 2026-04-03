import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/app_theme_extension.dart';
import '../../features/shared/file_controller.dart';
import '../../features/face_detection/presentation/model/face_capture_config.dart';
import '../../features/face_detection/presentation/controller/face_capture_controller.dart';
import '../../features/shared/models/app_file_model.dart';
import '../design/app_radius.dart';
import '../design/app_spacing.dart';
import '../di/core_providers.dart';
import '../feedback/app_snackbar.dart';

int? _lastLoggedFilePickerCount;

class FilePickerWidget extends ConsumerWidget {
  const FilePickerWidget({super.key, this.title = 'Add Attachment', this.fileTypesHint = 'Photos from gallery or camera', required this.maxFiles, this.profileKey});

  final String title;
  final String fileTypesHint;
  final int maxFiles;
  final String? profileKey;

  Future<void> _showMediaPickerSheet(BuildContext context, WidgetRef ref) async {
    final fileController = ref.read(fileControllerProvider.notifier);
    final logger = ref.read(appLoggerProvider);

    final selectedAction = await showModalBottomSheet<_MediaPickerAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final sheetColors = sheetContext.theme.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DecoratedBox(
              decoration: BoxDecoration(color: sheetColors.surface, borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('Add photos', style: sheetContext.text.title().copyWith(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: Text(
                        'Choose from gallery or take a photo (images only)',
                        textAlign: TextAlign.center,
                        style: sheetContext.text.body().copyWith(color: sheetColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // --- Disabled: generic file / document picker (PDF, etc.) — flow is images only.
                    // _MediaActionTile(
                    //   icon: Icons.folder_outlined,
                    //   title: 'Select Files',
                    //   subtitle: 'Browse and select from device storage',
                    //   onTap: () {
                    //     Navigator.of(sheetContext).pop(_MediaPickerAction.files);
                    //   },
                    // ),
                    // const SizedBox(height: AppSpacing.sm),
                    _MediaActionTile(
                      icon: Icons.photo_library_outlined,
                      title: 'Pick from Gallery',
                      subtitle: 'Choose photos from your gallery',
                      onTap: () {
                        Navigator.of(sheetContext).pop(_MediaPickerAction.gallery);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MediaActionTile(
                      icon: Icons.photo_camera_outlined,
                      title: 'Capture Photo',
                      subtitle: 'Take a new photo with camera',
                      onTap: () {
                        Navigator.of(sheetContext).pop(_MediaPickerAction.camera);
                      },
                    ),
                    // --- Disabled: video capture — flow is images only.
                    // const SizedBox(height: AppSpacing.sm),
                    // _MediaActionTile(
                    //   icon: Icons.videocam_outlined,
                    //   title: 'Record Video',
                    //   subtitle: 'Record a new video with camera',
                    //   onTap: () {
                    //     Navigator.of(sheetContext).pop(_MediaPickerAction.video);
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    String? message;
    switch (selectedAction) {
      // --- Disabled: document / any file type — images only (see bottom sheet).
      // case _MediaPickerAction.files:
      //   message = await fileController.pickFiles(
      //     maxFiles: maxFiles,
      //     type: FileType.any,
      //     allowMultiple: true,
      //   );
      //   break;
      case _MediaPickerAction.gallery:
        if (profileKey != null) {
          logger.info('[FilePickerWidget] gallery-open profile=$profileKey');
          message = await fileController.pickFromGalleryForProfile(profileKey: profileKey!);
        } else {
          message = await fileController.pickFromGallery(maxFiles: maxFiles);
        }
        break;
      case _MediaPickerAction.camera:
        if (profileKey != null) {
          logger.info('[FilePickerWidget] face-capture-open profile=$profileKey');
          final step = switch (profileKey!) {
            'left_profile' => FaceCaptureStep.left,
            'right_profile' => FaceCaptureStep.right,
            _ => FaceCaptureStep.front,
          };
          final capturedMap = await context.push<Map<String, String>>(AppRoutes.faceCapture, extra: FaceCaptureConfig.single(step));
          if (capturedMap != null && capturedMap.isNotEmpty) {
            logger.info('[FilePickerWidget] face-capture-success profile=$profileKey keys=${capturedMap.keys.join(",")}');
            capturedMap.forEach((key, path) {
              fileController.upsertProfilePhoto(profileKey: key, photoPath: path);
            });
            message = 'Photo captured successfully';
          } else {
            logger.info('[FilePickerWidget] face-capture-cancelled profile=$profileKey');
            fileController.removeProfilePhoto(profileKey!);
            message = null;
          }
        } else {
          final capturedMap = await context.push<Map<String, String>>(AppRoutes.faceCapture, extra: const FaceCaptureConfig.allProfiles());
          if (capturedMap != null && capturedMap.isNotEmpty) {
            message = fileController.addCapturedPhotoPaths(photoPathByProfile: capturedMap, maxFiles: maxFiles);
          } else {
            message = null;
          }
        }
        break;
      // --- Disabled: camera video — images only.
      // case _MediaPickerAction.video:
      //   message = await fileController.pickVideoFromCamera(maxFiles: maxFiles);
      //   break;
      case null:
        if (profileKey != null) {
          logger.info('[FilePickerWidget] picker-sheet-dismissed profile=$profileKey');
        }
        message = null;
        break;
    }

    if (message != null && context.mounted) {
      AppSnackbar.info(context, message);
    }
  }

  // ================= IMAGE THUMBNAIL =================

  Widget _buildImageThumbnail(BuildContext context, AppFileModel file, int index, void Function(int) onRemoveFile) {
    final colors = context.theme.colors;

    Widget imageChild;

    if (file.path.isNotEmpty && File(file.path).existsSync()) {
      imageChild = Image.file(File(file.path), fit: BoxFit.cover);
    } else {
      imageChild = Center(child: Icon(Icons.broken_image_rounded, color: colors.textSecondary));
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (file.path.isEmpty || !File(file.path).existsSync()) {
                return;
              }
              context.push(
                AppRoutes.employeeImagePreview,
                extra: PlatformFile(name: '', path: file.path, size: file.size),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(width: 88, height: 88, child: imageChild),
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
              child: Text('${index + 1}', style: context.text.caption().copyWith(color: Colors.white)),
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Material(
            color: colors.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onRemoveFile(index),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, size: 16, color: colors.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isImage(AppFileModel file) {
    final parts = file.name.split('.');
    if (parts.length < 2) return false;

    final ext = parts.last.toLowerCase();
    return const {'png', 'jpg', 'jpeg', 'webp'}.contains(ext);
  }

  String _statusLine(List<AppFileModel> files, WidgetRef ref) {
    final count = files.length;
    if (_lastLoggedFilePickerCount != count) {
      _lastLoggedFilePickerCount = count;
      ref.read(appLoggerProvider).info('[FilePickerWidget] files selected: $count');
    }
    if (files.isEmpty) return 'No files selected.';
    // if (files.length == 1) return '1 file selected';
    // return '${files.length} files selected';
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final accent = colors.primary;
    final files = profileKey == null ? ref.watch(fileControllerProvider) : ref.watch(fileControllerProvider.select((all) => all.where((f) => f.name.startsWith('${profileKey!}_')).toList(growable: false)));
    final fileController = ref.read(fileControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.title().copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => _showMediaPickerSheet(context, ref),
              child: CustomPaint(
                painter: _DashedRRectPainter(color: accent, borderRadius: AppRadius.md, dashWidth: 6, dashGap: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_rounded, size: 40, color: accent),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Click to Upload',
                          style: context.text.body().copyWith(color: accent, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: accent),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          fileTypesHint,
                          textAlign: TextAlign.center,
                          style: context.text.caption().copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (files.isNotEmpty) ...[
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (var index = 0; index < files.length; index++)
                  if (_isImage(files[index]))
                    _buildImageThumbnail(context, files[index], index, (idx) {
                      if (profileKey != null) {
                        ref.read(appLoggerProvider).info('[FilePickerWidget] profile-remove-tap profile=$profileKey');
                        fileController.removeProfilePhoto(profileKey!);
                      } else {
                        fileController.removeFile(idx);
                      }
                    }),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Center(
            child: Text(
              _statusLine(files, ref),
              textAlign: TextAlign.center,
              style: context.text.body().copyWith(color: files.isEmpty ? colors.textPrimary : colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet actions. Only gallery and camera are active; document pick and
/// video capture are commented out in the sheet and switch (images-only flow).
enum _MediaPickerAction { gallery, camera }

class _MediaActionTile extends StatelessWidget {
  const _MediaActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Material(
      color: colors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.text.body().copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.text.caption().copyWith(color: colors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DASHED BORDER =================

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.borderRadius, required this.dashWidth, required this.dashGap});

  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderRadius != borderRadius || oldDelegate.dashWidth != dashWidth || oldDelegate.dashGap != dashGap;
  }
}
