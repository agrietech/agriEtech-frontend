import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';
import '../utils/logger.dart';

/// Global error handler for the application
class ErrorHandler {
  /// Convert any exception to AppError
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error occurred', error, stackTrace);

    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return NetworkError.fromDioException(error);
    }

    if (error is Exception) {
      return UnknownError(
        message: error.toString(),
        details: error,
      );
    }

    return UnknownError(
      message: error?.toString() ?? 'An unexpected error occurred',
      details: error,
    );
  }

  /// Show error as snackbar with modern design and auto-cleanup
  static void showErrorSnackBar(BuildContext context, AppError error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                getUserMessage(error),
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: const Color(0xFFFFCDD2),
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    AppError error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (error.code != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error Code: ${error.code}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get user-friendly error message
  static String getUserMessage(AppError error) {
    if (error is ValidationError && error.fieldErrors != null) {
      return error.fieldErrors!.values
          .expand((errors) => errors)
          .join('\n');
    }
    return error.message;
  }
}