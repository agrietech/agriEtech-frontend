import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_models.freezed.dart';
part 'sensor_models.g.dart';

/// Sensor model
@freezed
class SensorModel with _$SensorModel {
  const factory SensorModel({
    required String id,
    required String farmId,
    required String hardwareId,
    required String sensorType,
    @Default(true) bool isActive,
    String? lastCalibration,
    double? batteryLevel,
    required String createdAt,
    required String updatedAt,
    // Nested farm details
    SensorFarmInfo? farm,
    // Latest reading
    SensorReading? latestReading,
  }) = _SensorModel;

  factory SensorModel.fromJson(Map<String, dynamic> json) =>
      _$SensorModelFromJson(json);
}

/// Sensor farm information
@freezed
class SensorFarmInfo with _$SensorFarmInfo {
  const factory SensorFarmInfo({
    required String id,
    required String farmName,
  }) = _SensorFarmInfo;

  factory SensorFarmInfo.fromJson(Map<String, dynamic> json) =>
      _$SensorFarmInfoFromJson(json);
}

/// Sensor reading model
@freezed
class SensorReading with _$SensorReading {
  const factory SensorReading({
    required String id,
    required String sensorId,
    double? soilMoisture,
    double? soilTemp,
    double? ambientTemp,
    double? humidity,
    double? rainfallMm,
    double? batteryLevel,
    required String recordedAt,
    required String createdAt,
  }) = _SensorReading;

  factory SensorReading.fromJson(Map<String, dynamic> json) =>
      _$SensorReadingFromJson(json);
}

/// Request model for registering sensor
@freezed
class RegisterSensorRequest with _$RegisterSensorRequest {
  const factory RegisterSensorRequest({
    required String farmId,
    required String hardwareId,
    required String sensorType,
    String? lastCalibration,
  }) = _RegisterSensorRequest;

  factory RegisterSensorRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterSensorRequestFromJson(json);
}

/// Sensor statistics
@freezed
class SensorStatistics with _$SensorStatistics {
  const factory SensorStatistics({
    @Default(0) int total,
    @Default(0) int active,
    @Default(0) int inactive,
    @Default(0) int lowBattery,
    Map<String, int>? byType,
    Map<String, int>? byFarm,
  }) = _SensorStatistics;

  factory SensorStatistics.fromJson(Map<String, dynamic> json) =>
      _$SensorStatisticsFromJson(json);
}

/// Telemetry data for charts
@freezed
class TelemetryData with _$TelemetryData {
  const factory TelemetryData({
    required List<SensorReading> readings,
    required String sensorId,
    required String sensorType,
    String? farmName,
  }) = _TelemetryData;

  factory TelemetryData.fromJson(Map<String, dynamic> json) =>
      _$TelemetryDataFromJson(json);
}

/// Sensor filter options
@freezed
class SensorFilters with _$SensorFilters {
  const factory SensorFilters({
    String? farmId,
    String? sensorType,
    bool? isActive,
  }) = _SensorFilters;

  factory SensorFilters.fromJson(Map<String, dynamic> json) =>
      _$SensorFiltersFromJson(json);
}

/// Sensor types enum
class SensorTypes {
  static const String soilMoisture = 'SOIL_MOISTURE';
  static const String temperature = 'TEMPERATURE';
  static const String rainGauge = 'RAIN_GAUGE';
  static const String leafWetness = 'LEAF_WETNESS';

  static const List<String> all = [
    soilMoisture,
    temperature,
    rainGauge,
    leafWetness,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case soilMoisture:
        return 'Soil Moisture';
      case temperature:
        return 'Temperature';
      case rainGauge:
        return 'Rain Gauge';
      case leafWetness:
        return 'Leaf Wetness';
      default:
        return type;
    }
  }

  static String getUnit(String type) {
    switch (type) {
      case soilMoisture:
        return '%';
      case temperature:
        return '°C';
      case rainGauge:
        return 'mm';
      case leafWetness:
        return '%';
      default:
        return '';
    }
  }
}
