import '../../../../../core/storage/shared_pref_storage.dart';
import '../../../constants/auth_constants.dart';

class AuthLocalDataSource {
  final AppStorage storage;

  AuthLocalDataSource(this.storage);

  Future<void> saveAuthSession({
    required String token,
    required int orgId,
  }) async {
    await storage.setString(AuthConstants.tokenKey, token);
    await storage.setInt(AuthConstants.orgIdKey, orgId);
  }

  String? getToken() {
    return storage.getString(AuthConstants.tokenKey);
  }

  int? getOrgId() {
    return storage.getInt(AuthConstants.orgIdKey);
  }

  Future<void> clearAuthSession() async {
    await storage.remove(AuthConstants.tokenKey);
    await storage.remove(AuthConstants.orgIdKey);
  }
}