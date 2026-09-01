import 'package:flutter/material.dart';
export 'app_tokens.dart';

/// Application theme configuration featuring an agricultural Green brand identity & Obsidian High-Tech AgTech aesthetic
class AppTheme {
  // Brand Colors (Light Green Natural Professional / Expert AgTech Palette)
  static const Color primaryColor = Color(0xFF15803D); // Lush Emerald Green
  static const Color primaryDark = Color(0xFF166534);  // Deep Forest Green
  static const Color primaryLight = Color(0xFF22C55E); // Vibrant Leaf Green
  static const Color primaryContainer = Color(0xFFDCFCE7); // Light Sage Container
  static const Color secondaryColor = Color(0xFF0D9488); // Teal / Hydro Irrigation
  static const Color tertiaryColor = Color(0xFFD97706);  // Warm Ethiopian Amber / Harvest Wheat

  // Surface and Container Tokens (Natural Light Professional System)
  static const Color surfaceLight = Color(0xFFF4F9F4); // Natural Light Mint Alabaster
  static const Color surfaceDark = Color(0xFF0E1E14); // Deep Forest Slate
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF162A1D); // Forest Slate Card
  static const Color borderLight = Color(0xFFE2ECE2); // Subtle Sage Border
  static const Color borderDark = Color(0xFF23442E); // Deep Sage Border
  static const Color headerDark = Color(0xFF14532D); // Deep Botanical Header
  static const Color accentGreen = Color(0xFF16A34A); // Lush Fresh Green
  static const Color neutralDark = Color(0xFF1E293B); // Slate 800 High-Contrast Neutral

  // Natural Glassmorphic Overlays
  static const Color glassDark = Color(0xDE132419);
  static const Color glassLight = Color(0xF2FFFFFF);
  static const Color glassBorderDark = Color(0x3322C55E);
  static const Color glassBorderLight = Color(0x2E15803D);

  // High-Tech Telemetry & Sensor Tokens
  static const Color telemetryNdvi = Color(0xFF10B981); // Satellite NDVI Emerald
  static const Color telemetrySensor = Color(0xFF0284C7); // IoT LoRa Cyan-Blue
  static const Color telemetrySoil = Color(0xFF8D6E63); // Soil Sensor Earth
  static const Color telemetryLocust = Color(0xFFDC2626); // Desert Locust Radar Red
  static const Color telemetryDrought = Color(0xFFF59E0B); // Drought Hazard Amber
  static const Color telemetryFlood = Color(0xFF3B82F6); // Hydro Flood Indigo

  // AgTech Natural Gradients (Vibrant & Organic — Zero Pitch-Black)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF15803D), Color(0xFF16A34A), Color(0xFF22C55E)],
  );

  static const LinearGradient naturalLightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFF4F9F4)],
  );

  static const LinearGradient naturalHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14532D), Color(0xFF15803D), Color(0xFF16A34A)],
  );

  static const LinearGradient techHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14532D), Color(0xFF15803D), Color(0xFF166534)],
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF122418), Color(0xFF1B3825)],
  );

  static const LinearGradient riskCriticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
  );

  static const LinearGradient ndviGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
  );

  // System & Alert Colors
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color successColor = Color(0xFF15803D);

  // Risk Level Colors (Early Warning Standards)
  static const Color lowRiskColor = Color(0xFF16A34A);
  static const Color moderateRiskColor = Color(0xFFF59E0B);
  static const Color highRiskColor = Color(0xFFEA580C);
  static const Color criticalRiskColor = Color(0xFFDC2626);

  /// Get color for a risk/severity level string
  static Color getRiskColor(String? level) {
    switch (level?.toUpperCase()) {
      case 'LOW':
        return lowRiskColor;
      case 'MODERATE':
        return moderateRiskColor;
      case 'HIGH':
        return highRiskColor;
      case 'CRITICAL':
        return criticalRiskColor;
      default:
        return Colors.grey;
    }
  }

  // Light Theme (Natural Professional)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: Colors.white,
      primaryContainer: primaryContainer,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF14532D),
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: Color(0xFF14532D),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        backgroundColor: Colors.white,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.normal,
            fontSize: 11,
          );
        }),
      ),
    );
  }

  // Dark Theme (Forest Slate AgTech)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryLight,
      secondary: const Color(0xFF2DD4BF),
      surface: surfaceDark,
      primaryContainer: const Color(0xFF1A3825),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceDark,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Color(0xFF14281C),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: primaryLight),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 3,
        backgroundColor: const Color(0xFF14281C),
        indicatorColor: const Color(0xFF224830),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            );
          }
          return TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.normal,
            fontSize: 11,
          );
        }),
      ),
    );
  }
}

