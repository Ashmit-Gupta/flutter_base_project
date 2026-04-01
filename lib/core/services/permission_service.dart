import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

enum AppPermission {
  camera,
  storage,
}

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}

abstract class PermissionService {
  Future<PermissionResult> request(AppPermission permission);
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<PermissionResult> request(AppPermission permission) async {
    final perm = _map(permission);

    // ✅ 1. Avoid unnecessary request
    if (await perm.isGranted) {
      return PermissionResult.granted;
    }

    // ✅ 2. Request only if needed
    final status = await perm.request();

    return _mapResult(status);
  }

  Permission _map(AppPermission permission) {
    switch (permission) {
      case AppPermission.camera:
        return Permission.camera;

      case AppPermission.storage:
        if (Platform.isAndroid) {
          // ✅ Most stable across Android versions
          return Permission.storage;
        }
        return Permission.photos; // iOS
    }
  }

  PermissionResult _mapResult(PermissionStatus status) {
    if (status.isGranted) return PermissionResult.granted;

    if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }
}

class MediaPermissionHandler {
  final PermissionService _permission;

  MediaPermissionHandler(this._permission);

  Future<PermissionResult> ensureCameraAccess() {
    return _permission.request(AppPermission.camera);
  }

  Future<PermissionResult> ensureStorageAccess() {
    return _permission.request(AppPermission.storage);
  }
}