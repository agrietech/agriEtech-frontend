/// Connectivity monitoring and offline queue reconciliation service
library sync_service;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/logger.dart';

class SyncService {
  static const String _prefsKey = 'agrietech_offline_sync_queue_v1';
  static final List<Map<String, dynamic>> _pendingQueue = [];
  static bool _initialized = false;

  /// Initialize and load persisted offline queue from disk
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        _pendingQueue.clear();
        _pendingQueue.addAll(decoded.cast<Map<String, dynamic>>());
        AppLogger.info('[SyncService] Restored ${_pendingQueue.length} offline operations from disk');
      }
      _initialized = true;
    } catch (e) {
      AppLogger.warn('[SyncService] Failed to load offline queue: $e');
      _initialized = true;
    }
  }

  /// Persist the current queue state to disk
  static Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_pendingQueue));
    } catch (e) {
      AppLogger.error('[SyncService] Error persisting offline queue: $e');
    }
  }

  /// Add a failed API call or offline write to the retry queue
  static Future<void> enqueue(String endpoint, String method, Map<String, dynamic> payload) async {
    await initialize();
    final entry = {
      'id': 'op_${DateTime.now().millisecondsSinceEpoch}',
      'endpoint': endpoint,
      'method': method.toUpperCase(),
      'payload': payload,
      'ts': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };
    _pendingQueue.add(entry);
    await _saveQueue();
    AppLogger.info('[SyncService] Enqueued offline operation: $method $endpoint (Total: ${_pendingQueue.length})');
  }

  /// Return count of pending sync items
  static int get pendingCount => _pendingQueue.length;

  /// Check if there are pending items
  static bool get hasItems => _pendingQueue.isNotEmpty;

  /// Get all current pending items without clearing
  static List<Map<String, dynamic>> getPendingItems() => List.unmodifiable(_pendingQueue);

  /// Get and clear the queue for processing
  static Future<List<Map<String, dynamic>>> drainQueue() async {
    await initialize();
    final items = List<Map<String, dynamic>>.from(_pendingQueue);
    _pendingQueue.clear();
    await _saveQueue();
    AppLogger.info('[SyncService] Drained ${items.length} items from offline queue');
    return items;
  }

  /// Re-enqueue an item if re-submission failed
  static Future<void> reEnqueue(Map<String, dynamic> item) async {
    await initialize();
    item['retryCount'] = ((item['retryCount'] as int?) ?? 0) + 1;
    // Cap retries at 10 to avoid poison pill loops
    if ((item['retryCount'] as int) <= 10) {
      _pendingQueue.add(item);
      await _saveQueue();
    } else {
      AppLogger.warn('[SyncService] Dropping operation after 10 failed attempts: ${item['method']} ${item['endpoint']}');
    }
  }
}

