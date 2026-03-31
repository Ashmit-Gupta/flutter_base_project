import 'package:basic_project_setup/features/security/pin/domain/repo_contract/pin_repo.dart';

import '../../../../../core/security/pin_hasher.dart';
import '../data_source/pin_local_data_source.dart';
import '../model/pin_data_model.dart';

class PinRepositoryImpl implements PinRepositoryContract {
  final PinLocalDataSource local;
  final PinHasher hasher;

  PinRepositoryImpl({
    required this.local,
    required this.hasher,
  });

  @override
  Future<void> setPin(String pin) async {
    _validatePin(pin);

    final salt = hasher.generateSalt();
    final hash = hasher.hashPin(pin, salt);

    await local.save(PinData(hash: hash, salt: salt));
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final data = await local.get();
    if (data == null) return false;

    return hasher.verify(pin, data.salt, data.hash);
  }

  @override
  Future<void> updatePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);

    if (!isValid) {
      throw Exception('Invalid old PIN');
    }

    await setPin(newPin);
  }

  @override
  Future<bool> hasPin() async {
    final data = await local.get();
    return data != null;
  }

  @override
  Future<void> clearPin() async {
    await local.clear();
  }

  void _validatePin(String pin) {
    if (pin.length < 4) {
      throw Exception('PIN must be at least 4 digits');
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      throw Exception('PIN must contain only digits');
    }
  }
}