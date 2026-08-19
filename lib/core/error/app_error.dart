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
      message: 'Request timeout. Please try again.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkError.serverError([String? message]) {
    return NetworkError(
      message: message ?? 'Server error. Please try again later.',
      code: 'SERVER_ERROR',
    );
  }

  factory NetworkError.fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkError.timeout();
      
      case DioExceptionType.connectionError:
        return NetworkError.noConnection();
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final message = _getHttpErrorMessage(statusCode);
        return NetworkError(
          message: message,
          code: 'HTTP_$statusCode',
          details: exception.response?.data,
        );
      
      default:
        return NetworkError.serverError(exception.message);
    }
  }

  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred.';
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
      message: 'Invalid email or password.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthError.accountLocked() {
    return const AuthError(
      message: 'Account locked due to too many failed attempts. Please try again later.',
      code: 'ACCOUNT_LOCKED',
    );
  }

  factory AuthError.tokenExpired() {
    return const AuthError(
      message: 'Session expired. Please login again.',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthError.unauthorized() {
    return const AuthError(
      message: 'You are not authorized to perform this action.',
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
      message: 'Failed to get location. Please try again.',
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
      message: 'Failed to upload file. Please try again.',
      code: 'UPLOAD_FAILED',
    );
  }
}

/// Unknown or unexpected errors
class UnknownError extends AppError {
  const UnknownError({
    super.message = 'An unexpected error occurred.',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}