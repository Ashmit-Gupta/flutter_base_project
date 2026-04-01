import '../../../../../core/storage/secure_storage_service.dart';
import '../model/pin_data_model.dart';

abstract class PinLocalDataSource {
  Future<void> save(PinData data);
  Future<PinData?> get();
  Future<void> clear();
}


class PinLocalDataSourceImpl implements PinLocalDataSource {
  final SecureStorageService storage;

  static const _pinKey = 'pin_data_v1';

  PinLocalDataSourceImpl(this.storage);

  @override
  Future<void> save(PinData data) async {
    final value = '${data.hash}:${data.salt}';

    try {
      await storage.write(_pinKey, value);
    } catch (e) {
      throw Exception('Failed to save PIN data');
    }
  }

  @override
  Future<PinData?> get() async {
    try {
      final value = await storage.read(_pinKey);

      if (value == null) return null;

      final parts = value.split(':');
      if (parts.length != 2) {
        // corrupted state → treat as no PIN
        await clear();
        return null;
      }

      return PinData(
        hash: parts[0],
        salt: parts[1],
      );
    } catch (e) {
      throw Exception('Failed to read PIN data');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await storage.delete(_pinKey);
    } catch (e) {
      throw Exception('Failed to clear PIN');
    }
  }
}