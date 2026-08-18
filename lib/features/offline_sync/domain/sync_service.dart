///
/// @file sync_service.dart
/// @feature offlineSync
/// @description Connectivity monitoring and queue reconciliation service.
/// @author Offline / Sync Lead
///
/// T5.6: three conflict strategies for the pending_actions queue.
/// T5.7: flush immediately when connectivity is restored, don't wait for
///       the next scheduled Workmanager window.
///
library sync_service;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/hive_service.dart';

/// A single queued offline mutation waiting to be sent to the backend.
class PendingAction {
  final String id;
  final String
      entityType; // 'farm_profile' | 'risk_score' | 'ndvi' | 'locust_position' | 'disease_diagnosis' | 'sensor_telemetry'
  final String method; // 'POST' | 'PUT' | 'PATCH' | 'DELETE'
  final String path;
  final Map<String, dynamic> payload;
  final DateTime queuedAt;

  PendingAction({
    required this.id,
    required this.entityType,
    required this.method,
    required this.path,
    required this.payload,
    DateTime? queuedAt,
  }) : queuedAt = queuedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'method': method,
        'path': path,
        'payload': payload,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory PendingAction.fromJson(Map<String, dynamic> json) => PendingAction(
        id: json['id'],
        entityType: json['entityType'],
        method: json['method'],
        path: json['path'],
        payload: Map<String, dynamic>.from(json['payload'] ?? {}),
        queuedAt: DateTime.tryParse(json['queuedAt'] ?? '') ?? DateTime.now(),
      );
}

enum ConflictStrategy { lastWriteWins, serverAuthoritative, appendOnly }

class SyncService {
  final DioClient _dioClient;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  SyncService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Which conflict strategy applies to a given queued entity type.
  static ConflictStrategy strategyFor(String entityType) {
    switch (entityType) {
      case 'farm_profile':
      case 'user_profile':
        return ConflictStrategy.lastWriteWins;
      case 'risk_score':
      case 'ndvi':
      case 'locust_position':
        return ConflictStrategy.serverAuthoritative;
      case 'disease_diagnosis':
      case 'sensor_telemetry':
        return ConflictStrategy.appendOnly;
      default:
        return ConflictStrategy.lastWriteWins;
    }
  }

  /// Decides whether a locally-queued mutation should still be sent given
  /// what the server currently holds for the same entity.
  ///
  /// - lastWriteWins: local wins if it was queued after the server's version.
  /// - serverAuthoritative: local is discarded — the server's computed value
  ///   (risk scores, NDVI, locust positions) always wins.
  /// - appendOnly: always sent — these are logs/records, never overwritten.
  bool shouldSendLocal({
    required String entityType,
    required DateTime localQueuedAt,
    DateTime? serverUpdatedAt,
  }) {
    switch (strategyFor(entityType)) {
      case ConflictStrategy.lastWriteWins:
        if (serverUpdatedAt == null) return true;
        return localQueuedAt.isAfter(serverUpdatedAt);
      case ConflictStrategy.serverAuthoritative:
        return false;
      case ConflictStrategy.appendOnly:
        return true;
    }
  }

  Future<void> queueAction(PendingAction action) async {
    await HiveService.pendingActionsBox.put(action.id, action.toJson());
  }

  List<PendingAction> getQueuedActions() {
    return HiveService.pendingActionsBox.values
        .map((json) => PendingAction.fromJson(Map<String, dynamic>.from(json)))
        .toList()
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
  }

  /// Sends every queued action in order, removing each on success.
  /// A failed action is left in the queue for the next sync attempt.
  Future<void> flushPendingActions() async {
    final actions = getQueuedActions();
    for (final action in actions) {
      try {
        await _send(action);
        await HiveService.pendingActionsBox.delete(action.id);
      } on DioException {
        // Network still down or server rejected it — keep it queued and
        // stop this pass rather than burning through retries out of order.
        break;
      }
    }
  }

  Future<void> _send(PendingAction action) {
    final dio = _dioClient.dio;
    switch (action.method) {
      case 'POST':
        return dio.post(action.path, data: action.payload);
      case 'PUT':
        return dio.put(action.path, data: action.payload);
      case 'PATCH':
        return dio.patch(action.path, data: action.payload);
      case 'DELETE':
        return dio.delete(action.path, data: action.payload);
      default:
        return dio.post(action.path, data: action.payload);
    }
  }

  /// T5.7 — the moment connectivity comes back, flush immediately instead
  /// of waiting for Workmanager's next periodic window.
  void startConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        flushPendingActions();
      }
    });
  }

  void stopConnectivityListener() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}
