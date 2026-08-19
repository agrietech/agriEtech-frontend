/// Connectivity monitoring and offline queue reconciliation service
library sync_service;

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
