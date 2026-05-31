import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'qash_secure_storage',
      publicKey: 'qash_public_key',
    ),
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<void> writeString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readString(String key) async {
    return _storage.read(key: key);
  }

  Future<void> writeBool(String key, bool value) async {
    await _storage.write(key: key, value: value ? '1' : '0');
  }

  Future<bool?> readBool(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) {
      return null;
    }
    if (raw == '1' || raw.toLowerCase() == 'true') {
      return true;
    }
    if (raw == '0' || raw.toLowerCase() == 'false') {
      return false;
    }
    return null;
  }
}
