///
/// @file hive_service.dart
/// @description Offline NoSQL box manager for caching risk assessments, weather, and farm offline buffers.
/// @author Storage / Offline Lead
///
/// T5.1 (P0 Critical): every other team member depends on these boxes being
/// open before the app renders its first frame. Keep this fast and defensive —
/// a corrupted box must never crash cold start.
///
library hive_service;

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/alerts/data/models/alert_model.dart';
import 'local_cache_boxes.dart';

class HiveService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Only alerts_cache stores a typed object today; every other box is
    // owned by another feature developer and stored as raw Map<String, dynamic>
    // until that developer registers their own adapter here.
    if (!Hive.isAdapterRegistered(AlertModelAdapter().typeId)) {
      Hive.registerAdapter(AlertModelAdapter());
    }

    await _openBoxSafely<AlertModel>(LocalCacheBoxes.alertsBox, typed: true);
    await _openBoxSafely(LocalCacheBoxes.weatherBox);
    await _openBoxSafely(LocalCacheBoxes.riskBox);
    await _openBoxSafely(LocalCacheBoxes.farmsBox);
    await _openBoxSafely(LocalCacheBoxes.boundaryBox);
    await _openBoxSafely(LocalCacheBoxes.pendingActionsBox);

    _initialized = true;
  }

  /// Opens a box, deleting and recreating it if it's corrupted rather than
  /// throwing — a corrupt cache should never block app startup.
  static Future<void> _openBoxSafely<T>(String name,
      {bool typed = false}) async {
    try {
      if (typed) {
        await Hive.openBox<T>(name);
      } else {
        await Hive.openBox(name);
      }
    } catch (_) {
      await Hive.deleteBoxFromDisk(name);
      if (typed) {
        await Hive.openBox<T>(name);
      } else {
        await Hive.openBox(name);
      }
    }
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
