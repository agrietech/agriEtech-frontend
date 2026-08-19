/// Offline NoSQL box manager for caching risk assessments, farms, weather
library hive_service;

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/alerts/data/models/alert_model.dart';
import 'local_cache_boxes.dart';

class HiveService {
  static const String _risksBox = 'risk_assessments';
  static const String _farmsBox = 'farms_cache';
  static const String _weatherBox = 'weather_cache';
  static const String _alertsBox = 'alerts_cache';
  static const String _diagnosisBox = 'diagnosis_cache';

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    // Open all offline cache boxes
    await Future.wait([
      Hive.openBox<Map>(_risksBox),
      Hive.openBox<Map>(_farmsBox),
      Hive.openBox<Map>(_weatherBox),
      Hive.openBox<Map>(_alertsBox),
      Hive.openBox<Map>(_diagnosisBox),
    ]);
  }

  static Box<Map> get risks => Hive.box<Map>(_risksBox);
  static Box<Map> get farms => Hive.box<Map>(_farmsBox);
  static Box<Map> get weather => Hive.box<Map>(_weatherBox);
  static Box<Map> get alerts => Hive.box<Map>(_alertsBox);
  static Box<Map> get diagnosis => Hive.box<Map>(_diagnosisBox);

  static Future<void> clearAll() async {
    await Future.wait([
      risks.clear(), farms.clear(), weather.clear(),
      alerts.clear(), diagnosis.clear(),
    ]);
  }

  static Box<AlertModel> get alertsBox =>
      Hive.box<AlertModel>(LocalCacheBoxes.alertsBox);
  static Box get weatherBox => Hive.box(LocalCacheBoxes.weatherBox);
  static Box get riskBox => Hive.box(LocalCacheBoxes.riskBox);
  static Box get farmsBox => Hive.box(LocalCacheBoxes.farmsBox);
  static Box get boundaryBox => Hive.box(LocalCacheBoxes.boundaryBox);
  static Box get pendingActionsBox =>
      Hive.box(LocalCacheBoxes.pendingActionsBox);

  static Future<void> closeAll() => Hive.close();
}
