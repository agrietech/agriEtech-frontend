import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';
import '../error/app_error.dart';
import '../utils/logger.dart';

/// Authentication repository
class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  /// Login user with email or phone and password
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final identifier = (request.email ?? request.phone ?? request.identifier ?? '').trim();
      final isEmail = identifier.contains('@');
      final formattedPhone = !isEmail ? _normalizePhone(identifier) : null;
      AppLogger.info('Attempting login for: ${isEmail ? identifier : formattedPhone}');
      final loginData = <String, dynamic>{
        'password': request.password,
        if (isEmail) 'email': identifier,
        if (!isEmail) 'phoneNumber': formattedPhone,
        if (!isEmail) 'phone': formattedPhone,
        'identifier': identifier,
        if (request.deviceToken != null) 'deviceToken': request.deviceToken,
      };
      final response = await _dioClient.post(
        ApiConstants.login, data: loginData,
      );

      // Backend wraps response in { success, data: { accessToken, refreshToken, user } }
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      
      final accessToken = (rawData['accessToken'] ?? rawData['token'] ?? rawData['tokens']?['accessToken'] ?? '').toString();
      final refreshToken = (rawData['refreshToken'] ?? rawData['tokens']?['refreshToken'] ?? '').toString();
      final userData = rawData['user'] is Map ? rawData['user'] as Map<String, dynamic> : rawData;
      
      final normalizedUser = Map<String, dynamic>.from(userData);
      if (!normalizedUser.containsKey('phone') && normalizedUser.containsKey('phoneNumber')) {
        normalizedUser['phone'] = normalizedUser['phoneNumber'];
      }
      if (!normalizedUser.containsKey('role') || normalizedUser['role'] == null) {
        normalizedUser['role'] = 'FARMER';
      }
      if (!normalizedUser.containsKey('fullName') || normalizedUser['fullName'] == null) {
        normalizedUser['fullName'] = normalizedUser['name'] ?? 'User';
      }
      if (!normalizedUser.containsKey('id') || normalizedUser['id'] == null) {
        normalizedUser['id'] = normalizedUser['_id'] ?? '';
      }
      
      final user = UserModel.fromJson(normalizedUser);
      final loginResponse = LoginResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );

      // Save authentication tokens & user profile locally for offline persistence
      if (accessToken.isNotEmpty) {
        await _storage.saveAccessToken(accessToken);
      }
      if (refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }
      await _storage.saveUserId(user.id);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      AppLogger.info('Login successful for user: ${user.id}');
      
      return loginResponse;
    } on DioException catch (e) {
      AppLogger.error('Login failed', e);
      throw _handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected login error', e, stackTrace);
      throw UnknownError(message: 'Login failed: ${e.toString()}');
    }
  }

  String _normalizePhone(String phone) {
    final clean = phone.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if ((clean.startsWith('09') || clean.startsWith('07')) && clean.length == 10) {
      return '+251${clean.substring(1)}';
    }
    if (clean.startsWith('251') && clean.length == 12) {
      return '+$clean';
    }
    return clean;
  }

  /// Register new user
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final formattedPhone = _normalizePhone(request.phone);
      AppLogger.info('Attempting registration for phone: $formattedPhone');
      
      final regData = <String, dynamic>{
        'phone': formattedPhone,
        'phoneNumber': formattedPhone,
        'password': request.password,
        'fullName': request.fullName,
        'role': request.role ?? 'FARMER',
        if (request.email != null && request.email!.isNotEmpty) 'email': request.email,
        if (request.regionId != null && request.regionId!.isNotEmpty) 'regionId': request.regionId,
        if (request.zoneId != null && request.zoneId!.isNotEmpty) 'zoneId': request.zoneId,
        if (request.woredaId != null && request.woredaId!.isNotEmpty) 'woredaId': request.woredaId,
        if (request.kebeleId != null && request.kebeleId!.isNotEmpty) 'kebeleId': request.kebeleId,
        if (request.kebeleName != null && request.kebeleName!.isNotEmpty) 'kebeleName': request.kebeleName,
        if (request.preferredLang != null && request.preferredLang!.isNotEmpty) 'preferredLang': request.preferredLang,
        if (request.deviceToken != null && request.deviceToken!.isNotEmpty) 'deviceToken': request.deviceToken,
      };

      final response = await _dioClient.post(
        ApiConstants.register, data: regData,
      );

      // Backend wraps response in { success, data: { accessToken, refreshToken, user } }
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      
      final accessToken = (rawData['accessToken'] ?? rawData['token'] ?? rawData['tokens']?['accessToken'] ?? '').toString();
      final refreshToken = (rawData['refreshToken'] ?? rawData['tokens']?['refreshToken'] ?? '').toString();
      final userData = rawData['user'] is Map ? rawData['user'] as Map<String, dynamic> : rawData;

      final normalizedUser = Map<String, dynamic>.from(userData);
      if (!normalizedUser.containsKey('phone') && normalizedUser.containsKey('phoneNumber')) {
        normalizedUser['phone'] = normalizedUser['phoneNumber'];
      }
      if (!normalizedUser.containsKey('role') || normalizedUser['role'] == null) {
        normalizedUser['role'] = 'FARMER';
      }
      if (!normalizedUser.containsKey('fullName') || normalizedUser['fullName'] == null) {
        normalizedUser['fullName'] = normalizedUser['name'] ?? request.fullName;
      }
      if (!normalizedUser.containsKey('id') || normalizedUser['id'] == null) {
        normalizedUser['id'] = normalizedUser['_id'] ?? '';
      }

      final user = UserModel.fromJson(normalizedUser);
      final loginResponse = LoginResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );

      // Save authentication tokens & user profile locally for offline persistence
      if (accessToken.isNotEmpty) {
        await _storage.saveAccessToken(accessToken);
      }
      if (refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }
      await _storage.saveUserId(user.id);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      AppLogger.info('Registration successful for user: ${user.id}');
      
      return loginResponse;
    } on DioException catch (e) {
      AppLogger.error('Registration failed', e);
      
      // Handle validation errors
      if (e.response?.statusCode == 422 && e.response?.data is Map) {
        throw ValidationError.fromResponse(e.response!.data);
      }
      
      throw _handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected registration error', e, stackTrace);
      throw UnknownError(message: 'Registration failed: ${e.toString()}');
    }
  }

  /// Get current user profile (with automatic local offline caching)
  Future<UserModel> getProfile() async {
    try {
      AppLogger.info('Fetching user profile');
      
      final response = await _dioClient.get(ApiConstants.profile);
      
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(rawData);
      
      // Cache latest profile locally
      await _storage.saveUserData(jsonEncode(user.toJson()));
      AppLogger.info('Profile fetched and cached successfully for user: ${user.id}');
      
      return user;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch profile', e);
      
      if (e.response?.statusCode == 401) {
        throw AuthError.tokenExpired();
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected profile fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    try {
      AppLogger.info('Updating user profile', updates);
      final response = await _dioClient.put(
        ApiConstants.profile,
        data: updates,
      );
      final userData = response.data['user'] ?? response.data;
      final updatedUser = UserModel.fromJson(userData as Map<String, dynamic>);
      await _storage.saveUserData(jsonEncode(updatedUser.toJson()));
      return updatedUser;
    } on DioException catch (e) {
      AppLogger.error('Failed to update profile', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected profile update error', e, stackTrace);
      throw UnknownError(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  /// Get locally cached user profile for offline session continuity
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonStr = await _storage.getUserData();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserModel.fromJson(map);
      }
    } catch (e) {
      AppLogger.warning('Failed to parse cached user data: $e');
    }
    return null;
  }

  /// Update user password
  Future<void> updatePassword(UpdatePasswordRequest request) async {
    try {
      AppLogger.info('Attempting password update');
      
      await _dioClient.patch(
        ApiConstants.updatePassword, data: request.toJson(),
      );

      AppLogger.info('Password updated successfully');
    } on DioException catch (e) {
      AppLogger.error('Password update failed', e);
      
      if (e.response?.statusCode == 401) {
        throw AuthError.invalidCredentials();
      } else if (e.response?.statusCode == 422) {
        throw ValidationError.fromResponse(e.response!.data);
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected password update error', e, stackTrace);
      throw UnknownError(message: 'Failed to update password: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<String> refreshAccessToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken == null) {
        throw AuthError.tokenExpired();
      }

      AppLogger.info('Refreshing access token');
      
      final response = await _dioClient.post(
        ApiConstants.refreshToken, data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String?;

      await _storage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _storage.saveRefreshToken(newRefreshToken);
      }

      AppLogger.info('Access token refreshed successfully');
      
      return newAccessToken;
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed', e);
      
      // Clear tokens on refresh failure
      await _storage.clearAuth();
      
      throw AuthError.tokenExpired();
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected token refresh error', e, stackTrace);
      throw AuthError.tokenExpired();
    }
  }

  /// Update device FCM token
  Future<void> updateDeviceToken(String token) async {
    try {
      AppLogger.info('Updating device token', {'token': token});

      await _dioClient.post(
        '/auth/device-token',
        data: {'deviceToken': token},
      );

      AppLogger.success('Device token updated');
    } on DioException catch (e) {
      AppLogger.error('Failed to update device token', e);
      // Don't throw - non-critical failure
    } catch (e) {
      AppLogger.error('Unexpected error updating device token', e);
      // Don't throw - non-critical failure
    }
  }

  /// Request password reset link / token sent to email or phone
  Future<void> requestPasswordReset(String identifier) async {
    try {
      final clean = identifier.trim();
      final isEmail = clean.contains('@');
      final formattedPhone = !isEmail ? _normalizePhone(clean) : null;
      AppLogger.info('Requesting password reset for: ${isEmail ? clean : formattedPhone}');
      await _dioClient.post(
        ApiConstants.forgotPassword,
        data: {
          if (isEmail) 'email': clean,
          if (!isEmail) 'phoneNumber': formattedPhone,
          if (!isEmail) 'phone': formattedPhone,
          'identifier': clean,
        },
      );
      AppLogger.info('Password reset request sent');
    } on DioException catch (e) {
      AppLogger.error('Password reset request failed', e);
      throw _handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected password reset error', e, stackTrace);
      throw const UnknownError(message: 'Failed to request password reset');
    }
  }

  /// Reset password using 6-digit numeric OTP code or verification token
  Future<void> resetPassword({required String token, required String newPassword}) async {
    try {
      final cleanToken = token.trim();
      AppLogger.info('Submitting password reset with 6-digit code/token');
      await _dioClient.post(
        ApiConstants.resetPassword,
        data: {
          'token': cleanToken,
          'code': cleanToken,
          'resetCode': cleanToken,
          'newPassword': newPassword,
        },
      );
      AppLogger.info('Password reset completed successfully');
    } on DioException catch (e) {
      AppLogger.error('Password reset failed', e);
      throw _handleAuthError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected password reset error', e, stackTrace);
      throw const UnknownError(message: 'Failed to reset password');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      AppLogger.info('Attempting logout');
      
      // Call logout API to invalidate tokens on server
      await _dioClient.post(ApiConstants.logout);
      
      AppLogger.info('Logout API called successfully');
    } on DioException catch (e) {
      // Log but continue with local logout
      AppLogger.warning('Logout API failed, continuing with local logout', e);
    } finally {
      // Always clear local auth data
      await _storage.clearAuth();
      AppLogger.info('Local auth data cleared');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    
    AppLogger.debug('Is logged in: $isLoggedIn');
    
    return isLoggedIn;
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.getUserId();
  }

  /// Save device token for push notifications
  Future<void> saveDeviceToken(String token) async {
    try {
      AppLogger.info('Saving device token');
      
      await _dioClient.put(
        ApiConstants.profile, data: {'deviceToken': token},
      );
      
      AppLogger.info('Device token saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save device token', e);
      // Don't throw - this is not critical
    }
  }

  /// Handle authentication errors
  AppError _handleAuthError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String? backendMessage;
    if (responseData is Map) {
      if (responseData['message'] != null && responseData['message'].toString().isNotEmpty) {
        backendMessage = responseData['message'].toString();
      } else if (responseData['error'] is Map) {
        final errMap = responseData['error'] as Map;
        backendMessage = errMap['message']?.toString() ?? errMap['detail']?.toString();
      } else if (responseData['error'] != null) {
        backendMessage = responseData['error'].toString();
      } else if (responseData['detail'] != null) {
        backendMessage = responseData['detail'].toString();
      } else if (responseData['msg'] != null) {
        backendMessage = responseData['msg'].toString();
      }

      if (backendMessage == null && responseData['errors'] != null) {
        final errs = responseData['errors'];
        if (errs is Map) {
          backendMessage = errs.entries.map((e) => '${e.key}: ${(e.value is List ? (e.value as List).join(", ") : e.value)}').join('\n');
        } else if (errs is List) {
          backendMessage = errs.join(', ');
        }
      }
    }

    if (statusCode == 401) {
      if (responseData is Map && responseData['code'] == 'ACCOUNT_LOCKED') {
        return AuthError.accountLocked();
      }
      return AuthError(
        message: backendMessage ?? 'Invalid phone/email or password.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    if (statusCode == 403) {
      return AuthError(
        message: backendMessage ?? 'Access denied. Please verify your email or contact support.',
        code: 'FORBIDDEN',
      );
    }

    if (statusCode == 422) {
      if (responseData is Map) {
        return ValidationError.fromResponse(Map<String, dynamic>.from(responseData));
      }
    }

    if (statusCode == 409) {
      return AuthError(
        message: backendMessage ?? 'An account with this phone number or email already exists.',
        code: 'CONFLICT',
      );
    }

    if (statusCode == 400) {
      return AuthError(
        message: backendMessage ?? 'Invalid request data. Please check your inputs.',
        code: 'BAD_REQUEST',
      );
    }

    if (backendMessage != null && backendMessage.isNotEmpty) {
      return AuthError(
        message: backendMessage,
        code: 'HTTP_$statusCode',
      );
    }

    return NetworkError.fromDioException(error);
  }
}

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(dioClient, storage);
});


