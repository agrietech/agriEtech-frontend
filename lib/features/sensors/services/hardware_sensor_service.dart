import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/socket_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/sensor_models.dart';
import '../repositories/sensor_repository.dart';
import '../providers/sensor_provider.dart';

/// Direct Hardware IoT Sensor Telemetry Stream Service
/// Integrates Socket.IO real-time telemetry streams directly by hardware ID
class HardwareSensorService {
  final SensorRepository _repository;
  final SocketClient _socketClient;
  final StreamController<SensorReading> _liveTelemetryController = StreamController<SensorReading>.broadcast();

  HardwareSensorService(this._repository, this._socketClient) {
    _initRealtimeListeners();
  }

  Stream<SensorReading> get liveTelemetryStream => _liveTelemetryController.stream;

  void _initRealtimeListeners() {
    // Socket.IO Real-time stream for direct hardware ID telemetry
    _socketClient.on('sensor_reading', (data) {
      if (data is Map<String, dynamic>) {
        try {
          final reading = SensorReading.fromJson(data);
          _liveTelemetryController.add(reading);
          AppLogger.info('Streamed live IoT hardware sensor reading via WebSocket', {'sensorId': reading.sensorId});
        } catch (e) {
          AppLogger.warning('Failed to parse incoming hardware sensor WebSocket packet: $e');
        }
      }
    });
  }

  /// Direct hardware sensor telemetry listener hook
  Future<void> subscribeToSensorTopic(String hardwareId) async {
    AppLogger.info('Subscribed to direct hardware sensor stream', {'hardwareId': hardwareId});
  }

  /// Direct woreda sensor grid stream hook
  Future<void> subscribeToWoredaSensors(String woredaId) async {
    AppLogger.info('Subscribed to woreda hardware sensor grid', {'woredaId': woredaId});
  }

  /// Submit live sensor telemetry reading directly by hardware ID
  Future<void> submitReading({
    required String hardwareId,
    required double? soilMoisture,
    required double? temperature,
    required double? humidity,
    required double? batteryLevel,
    Map<String, dynamic>? npk,
  }) async {
    final payload = {
      'hardwareId': hardwareId,
      'nodeId': hardwareId,
      'timestamp': DateTime.now().toIso8601String(),
      if (soilMoisture != null) 'soilMoisture': soilMoisture,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      if (npk != null) 'npk': npk,
    };

    await _repository.submitTelemetry(payload);
  }

  void dispose() {
    _socketClient.off('sensor_reading');
    _liveTelemetryController.close();
  }
}

/// Provider for HardwareSensorService
final hardwareSensorServiceProvider = Provider<HardwareSensorService>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final socket = ref.watch(socketClientProvider);
  final service = HardwareSensorService(repo, socket);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Backward-compatible alias
final firebaseSensorServiceProvider = hardwareSensorServiceProvider;

/// Live stream provider for a specific hardware sensor
final liveSensorStreamProvider = StreamProvider.family<SensorReading, String>((ref, hardwareId) {
  final service = ref.watch(hardwareSensorServiceProvider);
  service.subscribeToSensorTopic(hardwareId);
  return service.liveTelemetryStream.where((r) => r.sensorId == hardwareId);
});


