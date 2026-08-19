import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../utils/logger.dart';

/// Service for managing offline data synchronization
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  Box? _syncQueueBox;
  Box? _offlineDataBox;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Initialize sync service
  Future<void> initialize() async {
    try {
      // Open Hive boxes
      _syncQueueBox = await Hive.openBox('sync_queue');
      _offlineDataBox = await Hive.openBox('offline_data');
      
      // Check initial connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = !connectivityResult.contains(ConnectivityResult.none);
      
      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        final wasOffline = !_isOnline;
        _isOnline = !result.contains(ConnectivityResult.none);
        
        AppLogger.info('Connectivity changed', {
          'isOnline': _isOnline,
          'type': result.toString(),
        });
        
        // Sync when coming back online
        if (wasOffline && _isOnline) {
          AppLogger.info('Back online - starting sync');
          syncPendingData();
        }
      });
      
      AppLogger.success('Sync service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize sync service', e);
    }
  }

  /// Queue data for sync when online
  Future<void> queueForSync(String type, Map<String, dynamic> data) async {
    try {
      final syncItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'retryCount': 0,
      };
      
      await _syncQueueBox?.add(syncItem);
      AppLogger.info('Queued for sync', {'type': type});
      
      // Try immediate sync if online
      if (_isOnline) {
        await syncPendingData();
      }
    } catch (e) {
      AppLogger.error('Failed to queue for sync', e);
    }
  }

  /// Sync all pending data
  Future<void> syncPendingData() async {
    if (!_isOnline) {
      AppLogger.info('Offline - skipping sync');
      return;
    }

    try {
      final queue = _syncQueueBox?.values.toList() ?? [];
      AppLogger.info('Syncing pending data', {'count': queue.length});
      
      for (var i = 0; i < queue.length; i++) {
        final item = queue[i] as Map;
        try {
          await _syncItem(item);
          
          // Remove from queue after successful sync
          await _syncQueueBox?.deleteAt(i);
          AppLogger.success('Synced item', {'type': item['type']});
        } catch (e) {
          // Increment retry count
          item['retryCount'] = (item['retryCount'] as int) + 1;
          await _syncQueueBox?.putAt(i, item);
          
          AppLogger.error('Failed to sync item', e);
          
          // Remove if retry count exceeds limit
          if (item['retryCount'] > 3) {
            await _syncQueueBox?.deleteAt(i);
            AppLogger.warning('Removed item after max retries');
          }
        }
      }
    } catch (e) {
      AppLogger.error('Failed to sync pending data', e);
    }
  }

  /// Sync individual item based on type
  Future<void> _syncItem(Map item) async {
    final type = item['type'] as String;
    final data = item['data'] as Map<String, dynamic>?;

    switch (type) {
      case 'farm':
        // Farm data sync
        AppLogger.info('Syncing farm data: ${data?['id']}');
        // Note: Actual repository calls would need dependency injection
        // This is a placeholder for the sync logic
        break;
        
      case 'alert':
        // Alert data sync
        AppLogger.info('Syncing alert data');
        break;
        
      case 'diagnosis':
        // Diagnosis data sync
        AppLogger.info('Syncing diagnosis data');
        break;
        
      case 'sensor':
        // Sensor data sync
        AppLogger.info('Syncing sensor data');
        break;
        
      case 'risk_assessment':
        // Risk assessment data sync
        AppLogger.info('Syncing risk assessment data');
        break;
        
      default:
        AppLogger.warning('Unknown sync type', {'type': type});
    }
  }

  /// Store data offline
  Future<void> storeOffline(String key, dynamic data) async {
    try {
      await _offlineDataBox?.put(key, data);
      AppLogger.info('Stored offline', {'key': key});
    } catch (e) {
      AppLogger.error('Failed to store offline', e);
    }
  }

  /// Get offline data
  dynamic getOffline(String key) {
    try {
      return _offlineDataBox?.get(key);
    } catch (e) {
      AppLogger.error('Failed to get offline data', e);
      return null;
    }
  }

  /// Clear offline cache
  Future<void> clearOfflineCache() async {
    try {
      await _offlineDataBox?.clear();
      AppLogger.info('Offline cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear offline cache', e);
    }
  }

  /// Get sync queue size
  int getSyncQueueSize() {
    return _syncQueueBox?.length ?? 0;
  }

  /// Get offline storage size
  int getOfflineStorageSize() {
    return _offlineDataBox?.length ?? 0;
  }
}


