///
/// @file alerts_repository.dart
/// @feature alerts
/// @description Repository layer fetching data via DioClient with Hive offline caching fallback.
/// @author Feature Developer (alerts)
///
library alerts_repository;

import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/alert_model.dart';

class AlertsRepository {
  final DioClient _dioClient;

  AlertsRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Cache-first read: instant, works fully offline.
  List<AlertModel> getCachedAlerts() {
    final alerts = HiveService.alertsBox.values.toList();
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alerts;
  }

  /// Refreshes the cache from the backend. Throws on network failure so the
  /// caller can silently keep showing cached data instead of an error state.
  Future<List<AlertModel>> fetchAlerts() async {
    final response = await _dioClient.dio.get(ApiEndpoints.alerts);
    final data = (response.data['data'] as List? ?? []);
    final alerts = data
        .map((json) => AlertModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    await _replaceCache(alerts);
    return getCachedAlerts();
  }

  /// Merges a single alert (e.g. pushed live over WebSocket) into the cache
  /// without wiping everything else that's already there.
  Future<void> upsertAlert(AlertModel alert) async {
    await HiveService.alertsBox.put(alert.id, alert);
  }

  Future<void> markAsRead(String alertId) async {
    final existing = HiveService.alertsBox.get(alertId);
    if (existing != null) {
      await HiveService.alertsBox.put(alertId, existing.copyWith(isRead: true));
    }
  }

  int get unreadCount =>
      HiveService.alertsBox.values.where((a) => !a.isRead).length;

  Future<void> _replaceCache(List<AlertModel> alerts) async {
    final box = HiveService.alertsBox;
    // Preserve local isRead state across a full refresh.
    final readIds = box.values.where((a) => a.isRead).map((a) => a.id).toSet();
    await box.clear();
    for (final alert in alerts) {
      await box.put(alert.id,
          readIds.contains(alert.id) ? alert.copyWith(isRead: true) : alert);
    }
  }
}

/// Thrown by fetchAlerts callers when they want to distinguish "no network,
/// use cache" from a genuine bug.
class AlertsFetchException implements Exception {
  final DioException cause;
  AlertsFetchException(this.cause);
}
