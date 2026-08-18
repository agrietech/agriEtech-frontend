///
/// @file alerts_provider.dart
/// @feature alerts
/// @description Riverpod StateNotifier / AsyncNotifier provider for alerts.
/// @author State Management Developer (alerts)
///
library alerts_provider;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/socket_client.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alerts_repository.dart';

/// Singleton-per-app-session socket connection. connect() is called once
/// from app startup (after auth), disposed on logout.
final socketClientProvider = Provider<SocketClient>((ref) {
  final client = SocketClient();
  ref.onDispose(client.dispose);
  return client;
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository();
});

/// Raw stream of alerts pushed live over WebSocket ('alert:new' / 'emergency:alert').
final alertSocketStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final socket = ref.watch(socketClientProvider);
  return socket.alertStream;
});

/// True while the socket is connected — drive a small "live" indicator with it.
final socketConnectionProvider = StreamProvider<bool>((ref) {
  final socket = ref.watch(socketClientProvider);
  return socket.connectionStream;
});

class AlertsNotifier extends AsyncNotifier<List<AlertModel>> {
  late final AlertsRepository _repository;

  @override
  Future<List<AlertModel>> build() async {
    _repository = ref.read(alertsRepositoryProvider);

    // Re-render the inbox the instant a live alert arrives, without
    // waiting for the next scheduled refresh.
    ref.listen(alertSocketStreamProvider, (previous, next) {
      next.whenData((json) => _onLiveAlert(json));
    });

    final cached = _repository.getCachedAlerts();
    // Kick off a background refresh but don't block first paint on it —
    // cache-first per the offline_sync design.
    unawaited(refresh());
    return cached;
  }

  Future<void> _onLiveAlert(Map<String, dynamic> json) async {
    try {
      final alert = AlertModel.fromJson(json);
      await _repository.upsertAlert(alert);
      state = AsyncData(_repository.getCachedAlerts());
    } catch (_) {
      // Malformed push payload — ignore rather than crash the inbox.
    }
  }

  Future<void> refresh() async {
    try {
      final fresh = await _repository.fetchAlerts();
      state = AsyncData(fresh);
    } catch (_) {
      // Offline or backend unreachable — keep showing cached data,
      // don't flip the inbox into an error state.
    }
  }

  Future<void> markAsRead(String alertId) async {
    await _repository.markAsRead(alertId);
    state = AsyncData(_repository.getCachedAlerts());
  }
}

final alertsProvider = AsyncNotifierProvider<AlertsNotifier, List<AlertModel>>(
  AlertsNotifier.new,
);

final unreadAlertsCountProvider = Provider<int>((ref) {
  final alerts = ref.watch(alertsProvider).valueOrNull ?? [];
  return alerts.where((a) => !a.isRead).length;
});
