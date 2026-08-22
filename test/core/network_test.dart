import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/constants/api_constants.dart';

void main() {
  group('Network & API Constants Tests', () {
    test('ApiConstants base URLs and default timeouts are valid', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.baseApiUrl, contains('/api/v1'));
      expect(ApiConstants.defaultTimeout.inSeconds, greaterThanOrEqualTo(10));
      expect(ApiConstants.longTimeout.inSeconds, greaterThanOrEqualTo(30));
    });

    test('ApiConstants auth endpoints are well-formed', () {
      expect(ApiConstants.login, '/auth/login');
      expect(ApiConstants.register, '/auth/register');
      expect(ApiConstants.refreshToken, '/auth/refresh-token');
      expect(ApiConstants.forgotPassword, '/auth/forgot-password');
      expect(ApiConstants.resetPassword, '/auth/reset-password');
      expect(ApiConstants.updatePassword, '/auth/update-password');
    });

    test('ApiConstants feature endpoints are well-formed', () {
      expect(ApiConstants.farms, '/farms');
      expect(ApiConstants.alerts, '/alerts');
      expect(ApiConstants.riskAssessments, '/risk-assessments');
      expect(ApiConstants.diseaseDiagnosis, '/disease-diagnosis');
      expect(ApiConstants.sensors, '/sensors');
      expect(ApiConstants.analytics, '/analytics');
    });
  });
}
