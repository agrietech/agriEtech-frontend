///
/// @file secure_storage_service.dart
/// @description Encrypted storage service for auth tokens and farmer credentials.
/// @author Security / Storage Lead
///
library secure_storage_service;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async => await _storage.write(key: 'jwt_token', value: token);
  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');
  Future<void> deleteToken() async => await _storage.delete(key: 'jwt_token');
}
