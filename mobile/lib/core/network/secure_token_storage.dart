import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// MOB-03: Token disimpan di secure storage (Keychain/Keystore) melalui flutter_secure_storage
class SecureTokenStorage {
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryFallback = {};

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'sqlquest_access_token';
  static const _refreshTokenKey = 'sqlquest_refresh_token';
  static const _userIdKey = 'sqlquest_user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    _memoryFallback[_accessTokenKey] = accessToken;
    _memoryFallback[_refreshTokenKey] = refreshToken;
    _memoryFallback[_userIdKey] = userId;
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      await _storage.write(key: _userIdKey, value: userId);
    } catch (_) {
      // Fallback to in-memory storage during headless/widget tests
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      return token ?? _memoryFallback[_accessTokenKey];
    } catch (_) {
      return _memoryFallback[_accessTokenKey];
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      return token ?? _memoryFallback[_refreshTokenKey];
    } catch (_) {
      return _memoryFallback[_refreshTokenKey];
    }
  }

  Future<String?> getUserId() async {
    try {
      final id = await _storage.read(key: _userIdKey);
      return id ?? _memoryFallback[_userIdKey];
    } catch (_) {
      return _memoryFallback[_userIdKey];
    }
  }

  Future<void> clearTokens() async {
    _memoryFallback.clear();
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _userIdKey);
    } catch (_) {}
  }
}
