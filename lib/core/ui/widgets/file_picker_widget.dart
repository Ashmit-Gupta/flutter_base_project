import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../design/app_radius.dart';
import '../../design/app_spacing.dart';
import '../models/picked_file.dart';

/// Core file picker: **no** Riverpod, **no** feature imports.
/// Features wire [onGallery]/[onCamera], navigation, and snackbars via callbacks.
class FilePickerWidget extends StatelessWidget {
  const FilePickerWidget({
    super.key,
    required this.title,
    this.fileTypesHint = 'Photos from gallery or camera',
    required this.maxFiles,
    required this.files,
    required this.onGallery,
    required this.onCamera,
    required this.onRemoveAt,
    this.onPreviewTap,
    this.onUserMessage,
  });

  final String title;
  final String fileTypesHint;
  final int maxFiles;

  /// Files already selected for this slot (caller filters by profile if needed).
  final List<PickedFile> files;

  final Future<String?> Function() onGallery;
  final Future<String?> Function() onCamera;

  /// Remove file at index within [files] (local indices).
  final void Function(int index) onRemoveAt;

  final void Function(PickedFile file)? onPreviewTap;

  /// Optional feedback (e.g. snackbar) for picker messages.
  final void Function(String message)? onUserMessage;

  Future<void> _showMediaPickerSheet(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<_MediaPickerAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Add photos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Center(
                      child: Text(
                        'Choose from gallery or take a photo (images only)',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _MediaActionTile(
                      icon: Icons.photo_library_outlined,
                      title: 'Pick from Gallery',
                      subtitle: 'Choose photos from your gallery',
                      onTap: () =>
                          Navigator.of(sheetContext).pop(_MediaPickerAction.gallery),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MediaActionTile(
                      icon: Icons.photo_camera_outlined,
                      title: 'Capture Photo',
                      subtitle: 'Take a new photo with camera',
                      onTap: () =>
                          Navigator.of(sheetContext).pop(_MediaPickerAction.camera),
                    ),
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
      case _MediaPickerAction.gallery:
        message = await onGallery();
        break;
      case _MediaPickerAction.camera:
        message = await onCamera();
        break;
      case null:
        message = null;
        break;
    }

    if (message != null && context.mounted) {
      onUserMessage?.call(message);
    }
  }

  bool _isImage(PickedFile file) {
    final parts = file.name.split('.');
    if (parts.length < 2) return false;
    return const {'png', 'jpg', 'jpeg', 'webp'}.contains(parts.last.toLowerCase());
  }

  Widget _buildImageThumbnail(
    BuildContext context,
    PickedFile file,
    int index,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPreviewTap == null
                ? null
                : () {
                    if (file.path.isEmpty) return;
                    onPreviewTap!(file);
                  },
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 88,
                height: 88,
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
              ),
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
              onTap: () => onRemoveAt(index),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => _showMediaPickerSheet(context),
              child: CustomPaint(
                painter: _DashedRRectPainter(
                  color: accent,
                  borderRadius: AppRadius.md,
                  dashWidth: 6,
                  dashGap: 4,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                    horizontal: AppSpacing.md,
                  ),
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: accent,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          fileTypesHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (var i = 0; i < files.length; i++)
                  if (_isImage(files[i]))
                    _buildImageThumbnail(context, files[i], i),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum _MediaPickerAction { gallery, camera }

class _MediaActionTile extends StatelessWidget {
  const _MediaActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
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
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashGap,
  });

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
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.borderRadius != borderRadius ||
      old.dashWidth != dashWidth ||
      old.dashGap != dashGap;
}
