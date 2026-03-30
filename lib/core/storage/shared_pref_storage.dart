import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  final SharedPreferences prefs;

  AppStorage(this.prefs);

  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await prefs.remove(key);
  }
}