import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/socket_client.dart';
import '../../../core/utils/logger.dart';
import '../models/alert_models.dart';
import '../repositories/alert_repository.dart';

/// Alert repository provider
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AlertRepository(dioClient);
});

/// Alert list state notifier
class AlertNotifier extends StateNotifier<AsyncValue<List<AlertModel>>> {
  final AlertRepository _repository;
  final SocketClient _socketClient;

  AlertFilters _filters = const AlertFilters();

  AlertNotifier(this._repository, this._socketClient)
      : super(const AsyncValue.loading()) {
    _initializeAlerts();
    _setupRealtimeListener();
  }

  /// Initialize alerts
  Future<void> _initializeAlerts() async {
    await fetchAlerts();
  }

  /// Setup real-time WebSocket listener
  void _setupRealtimeListener() {
    _socketClient.on('new_alert', (data) {
      AppLogger.info('Received real-time alert', data);
      // Add new alert to the beginning of the list
      state.whenData((alerts) {
        try {
          final newAlert = AlertModel.fromJson(data);
          state = AsyncValue.data([newAlert, ...alerts]);
        } catch (e) {
          AppLogger.error('Failed to parse real-time alert', e);
        }
      });
    });

    _socketClient.on('alert_updated', (data) {
      AppLogger.info('Alert updated', data);
      // Update existing alert in the list
      state.whenData((alerts) {
        try {
          final updatedAlert = AlertModel.fromJson(data);
          final updatedList = alerts.map((alert) {
            return alert.id == updatedAlert.id ? updatedAlert : alert;
          }).toList();
          state = AsyncValue.data(updatedList);
        } catch (e) {
          AppLogger.error('Failed to parse updated alert', e);
        }
      });
    });
  }

  /// Fetch alerts with current filters
  Future<void> fetchAlerts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.getAlerts(
        woredaId: _filters.woredaId,
        severity: _filters.severity,
        hazardType: _filters.hazardType,
      );
    });
  }

  /// Refresh alerts
  Future<void> refresh() async {
    await fetchAlerts();
  }

  /// Apply filters
  Future<void> applyFilters(AlertFilters filters) async {
    _filters = filters;
    await fetchAlerts();
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _filters = const AlertFilters();
    await fetchAlerts();
  }

  /// Filter by severity
  Future<void> filterBySeverity(String? severity) async {
    _filters = _filters.copyWith(severity: severity);
    await fetchAlerts();
  }

  /// Filter by hazard type
  Future<void> filterByHazardType(String? hazardType) async {
    _filters = _filters.copyWith(hazardType: hazardType);
    await fetchAlerts();
  }

  /// Filter by woreda
  Future<void> filterByWoreda(String? woredaId) async {
    _filters = _filters.copyWith(woredaId: woredaId);
    await fetchAlerts();
  }

  /// Get current filters
  AlertFilters get currentFilters => _filters;

  @override
  void dispose() {
    _socketClient.off('new_alert');
    _socketClient.off('alert_updated');
    super.dispose();
  }
}

/// Alert list provider
final alertListProvider =
    StateNotifierProvider<AlertNotifier, AsyncValue<List<AlertModel>>>((ref) {
  final repository = ref.watch(alertRepositoryProvider);
  final socketClient = ref.watch(socketClientProvider);
  return AlertNotifier(repository, socketClient);
});

/// Alert statistics provider
final alertStatisticsProvider = Provider<AlertStatistics>((ref) {
  final alertsAsync = ref.watch(alertListProvider);
  final repository = ref.watch(alertRepositoryProvider);

  return alertsAsync.when(
    data: (alerts) => repository.calculateStatistics(alerts),
    loading: () => const AlertStatistics(),
    error: (_, __) => const AlertStatistics(),
  );
});

/// Critical alerts provider
final criticalAlertsProvider = Provider<List<AlertModel>>((ref) {
  final alertsAsync = ref.watch(alertListProvider);
  return alertsAsync.when(
    data: (alerts) =>
        alerts.where((alert) => alert.severity == 'CRITICAL').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Active alerts provider
final activeAlertsProvider = Provider<List<AlertModel>>((ref) {
  final alertsAsync = ref.watch(alertListProvider);
  return alertsAsync.when(
    data: (alerts) => alerts.where((alert) => alert.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Create alert provider
final createAlertProvider =
    FutureProvider.family<AlertModel, CreateAlertRequest>(
  (ref, request) async {
    final repository = ref.watch(alertRepositoryProvider);
    final alert = await repository.createAlert(request);
    
    // Refresh the alert list after creating
    ref.invalidate(alertListProvider);
    
    return alert;
  },
);

