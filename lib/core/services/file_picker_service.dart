import 'dart:io';

import 'package:basic_project_setup/core/services/permission_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/shared/models/app_file_model.dart';
import '../../features/shared/models/media_result.dart';
import '../logging/app_logger.dart';

abstract class FileSelectionService {
  Future<List<AppFileModel>> pickFiles({
    FileType type,
    List<String>? allowedExtensions,
    bool allowMultiple,
  });
}

abstract class MediaService {
  Future<MediaResult> captureImage();
  Future<MediaResult> pickImageFromGallery();
  Future<MediaResult> captureVideo();
}

class MediaServiceImpl implements MediaService {
  final ImagePicker _picker;
  final AppLogger _logger;
  final PermissionService _permissionService;

  MediaServiceImpl(this._picker, this._logger, this._permissionService);

  @override
  Future<MediaResult> captureImage() async {
    try {
      final permission =
      await _permissionService.request(AppPermission.camera);

      if (permission != PermissionResult.granted) {
        _logger.warning('[MediaService] Camera permission denied: $permission');
        return MediaResult.permissionDenied();
      }

      final file = await _picker.pickImage(source: ImageSource.camera);

      if (file == null) {
        _logger.warning('[MediaService] captureImage cancelled');
        return MediaResult.cancelled();
      }

      return MediaResult.single(await mapXFile(file));
    } catch (e, st) {
      _logger.error(
        '[MediaService] captureImage failed',
        error: e,
        stackTrace: st,
      );
      return MediaResult.error(e);
    }
  }

  @override
  Future<MediaResult> pickImageFromGallery() async {
    try {
      final permission =
      await _permissionService.request(AppPermission.storage);

      if (permission != PermissionResult.granted) {
        _logger.warning('[MediaService] Gallery permission denied');
        return MediaResult.permissionDenied();
      }

      final file = await _picker.pickImage(source: ImageSource.gallery);

      if (file == null) {
        return MediaResult.cancelled();
      }

      return MediaResult.single(await mapXFile(file));
    } catch (e, st) {
      _logger.error(
        '[MediaService] pickImageFromGallery failed',
        error: e,
        stackTrace: st,
      );

      return MediaResult.error(e);
    }
  }

  @override
  Future<MediaResult> captureVideo() async {
    try {
      final permission =
      await _permissionService.request(AppPermission.camera);

      if (permission != PermissionResult.granted) {
        _logger.warning('[MediaService] Camera permission denied: $permission');
        return MediaResult.permissionDenied();
      }

      final file = await _picker.pickVideo(source: ImageSource.camera);

      if (file == null) {
        return MediaResult.cancelled();
      }

      return MediaResult.single(await mapXFile(file));
    } catch (e, st) {
      _logger.error(
        '[MediaService] captureVideo failed',
        error: e,
        stackTrace: st,
      );
      return MediaResult.error(e);
    }
  }
}

class FileSelectionServiceImpl implements FileSelectionService {
  final FilePicker _picker;
  final AppLogger _logger;

  FileSelectionServiceImpl(this._picker, this._logger);

  @override
  Future<List<AppFileModel>> pickFiles({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  }) async {
    try {
      final result = await _picker.pickFiles(
        type: type,
        allowedExtensions:
        type == FileType.custom ? allowedExtensions : null,
        allowMultiple: allowMultiple,
      );

      if (result == null) return [];

      return result.files.map((f) {
        return AppFileModel(
          name: f.name,
          path: f.path ?? '',
          size: f.size,
        );
      }).toList();
    } catch (e, st) {
      _logger.error(
        '[FileSelectionService] failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}