import 'app_file_model.dart';

enum MediaResultStatus {
  success,
  cancelled,
  permissionDenied,
  error,
}

class MediaResult {
  final MediaResultStatus status;
  final List<AppFileModel> files;
  final Object? error;

  const MediaResult._({
    required this.status,
    required this.files,
    this.error,
  });

  // ✅ SUCCESS (always list, even for single file)
  factory MediaResult.success(List<AppFileModel> files) {
    return MediaResult._(
      status: MediaResultStatus.success,
      files: files,
    );
  }

  // ✅ Helper for single file (VERY useful)
  factory MediaResult.single(AppFileModel file) {
    return MediaResult._(
      status: MediaResultStatus.success,
      files: [file],
    );
  }

  // ✅ CANCELLED
  factory MediaResult.cancelled() {
    return const MediaResult._(
      status: MediaResultStatus.cancelled,
      files: [],
    );
  }

  // ✅ PERMISSION DENIED
  factory MediaResult.permissionDenied() {
    return const MediaResult._(
      status: MediaResultStatus.permissionDenied,
      files: [],
    );
  }

  // ✅ ERROR
  factory MediaResult.error(Object error) {
    return MediaResult._(
      status: MediaResultStatus.error,
      files: [],
      error: error,
    );
  }

  // ✅ Convenience getters (optional but powerful)
  bool get isSuccess => status == MediaResultStatus.success;
  bool get isEmpty => files.isEmpty;
}