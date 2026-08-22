import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration with comprehensive settings
class AppEnv {
  /// Initialize environment variables
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallback to default values if .env is unavailable
    }
  }

  static String _get(String key, String defaultValue) {
    if (!dotenv.isInitialized) return defaultValue;
    return dotenv.env[key] ?? defaultValue;
  }

  // API Configuration
  static String get apiBaseUrl => 
    _get('API_BASE_URL', 'https://agrietech.onrender.com/api/v1');
  
  static String get socketBaseUrl => 
    _get('SOCKET_BASE_URL', 'https://agrietech.onrender.com');

  // Map Configuration
  static String get mapTileUrl => 
    _get('MAP_TILE_URL', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');

  // Environment Settings
  static String get appEnv => _get('APP_ENV', 'development');
  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
  static bool get debugMode => _get('DEBUG_MODE', 'false').toLowerCase() == 'true';

  // API Timeouts
  static Duration get apiTimeout => Duration(
    milliseconds: int.tryParse(_get('API_TIMEOUT', '90000')) ?? 90000,
  );
  
  static Duration get longApiTimeout => Duration(
    milliseconds: int.tryParse(_get('LONG_API_TIMEOUT', '120000')) ?? 120000,
  );

  // Caching Configuration
  static bool get cacheEnabled => 
    _get('CACHE_ENABLED', 'true').toLowerCase() != 'false';
  
  static Duration get cacheShortDuration => Duration(
    milliseconds: int.tryParse(_get('CACHE_DURATION_SHORT', '300000')) ?? 30000,
  );
  
  static Duration get cacheMediumDuration => Duration(
    milliseconds: int.tryParse(_get('CACHE_DURATION_MEDIUM', '1800000')) ?? 1800000,
  );
  
  static Duration get cacheLongDuration => Duration(
    milliseconds: int.tryParse(_get('CACHE_DURATION_LONG', '3600000')) ?? 3600000,
  );

  // Socket Configuration
  static bool get socketReconnect => 
    _get('SOCKET_RECONNECT', 'true').toLowerCase() != 'false';
  
  static int get socketReconnectAttempts => 
    int.tryParse(_get('SOCKET_RECONNECT_ATTEMPTS', '5')) ?? 5;
  
  static int get socketReconnectDelay => 
    int.tryParse(_get('SOCKET_RECONNECT_DELAY', '1000')) ?? 1000;

  // Firebase Configuration
  static String get firebaseProjectId => 
    _get('FIREBASE_PROJECT_ID', 'agrietech-ewa');
  
  static String get firebaseApiKey => _get('FIREBASE_API_KEY', '');
  static String get firebaseAppId => _get('FIREBASE_APP_ID', '');

  // Feature Flags
  static bool get enableOfflineSync => 
    _get('ENABLE_OFFLINE_SYNC', 'true').toLowerCase() != 'false';
  
  static bool get enablePushNotifications => 
    _get('ENABLE_PUSH_NOTIFICATIONS', 'true').toLowerCase() != 'false';
  
  static bool get enableBackgroundSync => 
    _get('ENABLE_BACKGROUND_SYNC', 'true').toLowerCase() != 'false';
  
  static bool get enableBiometricAuth => 
    _get('ENABLE_BIOMETRIC_AUTH', 'false').toLowerCase() == 'true';

  // Image Upload Configuration
  static int get maxImageSizeMB => 
    int.tryParse(_get('MAX_IMAGE_SIZE_MB', '5')) ?? 5;
  
  static List<String> get allowedImageFormats => 
    _get('ALLOWED_IMAGE_FORMATS', 'jpg,jpeg,png,webp')
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .toList();

  // Localization
  static String get defaultLanguage => _get('DEFAULT_LANGUAGE', 'en');
  static String get fallbackLanguage => _get('FALLBACK_LANGUAGE', 'en');
}
