/// Background task handler synchronizing offline farmer data on network restore
library background_sync_worker;

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../domain/sync_service.dart';

class BackgroundSyncWorker {
  static const String taskName = 'agrietech_background_sync';

  /// Called by workmanager or connectivity listener when network is restored
  static Future<bool> execute() async {
    try {
      await SyncService.initialize();
      if (!SyncService.hasItems) {
        AppLogger.info('[BackgroundSync] No pending offline items to synchronize');
        return true;
      }

      final items = await SyncService.drainQueue();
      AppLogger.info('[BackgroundSync] Starting synchronization replay for ${items.length} items');

      final storage = SecureStorageService(const FlutterSecureStorage());
      final client = DioClient(storage);
      final dio = client.dio;

      int successCount = 0;
      int failureCount = 0;

      for (final item in items) {
        final id = item['id'] as String? ?? 'op_${DateTime.now().millisecondsSinceEpoch}';
        final method = (item['method'] as String? ?? 'POST').toUpperCase();
        final endpoint = item['endpoint'] as String? ?? '';
        final payload = item['payload'] as Map<String, dynamic>? ?? {};

        AppLogger.info('[BackgroundSync] Re-submitting: $method $endpoint (ID: $id)');

        try {
          final response = await dio.request<dynamic>(
            endpoint,
            data: method == 'GET' ? null : payload,
            queryParameters: method == 'GET' ? payload : null,
            options: Options(
              method: method,
              headers: {
                'X-Idempotency-Key': id,
                'X-Sync-Timestamp': item['ts'] ?? DateTime.now().toIso8601String(),
              },
            ),
          );

          if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
            AppLogger.info('[BackgroundSync] Successfully synced: $method $endpoint [${response.statusCode}]');
            successCount++;
          } else {
            AppLogger.warn('[BackgroundSync] Unexpected response for $endpoint: ${response.statusCode}');
            await SyncService.reEnqueue(item);
            failureCount++;
          }
        } on DioException catch (dioErr) {
          final statusCode = dioErr.response?.statusCode;
          // Unrecoverable client errors (400 Bad Request, 422 Unprocessable, 403 Forbidden) - drop to avoid infinite loops
          if (statusCode != null && statusCode >= 400 && statusCode < 500 && statusCode != 401 && statusCode != 408 && statusCode != 429) {
            AppLogger.warn('[BackgroundSync] Dropping invalid operation ($statusCode): $method $endpoint - ${dioErr.response?.data}');
            failureCount++;
          } else {
            // Transient network failure or 5xx server error - re-enqueue for next cycle
            AppLogger.warn('[BackgroundSync] Transient error syncing $endpoint ($statusCode). Re-enqueuing.');
            await SyncService.reEnqueue(item);
            failureCount++;
          }
        } catch (e) {
          AppLogger.error('[BackgroundSync] Unknown error executing $method $endpoint: $e');
          await SyncService.reEnqueue(item);
          failureCount++;
        }
      }

      AppLogger.info('[BackgroundSync] Batch sync completed. Success: $successCount, Retried/Dropped: $failureCount');
      return failureCount == 0;
    } catch (e, stack) {
      AppLogger.error('[BackgroundSync] Critical error during background synchronization: $e', e, stack);
      return false;
    }
  }
}


