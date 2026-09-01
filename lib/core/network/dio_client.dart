import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/api_constants.dart';
import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

/// HTTP Client with advanced features
class DioClient {
  late final Dio _dio;
  final SecureStorageService _storage;
  final Connectivity _connectivity = Connectivity();

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseApiUrl,
        connectTimeout: ApiConstants.defaultTimeout,
        receiveTimeout: ApiConstants.defaultTimeout,
        sendTimeout: ApiConstants.defaultTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log request in debug mode
          if (AppEnv.debugMode) {
            AppLogger.info('API Request: ${options.method} ${options.path}');
            if (options.data != null) {
              AppLogger.debug('Request Data: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          // Log response in debug mode
          if (AppEnv.debugMode) {
            AppLogger.info('API Response: ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log error
          AppLogger.error('API Error: ${error.message}', error.error, error.stackTrace);

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              try {
                // Retry original request
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                AppLogger.error('Retry failed after token refresh', e);
              }
            } else {
              // Clear tokens and redirect to login
              await _storage.clearAuth();
            }
          }

          // Handle network errors & automatic cold-start retry
          final requestOptions = error.requestOptions;
          final retryCount = (requestOptions.extra['retryCount'] ?? 0) as int;
          final method = requestOptions.method.toUpperCase();
          final isIdempotent = method == 'GET' || method == 'HEAD' || method == 'OPTIONS';
          
          final isConnectionFailure = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError;
          final isReceiveTimeout = error.type == DioExceptionType.receiveTimeout;

          // Safe to retry if server never established connection, OR if the request is an idempotent GET
          final canRetry = (isConnectionFailure || (isIdempotent && isReceiveTimeout)) && retryCount < 2;

          if (canRetry) {
            AppLogger.info('Connection delay detected (cold-start), retrying $method ${requestOptions.path} (attempt ${retryCount + 1})...');
            await Future.delayed(Duration(seconds: retryCount + 1));
            requestOptions.extra['retryCount'] = retryCount + 1;
            try {
              final response = await _dio.fetch<dynamic>(requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              AppLogger.warning('Retry attempt ${retryCount + 1} response: ${retryError.response?.statusCode}');
              if (retryError.response != null) {
                return handler.next(retryError);
              }
            } catch (e) {
              AppLogger.warning('Retry attempt ${retryCount + 1} failed');
            }
          }

          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            error = error.copyWith(
              message: 'Server connection timeout. Please verify your connection or try again.',
            );
          } else if (error.type == DioExceptionType.connectionError) {
            error = error.copyWith(
              message: 'Unable to reach backend server. Please check your network connection.',
            );
          }

          return handler.next(error);
        },
      ),
    );

    // Logging interceptor for debugging
    if (AppEnv.debugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => AppLogger.debug(obj.toString()),
      ));
    }
  }

  Dio get dio => _dio;

  /// Retry failed request with fresh token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _storage.getAccessToken();
    
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool>? _refreshFuture;

  /// Refresh access token with concurrency lock
  Future<bool> _refreshToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }
    _refreshFuture = _performTokenRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _performTokenRefresh() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return false;
      }

      AppLogger.info('Attempting to refresh token');

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null}, // Remove auth header for refresh
        ),
      );

      if (response.statusCode == 200) {
        final raw = response.data is Map ? response.data as Map<String, dynamic> : <String, dynamic>{};
        final data = raw['data'] is Map<String, dynamic> ? raw['data'] as Map<String, dynamic> : raw;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          await _storage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _storage.saveRefreshToken(newRefreshToken);
          }
          
          AppLogger.info('Token refreshed successfully');
          return true;
        }
      }
      
      AppLogger.warning('Token refresh failed: Invalid response');
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('Token refresh error', e, stackTrace);
      return false;
    }
  }

  /// Check connectivity status
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// GET request with caching support
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = false,
    Duration? cacheDuration,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file with progress tracking
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String? fileName,
    String fieldName = 'image',
    Map<String, dynamic>? data,
    void Function(int, int)? onProgress,
  }) async {
    final multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
    final formData = FormData.fromMap({
      fieldName: multipartFile,
      if (fieldName != 'file') 'file': await MultipartFile.fromFile(filePath, filename: fileName),
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

  /// Upload raw bytes directly (for Web or compressed in-memory images)
  Future<Response> uploadBytes(
    String path,
    List<int> bytes, {
    String fileName = 'upload.jpg',
    String fieldName = 'image',
    Map<String, dynamic>? data,
    void Function(int, int)? onProgress,
  }) async {
    final multipartFile = MultipartFile.fromBytes(bytes, filename: fileName);
    final formData = FormData.fromMap({
      fieldName: multipartFile,
      if (fieldName != 'file') 'file': MultipartFile.fromBytes(bytes, filename: fileName),
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

  /// Upload multiple files
  Future<Response> uploadMultipleFiles(
    String path,
    List<String> filePaths, {
    Map<String, dynamic>? data,
    void Function(int, int)? onProgress,
  }) async {
    final files = <MultipartFile>[];
    for (final filePath in filePaths) {
      files.add(await MultipartFile.fromFile(filePath));
    }

    final formData = FormData.fromMap({
      'files': files,
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}

/// Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  return DioClient(storage);
});

