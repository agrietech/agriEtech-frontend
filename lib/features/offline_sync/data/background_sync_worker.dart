///
/// @file background_sync_worker.dart
/// @feature offlineSync
/// @description Workmanager background task handler synchronizing offline farmer data when network is restored.
/// @author Offline / Sync Lead
///
/// T5.5: runs even when the app is closed. IMPORTANT — the callback below
/// executes in a separate isolate with no access to app state or the
/// providers created in main(). It must open Hive and build its own
/// DioClient/SyncService from scratch every time it runs.
///
library background_sync_worker;

import 'package:workmanager/workmanager.dart';
import '../../../core/storage/hive_service.dart';
import '../domain/sync_service.dart';

const String kPeriodicSyncTask = 'syncPendingActions';
const String kPeriodicSyncTaskUniqueName = 'backgroundSync';

class BackgroundSyncWorker {
  /// Call once from main(), before runApp().
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kPeriodicSyncTaskUniqueName,
      kPeriodicSyncTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
  }

  static Future<void> cancelAll() => Workmanager().cancelAll();
}

/// Top-level entry point required by Workmanager — must stay outside any
/// class and be annotated with @pragma('vm:entry-point') or the isolate
/// won't find it in release builds.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != kPeriodicSyncTask) {
      return Future.value(true);
    }

    try {
      // Fresh isolate — nothing from the main app is available, so Hive
      // must be (re)opened here before touching pending_actions.
      await HiveService.init();
      final syncService = SyncService();
      await syncService.flushPendingActions();
      return Future.value(true);
    } catch (_) {
      // Returning false tells Workmanager to retry per the backoff policy
      // instead of silently dropping the queue.
      return Future.value(false);
    }
  });
}
