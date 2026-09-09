import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

/// Secure storage service for sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Auth tokens
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  Future<void> saveUserData(String userJson) async {
    await _storage.write(key: 'cached_user_data', value: userJson);
  }

  Future<String?> getUserData() async {
    return await _storage.read(key: 'cached_user_data');
  }

  // Remembered user (Username / Phone / Email)
  Future<void> saveRememberedUser(String identifier) async {
    await _storage.write(key: 'remembered_user_identifier', value: identifier);
  }

  Future<String?> getRememberedUser() async {
    return await _storage.read(key: 'remembered_user_identifier');
  }

  Future<void> clearRememberedUser() async {
    await _storage.delete(key: 'remembered_user_identifier');
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userIdKey);
    await _storage.delete(key: 'cached_user_data');
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// Provider for SecureStorageService
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  return SecureStorageService(storage);
});
