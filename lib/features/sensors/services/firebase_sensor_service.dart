import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/network/socket_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/sensor_models.dart';
import '../repositories/sensor_repository.dart';
import '../providers/sensor_provider.dart';

/// Firebase & Realtime IoT Sensor Telemetry Sync Service
/// Integrates Firebase Cloud Messaging topics and Socket.IO real-time telemetry streams
class FirebaseSensorService {
  final SensorRepository _repository;
  final SocketClient _socketClient;
  final StreamController<SensorReading> _liveTelemetryController = StreamController<SensorReading>.broadcast();

  FirebaseSensorService(this._repository, this._socketClient) {
    _initRealtimeListeners();
  }

  Stream<SensorReading> get liveTelemetryStream => _liveTelemetryController.stream;

  void _initRealtimeListeners() {
    // 1. Socket.IO Real-time stream
    _socketClient.on('sensor_reading', (data) {
      if (data is Map<String, dynamic>) {
        try {
          final reading = SensorReading.fromJson(data);
          _liveTelemetryController.add(reading);
          AppLogger.info('Streamed live IoT sensor reading via WebSocket', {'sensorId': reading.sensorId});
        } catch (e) {
          AppLogger.warning('Failed to parse incoming sensor WebSocket packet: $e');
        }
      }
    });

    // 2. Firebase Cloud Messaging sensor topic listeners (Mobile / Native)
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data['type'] == 'SENSOR_TELEMETRY' || message.data['type'] == 'SENSOR_ALERT') {
          AppLogger.info('Received Firebase FCM sensor telemetry message', message.data);
          try {
            final reading = SensorReading.fromJson(Map<String, dynamic>.from(message.data));
            _liveTelemetryController.add(reading);
          } catch (_) {}
        }
      });
    } catch (e) {
      AppLogger.info('Firebase Messaging stream not active in current environment: $e');
    }
  }

  /// Subscribe to specific hardware sensor Firebase topic
  Future<void> subscribeToSensorTopic(String hardwareId) async {
    try {
      final topic = 'sensor_${hardwareId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}';
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      AppLogger.info('Subscribed to Firebase sensor topic: $topic');
    } catch (e) {
      AppLogger.info('Topic subscription skipped (not supported on this platform): $e');
    }
  }

  /// Subscribe to woreda sensor grid Firebase topic
  Future<void> subscribeToWoredaSensors(String woredaId) async {
    try {
      final topic = 'woreda_${woredaId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}_sensors';
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      AppLogger.info('Subscribed to woreda sensor grid topic: $topic');
    } catch (e) {
      AppLogger.info('Woreda sensor topic subscription skipped: $e');
    }
  }

  /// Submit live sensor telemetry probe reading
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

/// Provider for FirebaseSensorService
final firebaseSensorServiceProvider = Provider<FirebaseSensorService>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  final socket = ref.watch(socketClientProvider);
  final service = FirebaseSensorService(repo, socket);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Live stream provider for a specific hardware sensor
final liveSensorStreamProvider = StreamProvider.family<SensorReading, String>((ref, hardwareId) {
  final service = ref.watch(firebaseSensorServiceProvider);
  service.subscribeToSensorTopic(hardwareId);
  return service.liveTelemetryStream.where((r) => r.sensorId == hardwareId);
});
