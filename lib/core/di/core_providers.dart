import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_config.dart';
import '../logging/app_logger.dart';
import '../network/dio_client.dart';
import '../services/file_picker_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/shared_pref_storage.dart';

const _authTokenKey = 'authToken';

final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('appConfigProvider must be overridden at bootstrap.');
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final sharedPreferencesSyncProvider = Provider<SharedPreferences>((ref) {
  return ref.watch(sharedPreferencesProvider).requireValue;
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  final config = ref.watch(appConfigProvider);
  return AppLogger(enableLogging: config.enableLogging);
});

final dioClientProvider = Provider<DioClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final logger = ref.watch(appLoggerProvider);
  final storage = ref.watch(appStorageProvider);
  return DioClient(
    config,
    logger,
    () async => storage.getString(_authTokenKey),
  );
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionServiceImpl();
});

final mediaServiceProvider = Provider<MediaService>((ref) {
  return MediaServiceImpl(
    ImagePicker(),
    ref.read(appLoggerProvider),
    ref.read(permissionServiceProvider),
  );
});

final mediaPermissionHandlerProvider = Provider<MediaPermissionHandler>(
      (ref) => MediaPermissionHandler(ref.watch(permissionServiceProvider)),
);

final locationPermissionHandlerProvider = Provider<LocationPermissionHandler>(
      (ref) => LocationPermissionHandler(ref.watch(permissionServiceProvider)),
);

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

final fileSelectionServiceProvider =
Provider<FileSelectionService>((ref) {
  return FileSelectionServiceImpl(
    FilePicker.platform,
    ref.read(appLoggerProvider),
  );
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});

final appStorageProvider = Provider<AppStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesSyncProvider);
  return AppStorage(prefs);
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final secureStorage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageServiceImpl(secureStorage);
});
