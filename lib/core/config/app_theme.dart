///
/// @file app_theme.dart
/// @description Design system theme tokens (colors, typography, elevation, rounded borders).
/// @author UI/UX Lead
///
library app_theme;

import 'package:flutter/material.dart';

class AppTheme {
  // Brand Palette: Earth Green & Amber Warning
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentAmber = Color(0xFFFFA000);
  static const Color criticalRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1976D2);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFF121212);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        surface: surfaceLight,
      ),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        surface: surfaceDark,
      ),
      fontFamily: 'Inter',
    );
  }
}
