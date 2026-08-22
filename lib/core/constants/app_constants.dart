/// Application Constants
class AppConstants {
  // App Info
  static const String appName = 'AgriEtech';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String languageKey = 'preferred_language';

  // Supported Languages
  static const String englishCode = 'en';
  static const String amharicCode = 'am';
  static const List<String> supportedLanguages = [englishCode, amharicCode];

  // Default Values
  static const String defaultLanguage = englishCode;
  static const double defaultLat = 9.0320; // Addis Ababa
  static const double defaultLng = 38.7469;

  // Ethiopian Boundaries
  static const double ethiopiaMinLat = 3.0;
  static const double ethiopiaMaxLat = 15.0;
  static const double ethiopiaMinLng = 33.0;
  static const double ethiopiaMaxLng = 48.0;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheMediumDuration = Duration(minutes: 30);
  static const Duration cacheLongDuration = Duration(hours: 1);
  static const Duration cacheVeryLongDuration = Duration(hours: 24);

  // Sync
  static const Duration syncInterval = Duration(minutes: 15);
  static const Duration backgroundSyncInterval = Duration(hours: 1);

  // Map
  static const double defaultZoom = 10.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;

  // Risk Levels
  static const String riskLow = 'LOW';
  static const String riskModerate = 'MODERATE';
  static const String riskHigh = 'HIGH';
  static const String riskCritical = 'CRITICAL';

  // Hazard Types
  static const String hazardDrought = 'DROUGHT';
  static const String hazardFlood = 'FLOOD';
  static const String hazardLocust = 'LOCUST_PEST';
  static const String hazardFrost = 'FROST';
  static const String hazardHeatwave = 'HEATWAVE';
}
