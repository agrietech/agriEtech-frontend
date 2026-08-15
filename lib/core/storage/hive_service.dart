///
/// @file hive_service.dart
/// @description Offline NoSQL box manager for caching risk assessments, weather, and farm offline buffers.
/// @author Storage / Offline Lead
///
library hive_service;

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // TODO: Register Hive TypeAdapters
  }
}
