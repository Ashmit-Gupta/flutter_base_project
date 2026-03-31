import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PinHasher {
  static const _iterations = 10000;

  String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(values);
  }

  String hashPin(String pin, String salt) {
    final key = utf8.encode(pin);
    final saltBytes = base64Decode(salt);

    List<int> result = key;

    for (int i = 0; i < _iterations; i++) {
      result = sha256.convert([...result, ...saltBytes]).bytes;
    }

    return base64Encode(result);
  }

  bool verify(String pin, String salt, String storedHash) {
    final newHash = hashPin(pin, salt);
    return newHash == storedHash;
  }
}