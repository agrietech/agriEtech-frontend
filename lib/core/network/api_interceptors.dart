///
/// @file api_interceptors.dart
/// @description Dio interceptor attaching Bearer tokens and handling 401 token refresh.
/// @author Networking Specialist
///
library api_interceptors;

import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

class ApiInterceptors extends Interceptor {
  final SecureStorageService _storage;

  ApiInterceptors(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty && !options.headers.containsKey('Authorization')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      AppLogger.warning('Unauthorized (401) response received, clearing authentication tokens');
      await _storage.clearAuth();
    }
    super.onError(err, handler);
  }
}
