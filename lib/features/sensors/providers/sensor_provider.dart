import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/socket_client.dart';
import '../../../core/utils/logger.dart';
import '../models/sensor_models.dart';
import '../repositories/sensor_repository.dart';

/// Sensor repository provider
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SensorRepository(dioClient);
});

/// Sensor list state notifier
class SensorNotifier extends StateNotifier<AsyncValue<List<SensorModel>>> {
  final SensorRepository _repository;
  final SocketClient _socketClient;
  SensorFilters _filters = const SensorFilters();

  SensorNotifier(this._repository, this._socketClient)
      : super(const AsyncValue.loading()) {
    fetchSensors();
    _setupRealtimeListener();
  }

  /// Setup real-time WebSocket listener for sensor updates
  void _setupRealtimeListener() {
    _socketClient.on('sensor_reading', (data) {
      AppLogger.info('Received real-time sensor reading', data);
      // Refresh sensors to get updated battery levels
      fetchSensors();
    });
  }

  /// Fetch sensors
  Future<void> fetchSensors() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (_filters.farmId != null) {
        return await _repository.getFarmSensors(_filters.farmId!);
      }
      return await _repository.getAllSensors();
    });
  }

  /// Refresh sensors
  Future<void> refresh() async {
    await fetchSensors();
  }

  /// Apply filters
  Future<void> applyFilters(SensorFilters filters) async {
    _filters = filters;
    await fetchSensors();
  }

  /// Filter by farm
  Future<void> filterByFarm(String? farmId) async {
    _filters = _filters.copyWith(farmId: farmId);
    await fetchSensors();
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _filters = const SensorFilters();
    await fetchSensors();
  }

  /// Get current filters
  SensorFilters get currentFilters => _filters;

  @override
  void dispose() {
    _socketClient.off('sensor_reading');
    super.dispose();
  }
}

/// Sensor list provider
final sensorListProvider =
    StateNotifierProvider<SensorNotifier, AsyncValue<List<SensorModel>>>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  final socketClient = ref.watch(socketClientProvider);
  return SensorNotifier(repository, socketClient);
});

/// Sensor statistics provider
final sensorStatisticsProvider = Provider<SensorStatistics>((ref) {
  final sensorsAsync = ref.watch(sensorListProvider);
  final repository = ref.watch(sensorRepositoryProvider);

  return sensorsAsync.when(
    data: (sensors) => repository.calculateStatistics(sensors),
    loading: () => const SensorStatistics(),
    error: (_, __) => const SensorStatistics(),
  );
});

/// Active sensors provider
final activeSensorsProvider = Provider<List<SensorModel>>((ref) {
  final sensorsAsync = ref.watch(sensorListProvider);
  return sensorsAsync.when(
    data: (sensors) => sensors.where((s) => s.isActive).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Low battery sensors provider
final lowBatterySensorsProvider = Provider<List<SensorModel>>((ref) {
  final sensorsAsync = ref.watch(sensorListProvider);
  return sensorsAsync.when(
    data: (sensors) => sensors
        .where((s) => s.batteryLevel != null && s.batteryLevel! < 20)
        .toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Sensor telemetry provider
final sensorTelemetryProvider = FutureProvider.family<List<SensorReading>,
    ({String sensorId, String? startDate, String? endDate, int? limit})>(
  (ref, params) async {
    final repository = ref.watch(sensorRepositoryProvider);
    return await repository.getSensorTelemetry(
      sensorId: params.sensorId,
      startDate: params.startDate,
      endDate: params.endDate,
      limit: params.limit,
    );
  },
);

/// Register sensor provider
final registerSensorProvider =
    FutureProvider.family<SensorModel, RegisterSensorRequest>(
  (ref, request) async {
    final repository = ref.watch(sensorRepositoryProvider);
    final sensor = await repository.registerSensor(request);

    // Refresh the sensor list after registering
    ref.invalidate(sensorListProvider);

    return sensor;
  },
);

