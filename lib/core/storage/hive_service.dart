/// Offline NoSQL box manager for caching risk assessments, farms, weather
library hive_service;

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _risksBox = 'risk_assessments';
  static const String _farmsBox = 'farms_cache';
  static const String _weatherBox = 'weather_cache';
  static const String _alertsBox = 'alerts_cache';
  static const String _diagnosisBox = 'diagnosis_cache';

  static Future<void> init() async {
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
}
