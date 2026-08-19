import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/error/app_error.dart';
import 'package:agrietech/core/error/error_handler.dart';

void main() {
  group('AppError - Type Hierarchy & Mapping', () {
    test('ValidationError contains field errors and parsing', () {
      final error = ValidationError.fromResponse(const {
        'errors': {
          'phone': ['Phone number is required'],
          'password': ['Password is too short'],
        },
      });

      expect(error.fieldErrors, isNotNull);
      expect(error.fieldErrors!['phone'], contains('Phone number is required'));
      expect(error.fieldErrors!['password'], contains('Password is too short'));
    });

    test('AuthError codes and messages', () {
      final tokenExpired = AuthError.tokenExpired();
      expect(tokenExpired.code, equals('TOKEN_EXPIRED'));
      expect(tokenExpired.message, contains('Session expired'));

      final invalidCreds = AuthError.invalidCredentials();
      expect(invalidCreds.code, equals('INVALID_CREDENTIALS'));

      final unauthorized = AuthError.unauthorized();
      expect(unauthorized.code, equals('UNAUTHORIZED'));

      final locked = AuthError.accountLocked();
      expect(locked.code, equals('ACCOUNT_LOCKED'));
    });

    test('NetworkError error codes and timeouts', () {
      final connTimeout = NetworkError.timeout();
      expect(connTimeout.code, equals('TIMEOUT'));

      final noInternet = NetworkError.noConnection();
      expect(noInternet.code, equals('NO_CONNECTION'));
    });

    test('ErrorHandler.handleError converts various exceptions', () {
      final rawError = Exception('Custom database error');
      final appError = ErrorHandler.handleError(rawError);
      expect(appError, isA<UnknownError>());
      expect(appError.message, contains('Custom database error'));

      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final networkError = ErrorHandler.handleError(dioError);
      expect(networkError, isA<NetworkError>());
      expect(networkError.code, equals('TIMEOUT'));
    });
  });
}
