///
/// @file env.dart
/// @description Environment configuration loader.
/// @author Frontend Core
///
library env;

class AppEnv {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5000/api/v1');
  static const String socketBaseUrl = String.fromEnvironment('SOCKET_BASE_URL', defaultValue: 'http://10.0.2.2:5000');
  static const String mapTileUrl = String.fromEnvironment('MAP_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
}
