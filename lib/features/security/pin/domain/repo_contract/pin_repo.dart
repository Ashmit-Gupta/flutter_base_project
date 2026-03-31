abstract class PinRepositoryContract {
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> updatePin(String oldPin, String newPin);
  Future<bool> hasPin();
  Future<void> clearPin();
}

