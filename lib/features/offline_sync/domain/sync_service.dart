/// Connectivity monitoring and offline queue reconciliation service
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
  static final List<Map<String, dynamic>> _pendingQueue = [];

  /// Add a failed API call to the offline retry queue
  static void enqueue(String endpoint, String method, Map<String, dynamic> payload) {
    _pendingQueue.add({'endpoint': endpoint, 'method': method, 'payload': payload, 'ts': DateTime.now().toIso8601String()});
  }

  /// Return count of pending sync items
  static int get pendingCount => _pendingQueue.length;

  /// Get and clear the queue for processing
  static List<Map<String, dynamic>> drainQueue() {
    final items = List<Map<String, dynamic>>.from(_pendingQueue);
    _pendingQueue.clear();
    return items;
  }

  static bool get hasItems => _pendingQueue.isNotEmpty;
}
