import 'package:dio/dio.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/sensor_models.dart';

class SensorRepository {
  final DioClient _dioClient;

  SensorRepository(this._dioClient);

  /// Register a new sensor
  Future<SensorModel> registerSensor(RegisterSensorRequest request) async {
    try {
      AppLogger.info('Registering sensor', {
        'farmId': request.farmId,
        'hardwareId': request.hardwareId,
        'sensorType': request.sensorType,
      });

      final response = await _dioClient.post(
        '/sensors',
        data: request.toJson(),
      );

      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      final map = Map<String, dynamic>.from(raw);
      map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
      map['updatedAt'] = map['updatedAt'] ?? map['createdAt'];
      map['sensorType'] = map['sensorType'] ?? map['type'] ?? 'SOIL_MOISTURE';
      map['hardwareId'] = map['hardwareId'] ?? map['nodeId'] ?? map['id'] ?? '';
      map['farmId'] = map['farmId'] ?? '';
      final sensor = SensorModel.fromJson(map);
      AppLogger.success('Sensor registered successfully', {'sensorId': sensor.id});
      return sensor;
    } on DioException catch (e) {
      AppLogger.error('Failed to register sensor', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error registering sensor', e);
      throw const UnknownError(
        message: 'Failed to register sensor',
      );
    }
  }

  /// Get all sensors
  Future<List<SensorModel>> getAllSensors() async {
    try {
      AppLogger.info('Fetching all sensors');

      final response = await _dioClient.get('/sensors');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final sensorsList = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
        map['updatedAt'] = map['updatedAt'] ?? map['createdAt'];
        map['sensorType'] = map['sensorType'] ?? map['type'] ?? 'SOIL_MOISTURE';
        map['hardwareId'] = map['hardwareId'] ?? map['nodeId'] ?? map['id'] ?? '';
        map['farmId'] = map['farmId'] ?? '';
        return SensorModel.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${sensorsList.length} sensors');
      return sensorsList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch sensors', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching sensors', e);
      throw const UnknownError(
        message: 'Failed to fetch sensors',
      );
    }
  }

  /// Get sensors for a specific farm
  Future<List<SensorModel>> getFarmSensors(String farmId) async {
    try {
      AppLogger.info('Fetching sensors for farm', {'farmId': farmId});

      final response = await _dioClient.get('/sensors/farm/$farmId');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final sensorsList = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
        map['updatedAt'] = map['updatedAt'] ?? map['createdAt'];
        map['sensorType'] = map['sensorType'] ?? map['type'] ?? 'SOIL_MOISTURE';
        map['hardwareId'] = map['hardwareId'] ?? map['nodeId'] ?? map['id'] ?? '';
        map['farmId'] = map['farmId'] ?? '';
        return SensorModel.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${sensorsList.length} sensors');
      return sensorsList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch farm sensors', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching farm sensors', e);
      throw const UnknownError(
        message: 'Failed to fetch sensors',
      );
    }
  }

  /// Get sensor telemetry data
  Future<List<SensorReading>> getSensorTelemetry({
    required String sensorId,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    try {
      AppLogger.info('Fetching sensor telemetry', {
        'sensorId': sensorId,
        'startDate': startDate,
        'endDate': endDate,
      });

      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        '/sensors/$sensorId/telemetry',
        queryParameters: queryParams,
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final readings = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
        map['recordedAt'] = map['recordedAt'] ?? map['timestamp'] ?? map['createdAt'];
        map['sensorId'] = map['sensorId'] ?? sensorId;
        map['id'] = map['id'] ?? '';
        return SensorReading.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${readings.length} readings');
      return readings;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch telemetry', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching telemetry', e);
      throw const UnknownError(
        message: 'Failed to fetch telemetry data',
      );
    }
  }

  /// Update sensor status
  Future<SensorModel> updateSensorStatus(String sensorId, bool isActive) async {
    try {
      AppLogger.info('Updating sensor status', {
        'sensorId': sensorId,
        'isActive': isActive,
      });

      final response = await _dioClient.patch(
        '/sensors/$sensorId',
        data: {'isActive': isActive},
      );

      final sensor = SensorModel.fromJson(response.data['data']);
      AppLogger.success('Sensor status updated');
      return sensor;
    } on DioException catch (e) {
      AppLogger.error('Failed to update sensor status', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error updating sensor status', e);
      throw const UnknownError(
        message: 'Failed to update sensor status',
      );
    }
  }

  /// Calculate sensor statistics
  SensorStatistics calculateStatistics(List<SensorModel> sensors) {
    int active = 0;
    int inactive = 0;
    int lowBattery = 0;

    final byType = <String, int>{};
    final byFarm = <String, int>{};

    for (final sensor in sensors) {
      // Count active/inactive
      if (sensor.isActive) {
        active++;
      } else {
        inactive++;
      }

      // Count low battery (< 20%)
      if (sensor.batteryLevel != null && sensor.batteryLevel! < 20) {
        lowBattery++;
      }

      // Count by type
      byType[sensor.sensorType] = (byType[sensor.sensorType] ?? 0) + 1;

      // Count by farm
      if (sensor.farm != null) {
        final farmName = sensor.farm!.farmName;
        byFarm[farmName] = (byFarm[farmName] ?? 0) + 1;
      }
    }

    return SensorStatistics(
      total: sensors.length,
      active: active,
      inactive: inactive,
      lowBattery: lowBattery,
      byType: byType,
      byFarm: byFarm,
    );
  }
}
