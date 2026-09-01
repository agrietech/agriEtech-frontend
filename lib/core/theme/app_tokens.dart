import 'package:flutter/material.dart';

/// Standardized 8-Point Spatial Grid Tokens for AgriEtech UI System
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double hero = 64.0;

  // Semantic Spacing Tokens
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double sectionGap = 24.0;
  static const double itemGap = 12.0;
}

/// Unified Corner Radius Tokens
class AppRadii {
  AppRadii._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  // Pre-built BorderRadius objects (Standard)
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));

  // Legacy aliases
  static const BorderRadius radiusSm = roundedSm;
  static const BorderRadius radiusMd = roundedMd;
  static const BorderRadius radiusLg = roundedLg;
  static const BorderRadius radiusXl = roundedXl;
  static const BorderRadius radiusXxl = roundedXxl;
  static const BorderRadius radiusPill = roundedPill;
}

/// Backward compatibility alias for AppRadius
typedef AppRadius = AppRadii;

/// Ambient & Directional Shadow Tokens
class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft({bool isDark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> card({bool isDark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> elevated({bool isDark = false}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 14,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ];
}

/// Standardized Icon Dimension Scale
class AppIconSize {
  AppIconSize._();

  static const double xs = 14.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double hero = 48.0;
}

/// Accessibility & Touch Target Tokens (WCAG 2.1 AA Compliance)
class AppTouchTarget {
  AppTouchTarget._();

  /// Minimum recommended touch target dimension in dp
  static const double minDimension = 48.0;

  static const BoxConstraints minConstraints = BoxConstraints(
    minWidth: minDimension,
    minHeight: minDimension,
  );
}

/// Standardized Typography System (WCAG Compliant Scale)
class AppTypography {
  AppTypography._();

  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.2,
  );
}

/// Physics-based Animation Duration and Curve Tokens
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration extended = Duration(milliseconds: 600);
}

class AppCurves {
  AppCurves._();

  static const Curve spring = Curves.easeOutBack;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve snappy = Curves.easeOutCubic;
}

