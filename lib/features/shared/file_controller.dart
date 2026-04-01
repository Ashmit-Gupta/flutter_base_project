import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/core_providers.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/file_picker_service.dart';
import '../../features/shared/models/app_file_model.dart';
import '../../features/shared/models/media_result.dart';

final fileControllerProvider =
NotifierProvider.autoDispose<FileController, List<AppFileModel>>(
  FileController.new,
);

class FileController extends Notifier<List<AppFileModel>> {
  FileSelectionService get _fileService =>
      ref.read(fileSelectionServiceProvider);

  MediaService get _mediaService =>
      ref.read(mediaServiceProvider);

  AppLogger get _logger => ref.read(appLoggerProvider);

  @override
  List<AppFileModel> build() => [];

  // ================= FILE PICKER =================

  Future<String?> pickFiles({
    required int maxFiles,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  }) async {
    try {
      final files = await _fileService.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (files.isEmpty) return 'No files selected';

      return _mergeWithConstraints(files, maxFiles);
    } catch (e, st) {
      _logger.error(
        '[FileController] pickFiles failed',
        error: e,
        stackTrace: st,
      );
      return 'Failed to pick files';
    }
  }

  // ================= CAMERA =================

  Future<String?> pickFromCamera({required int maxFiles}) async {
    try {
      final result = await _mediaService.captureImage();

      switch (result.status) {
        case MediaResultStatus.success:
          return _mergeWithConstraints(result.files, maxFiles);

        case MediaResultStatus.cancelled:
          return 'No image captured';

        case MediaResultStatus.permissionDenied:
          return 'Camera permission denied';

        case MediaResultStatus.error:
          return 'Camera failed';
      }
    } catch (e, st) {
      _logger.error(
        '[FileController] pickFromCamera failed',
        error: e,
        stackTrace: st,
      );
      return 'Camera failed';
    }
  }

  // ================= GALLERY =================

  Future<String?> pickFromGallery({required int maxFiles}) async {
    try {
      final result = await _mediaService.pickImageFromGallery();

      switch (result.status) {
        case MediaResultStatus.success:
          return _mergeWithConstraints(result.files, maxFiles);

        case MediaResultStatus.cancelled:
          return 'No file selected';

        case MediaResultStatus.permissionDenied:
          return 'Permission denied. Please allow and try again.';

        case MediaResultStatus.error:
          return 'Gallery failed';
      }
    } catch (e, st) {
      _logger.error(
        '[FileController] pickFromGallery failed',
        error: e,
        stackTrace: st,
      );
      return 'Gallery failed';
    }
  }

  // ================= VIDEO =================

  Future<String?> pickVideoFromCamera({required int maxFiles}) async {
    try {
      final result = await _mediaService.captureVideo();

      switch (result.status) {
        case MediaResultStatus.success:
          return _mergeWithConstraints(result.files, maxFiles);

        case MediaResultStatus.cancelled:
          return 'No video recorded';

        case MediaResultStatus.permissionDenied:
          return 'Camera permission denied';

        case MediaResultStatus.error:
          return 'Video capture failed';
      }
    } catch (e, st) {
      _logger.error(
        '[FileController] pickVideoFromCamera failed',
        error: e,
        stackTrace: st,
      );
      return 'Video capture failed';
    }
  }

  // ================= STATE =================

  void removeFile(int index) {
    if (index < 0 || index >= state.length) return;

    final next = [...state]..removeAt(index);
    state = next;
  }

  void clear() => state = [];

  String? validateFileCount({
    required int minFiles,
    required int maxFiles,
  }) {
    final count = state.length;

    if (count < minFiles || count > maxFiles) {
      return 'Select between $minFiles and $maxFiles files.';
    }

    return null;
  }

  // ================= INTERNAL =================

  String? _mergeWithConstraints(
      List<AppFileModel> incoming, int maxFiles) {
    final merged = [...state];
    final seen = merged.map(_identity).toSet();

    int duplicates = 0;

    for (final file in incoming) {
      final id = _identity(file);

      if (seen.contains(id)) {
        duplicates++;
        continue;
      }

      merged.add(file);
      seen.add(id);
    }

    String? message;

    if (merged.length > maxFiles) {
      merged.removeRange(maxFiles, merged.length);
      message = 'Only $maxFiles file(s) allowed';
    }

    state = merged;

    if (state.isEmpty) return 'No files selected';
    if (message != null) return message;
    if (duplicates > 0) return '$duplicates duplicate(s) skipped';

    return '${state.length} file(s) selected';
  }

  String _identity(AppFileModel file) {
    return '${file.name}|${file.path}|${file.size}';
  }
}