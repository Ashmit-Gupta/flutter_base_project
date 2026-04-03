import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../core/di/core_providers.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/file_picker_service.dart';
import 'models/app_file_model.dart';
import 'models/media_result.dart';

/// Scoped file pick state: each [scopeId] is an isolated list (e.g. per screen/flow).
/// Auto-dispose clears state when the route/provider stops being watched.
final fileControllerProvider = NotifierProvider.autoDispose
    .family<FileController, List<AppFileModel>, String>(FileController.new);

class FileController extends Notifier<List<AppFileModel>> {
  FileController(this.scopeId);

  /// Identifies this flow; not stored in [state], but available for logging/tests.
  final String scopeId;

  FileSelectionService get _fileService => ref.read(fileSelectionServiceProvider);

  MediaService get _mediaService => ref.read(mediaServiceProvider);

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
      _logger.error('[FileController] pickFiles failed', error: e, stackTrace: st);
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
      _logger.error('[FileController] pickFromCamera failed', error: e, stackTrace: st);
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
      _logger.error('[FileController] pickFromGallery failed', error: e, stackTrace: st);
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
      _logger.error('[FileController] pickVideoFromCamera failed', error: e, stackTrace: st);
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

  String? validateFileCount({required int minFiles, required int maxFiles}) {
    final count = state.length;

    if (count < minFiles || count > maxFiles) {
      return 'Select only $minFiles  files.';
    }

    return null;
  }

  // ================= INTERNAL =================

  String? _mergeWithConstraints(List<AppFileModel> incoming, int maxFiles) {
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

  List<AppFileModel> filesForProfile(String profileKey) {
    return state
        .where((file) => file.name.startsWith('${profileKey}_'))
        .toList(growable: false);
  }

  Future<String?> pickFromGalleryForProfile({required String profileKey}) async {
    try {
      final result = await _mediaService.pickImageFromGallery();
      switch (result.status) {
        case MediaResultStatus.success:
          if (result.files.isEmpty) return 'No file selected';
          final first = result.files.first;
          return upsertProfilePhoto(
            profileKey: profileKey,
            photoPath: first.path,
          );
        case MediaResultStatus.cancelled:
          return 'No file selected';
        case MediaResultStatus.permissionDenied:
          return 'Permission denied. Please allow and try again.';
        case MediaResultStatus.error:
          return 'Gallery failed';
      }
    } catch (e, st) {
      _logger.error(
        '[FileController] pickFromGalleryForProfile failed scope=$scopeId',
        error: e,
        stackTrace: st,
      );
      return 'Gallery failed';
    }
  }

  Future<String?> pickFromCameraForProfile({required String profileKey}) async {
    try {
      final result = await _mediaService.captureImage();
      switch (result.status) {
        case MediaResultStatus.success:
          if (result.files.isEmpty) return 'No image captured';
          final first = result.files.first;
          return upsertProfilePhoto(
            profileKey: profileKey,
            photoPath: first.path,
          );
        case MediaResultStatus.cancelled:
          return 'No image captured';
        case MediaResultStatus.permissionDenied:
          return 'Camera permission denied';
        case MediaResultStatus.error:
          return 'Camera failed';
      }
    } catch (e, st) {
      _logger.error(
        '[FileController] pickFromCameraForProfile failed scope=$scopeId',
        error: e,
        stackTrace: st,
      );
      return 'Camera failed';
    }
  }

  String? addCapturedPhotoPath({required String photoPath, required int maxFiles}) {
    final file = File(photoPath);
    if (!file.existsSync()) {
      return 'Captured photo not found.';
    }
    final appFile = AppFileModel(
      name: photoPath.split(Platform.pathSeparator).last,
      path: photoPath,
      size: file.lengthSync(),
    );
    return _mergeWithConstraints(<AppFileModel>[appFile], maxFiles);
  }

  String? addCapturedPhotoPaths({
    required Map<String, String> photoPathByProfile,
    required int maxFiles,
  }) {
    final files = <AppFileModel>[];
    photoPathByProfile.forEach((profileKey, path) {
      final file = File(path);
      if (!file.existsSync()) return;
      files.add(
        AppFileModel(
          name: '${profileKey}_${path.split(Platform.pathSeparator).last}',
          path: path,
          size: file.lengthSync(),
        ),
      );
    });
    if (files.isEmpty) return 'Captured photo not found.';
    return _mergeWithConstraints(files, maxFiles);
  }

  String? upsertProfilePhoto({
    required String profileKey,
    required String photoPath,
  }) {
    final file = File(photoPath);
    if (!file.existsSync()) return 'Selected photo not found.';
    final fileName = photoPath.split(Platform.pathSeparator).last;
    final appFile = AppFileModel(
      name: '${profileKey}_$fileName',
      path: photoPath,
      size: file.lengthSync(),
    );
    final next = state
        .where((f) => !f.name.startsWith('${profileKey}_'))
        .toList(growable: true)
      ..add(appFile);
    state = next;
    _logger.info(
      '[FileController] profile-photo-upserted scope=$scopeId profile=$profileKey path=$photoPath',
    );
    return null;
  }

  void removeProfilePhoto(String profileKey) {
    final before = state.length;
    state = state
        .where((file) => !file.name.startsWith('${profileKey}_'))
        .toList(growable: false);
    final after = state.length;
    _logger.info(
      '[FileController] profile-photo-removed scope=$scopeId profile=$profileKey removed=${before - after}',
    );
  }
}
