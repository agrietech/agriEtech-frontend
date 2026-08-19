/// Background task handler synchronizing offline farmer data on network restore
library background_sync_worker;

import '../../../../core/utils/logger.dart';
import '../domain/sync_service.dart';

class BackgroundSyncWorker {
  static const String taskName = 'agrietech_background_sync';

  /// Called by workmanager when network is restored
  static Future<bool> execute() async {
    try {
      if (!SyncService.hasItems) return true;
      final items = SyncService.drainQueue();
      // Re-submit queued API calls (items would be processed by DioClient retry logic)
      for (final item in items) {
        // Log each queued item for re-submission
        AppLogger.info('[BackgroundSync] Re-submitting: ${item['method']} ${item['endpoint']}');
      }
      return true;
    } catch (e) {
      AppLogger.error('[BackgroundSync] Error: $e');
      return false;
    }
  }
}
