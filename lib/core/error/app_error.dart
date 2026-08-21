import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Base class for application errors
abstract class AppError extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppError({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// Network related errors
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.details,
  });

  factory NetworkError.noConnection() {
    return const NetworkError(
      message: 'No internet connection. Please check your network settings.',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkError.timeout() {
    return const NetworkError(
      message: 'Request timed out. Please check your connection and try again.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkError.serverError([String? message]) {
    return NetworkError(
      message: message ?? 'Server error occurred. Please try again later.',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkError.fromDioException(DioException exception) {
    if (exception.response?.data is Map) {
      final data = exception.response!.data as Map;
      final serverMsg = data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString() ??
          data['msg']?.toString();
      if (serverMsg != null && serverMsg.isNotEmpty) {
        return NetworkError(
          message: serverMsg,
          code: 'HTTP_${exception.response?.statusCode ?? 400}',
          details: data,
        );
      }
    }

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout();
      
      case DioExceptionType.connectionError:
        return const NetworkError(
          message: 'Unable to reach backend server. Please verify your connection or try again.',
          code: 'CONNECTION_ERROR',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = _getHttpErrorMessage(statusCode);
        return NetworkError(
          message: message,
          code: 'HTTP_$statusCode',
          details: exception.response?.data,
        );
      
      default:
        final rawMsg = exception.message ?? exception.error?.toString();
        return NetworkError(
          message: (rawMsg != null && rawMsg.isNotEmpty) ? rawMsg : 'Network request failed. Please try again.',
          code: 'NETWORK_ERROR',
        );
    }
  }

  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please verify your input.';
      case 401:
        return 'Authentication required. Please sign in again.';
      case 403:
        return 'Access denied. Insufficient permissions for this action.';
      case 404:
        return 'Requested resource not found.';
      case 409:
        return 'Resource conflict. The item already exists.';
      case 422:
        return 'Validation failed. Please verify your input.';
      case 429:
        return 'Rate limit exceeded. Please wait before trying again.';
      case 500:
        return 'Internal server error occurred. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred. Please contact support if the issue persists.';
    }
  }
}

/// Authentication related errors
class AuthError extends AppError {
  const AuthError({
    required super.message,
    super.code,
    super.details,
  });

  factory AuthError.invalidCredentials() {
    return const AuthError(
      message: 'Invalid username or password.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthError.accountLocked() {
    return const AuthError(
      message: 'Account temporarily locked due to multiple failed login attempts. Please try again later.',
      code: 'ACCOUNT_LOCKED',
    );
  }

  factory AuthError.tokenExpired() {
    return const AuthError(
      message: 'Your session has expired. Please sign in again.',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthError.unauthorized() {
    return const AuthError(
      message: 'Unauthorized access. You do not have permission for this action.',
      code: 'UNAUTHORIZED',
    );
  }
}

/// Validation related errors
class ValidationError extends AppError {
  final Map<String, List<String>>? fieldErrors;

  const ValidationError({
    required super.message,
    super.code,
    super.details,
    this.fieldErrors,
  });

  factory ValidationError.fromResponse(Map<String, dynamic> response) {
    final errors = response['errors'] as Map<String, dynamic>?;
    final fieldErrors = <String, List<String>>{};
    
    if (errors != null) {
      errors.forEach((field, messages) {
        if (messages is List) {
          fieldErrors[field] = messages.cast<String>();
        } else if (messages is String) {
          fieldErrors[field] = [messages];
        }
      });
    }

    return ValidationError(
      message: response['message'] as String? ?? 'Validation failed',
      code: 'VALIDATION_ERROR',
      fieldErrors: fieldErrors.isNotEmpty ? fieldErrors : null,
    );
  }

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Cache related errors
class CacheError extends AppError {
  const CacheError({
    required super.message,
    super.code,
    super.details,
  });

  factory CacheError.notFound() {
    return const CacheError(
      message: 'Data not found in cache.',
      code: 'CACHE_NOT_FOUND',
    );
  }

  factory CacheError.expired() {
    return const CacheError(
      message: 'Cached data has expired.',
      code: 'CACHE_EXPIRED',
    );
  }
}

/// Location related errors
class LocationError extends AppError {
  const LocationError({
    required super.message,
    super.code,
    super.details,
  });

  factory LocationError.permissionDenied() {
    return const LocationError(
      message: 'Location permission denied. Please enable location access.',
      code: 'PERMISSION_DENIED',
    );
  }

  factory LocationError.serviceDisabled() {
    return const LocationError(
      message: 'Location services are disabled. Please enable GPS.',
      code: 'SERVICE_DISABLED',
    );
  }

  factory LocationError.timeout() {
    return const LocationError(
      message: 'Unable to retrieve location. Please check your GPS signal and try again.',
      code: 'LOCATION_TIMEOUT',
    );
  }
}

/// File related errors
class FileError extends AppError {
  const FileError({
    required super.message,
    super.code,
    super.details,
  });

  factory FileError.notFound() {
    return const FileError(
      message: 'File not found.',
      code: 'FILE_NOT_FOUND',
    );
  }

  factory FileError.tooLarge() {
    return const FileError(
      message: 'File size exceeds the maximum allowed limit.',
      code: 'FILE_TOO_LARGE',
    );
  }

  factory FileError.invalidFormat() {
    return const FileError(
      message: 'Invalid file format.',
      code: 'INVALID_FORMAT',
    );
  }

  factory FileError.uploadFailed() {
    return const FileError(
      message: 'File upload failed. Please check your connection and try again.',
      code: 'UPLOAD_FAILED',
    );
  }
}

/// Unknown or unexpected errors
class UnknownError extends AppError {
  const UnknownError({
    super.message = 'An unexpected error occurred. Please try again or contact support if the issue persists.',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}