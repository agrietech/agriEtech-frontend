///
/// @file local_cache_boxes.dart
/// @description Hive box name definitions and query helpers.
/// @author Banchiamlak
///
library local_cache_boxes;

class LocalCacheBoxes {
  static const String weatherBox = 'weather_cache';
  static const String riskBox = 'risk_cache';
  static const String farmsBox = 'farms_cache';
  static const String alertsBox = 'alerts_cache';
  static const String boundaryBox = 'boundary_cache';
  static const String pendingActionsBox = 'pending_actions';

  /// All boxes that must be opened on app start (T5.1).
  static const List<String> all = [
    weatherBox,
    riskBox,
    farmsBox,
    alertsBox,
    boundaryBox,
    pendingActionsBox,
  ];
}
