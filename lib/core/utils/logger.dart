import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../config/env.dart';

/// Application logging utility
class AppLogger {
  static const String _tag = 'AgriEtech';

  /// Log info message
  static void info(String message, [Object? data]) {
    if (AppEnv.debugMode || kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 800,
        error: data,
      );
    }
  }

  /// Log debug message
  static void debug(String message, [Object? data]) {
    if (AppEnv.debugMode || kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 700,
        error: data,
      );
    }
  }

  /// Log warning message
  static void warning(String message, [Object? error]) {
    if (AppEnv.debugMode || kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 900,
        error: error,
      );
    }
  }

  /// Log error message
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (AppEnv.debugMode || kDebugMode) {
      developer.log(
        message,
        name: _tag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log success message
  static void success(String message, [Object? data]) {
    if (AppEnv.debugMode || kDebugMode) {
      developer.log(
        '✓ $message',
        name: _tag,
        level: 800,
        error: data,
      );
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    if (AppEnv.debugMode) {
      debug('API $method: $url', data);
    }
  }

  /// Log API response
  static void apiResponse(int statusCode, String url, [dynamic data]) {
    if (AppEnv.debugMode) {
      debug('API Response $statusCode: $url', data);
    }
  }
}