import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/theme/app_theme.dart';

void main() {
  group('AppTheme - Risk Color Mapping', () {
    test('getRiskColor returns appropriate color for each level', () {
      expect(AppTheme.getRiskColor('LOW'), equals(AppTheme.lowRiskColor));
      expect(AppTheme.getRiskColor('MODERATE'), equals(AppTheme.moderateRiskColor));
      expect(AppTheme.getRiskColor('HIGH'), equals(AppTheme.highRiskColor));
      expect(AppTheme.getRiskColor('CRITICAL'), equals(AppTheme.criticalRiskColor));
      expect(AppTheme.getRiskColor('UNKNOWN'), equals(Colors.grey));
      expect(AppTheme.getRiskColor(null), equals(Colors.grey));
    });

    test('case-insensitivity of getRiskColor', () {
      expect(AppTheme.getRiskColor('low'), equals(AppTheme.lowRiskColor));
      expect(AppTheme.getRiskColor('High'), equals(AppTheme.highRiskColor));
      expect(AppTheme.getRiskColor('critical'), equals(AppTheme.criticalRiskColor));
    });

    test('light and dark theme configurations are non-null', () {
      expect(AppTheme.lightTheme, isNotNull);
      expect(AppTheme.darkTheme, isNotNull);
      expect(AppTheme.primaryColor, isNotNull);
      expect(AppTheme.secondaryColor, isNotNull);
    });
  });
}
