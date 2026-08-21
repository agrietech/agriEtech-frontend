/// Sensor and telemetry models (pure Dart without Freezed)
library sensor_models;

/// Sensor model
class SensorModel {
  final String id;
  final String farmId;
  final String hardwareId;
  final String sensorType;
  final bool isActive;
  final String? lastCalibration;
  final double? batteryLevel;
  final String createdAt;
  final String updatedAt;
  final SensorFarmInfo? farm;
  final SensorReading? latestReading;

  const SensorModel({
    required this.id,
    required this.farmId,
    required this.hardwareId,
    required this.sensorType,
    this.isActive = true,
    this.lastCalibration,
    this.batteryLevel,
    this.createdAt = '',
    this.updatedAt = '',
    this.farm,
    this.latestReading,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: (json['id'] ?? '').toString(),
      farmId: (json['farmId'] ?? '').toString(),
      hardwareId: (json['hardwareId'] ?? json['nodeId'] ?? json['id'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? json['type'] ?? 'SOIL_MOISTURE').toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      lastCalibration: json['lastCalibration'] as String?,
      batteryLevel: json['batteryLevel'] != null
          ? ((json['batteryLevel'] as num).toDouble())
          : null,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      farm: json['farm'] is Map<String, dynamic>
          ? SensorFarmInfo.fromJson(json['farm'] as Map<String, dynamic>)
          : null,
      latestReading: json['latestReading'] is Map<String, dynamic>
          ? SensorReading.fromJson(json['latestReading'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmId': farmId,
    'hardwareId': hardwareId,
    'sensorType': sensorType,
    'isActive': isActive,
    if (lastCalibration != null) 'lastCalibration': lastCalibration,
    if (batteryLevel != null) 'batteryLevel': batteryLevel,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (farm != null) 'farm': farm!.toJson(),
    if (latestReading != null) 'latestReading': latestReading!.toJson(),
  };

  SensorModel copyWith({
    String? id,
    String? farmId,
    String? hardwareId,
    String? sensorType,
    bool? isActive,
    String? lastCalibration,
    double? batteryLevel,
    String? createdAt,
    String? updatedAt,
    SensorFarmInfo? farm,
    SensorReading? latestReading,
  }) {
    return SensorModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      hardwareId: hardwareId ?? this.hardwareId,
      sensorType: sensorType ?? this.sensorType,
      isActive: isActive ?? this.isActive,
      lastCalibration: lastCalibration ?? this.lastCalibration,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farm: farm ?? this.farm,
      latestReading: latestReading ?? this.latestReading,
    );
  }
}

/// Sensor farm information
class SensorFarmInfo {
  final String id;
  final String farmName;

  const SensorFarmInfo({
    required this.id,
    required this.farmName,
  });

  factory SensorFarmInfo.fromJson(Map<String, dynamic> json) {
    return SensorFarmInfo(
      id: (json['id'] ?? '').toString(),
      farmName: (json['farmName'] ?? json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'farmName': farmName,
  };
}

/// Sensor reading model
class SensorReading {
  final String id;
  final String sensorId;
  final double? soilMoisture;
  final double? soilTemp;
  final double? ambientTemp;
  final double? humidity;
  final double? rainfallMm;
  final double? batteryLevel;
  final String recordedAt;
  final String createdAt;

  const SensorReading({
    required this.id,
    required this.sensorId,
    this.soilMoisture,
    this.soilTemp,
    this.ambientTemp,
    this.humidity,
    this.rainfallMm,
    this.batteryLevel,
    this.recordedAt = '',
    this.createdAt = '',
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic val) => val != null ? ((val as num).toDouble()) : null;

    return SensorReading(
      id: (json['id'] ?? '').toString(),
      sensorId: (json['sensorId'] ?? '').toString(),
      soilMoisture: toDouble(json['soilMoisture'] ?? json['moisture']),
      soilTemp: toDouble(json['soilTemp']),
      ambientTemp: toDouble(json['ambientTemp'] ?? json['temperature']),
      humidity: toDouble(json['humidity']),
      rainfallMm: toDouble(json['rainfallMm'] ?? json['rainfall']),
      batteryLevel: toDouble(json['batteryLevel']),
      recordedAt: (json['recordedAt'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()).toString(),
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sensorId': sensorId,
    if (soilMoisture != null) 'soilMoisture': soilMoisture,
    if (soilTemp != null) 'soilTemp': soilTemp,
    if (ambientTemp != null) 'ambientTemp': ambientTemp,
    if (humidity != null) 'humidity': humidity,
    if (rainfallMm != null) 'rainfallMm': rainfallMm,
    if (batteryLevel != null) 'batteryLevel': batteryLevel,
    'recordedAt': recordedAt,
    'createdAt': createdAt,
  };
}

/// Request model for registering sensor
class RegisterSensorRequest {
  final String farmId;
  final String hardwareId;
  final String sensorType;
  final String? lastCalibration;

  const RegisterSensorRequest({
    required this.farmId,
    required this.hardwareId,
    required this.sensorType,
    this.lastCalibration,
  });

  factory RegisterSensorRequest.fromJson(Map<String, dynamic> json) {
    return RegisterSensorRequest(
      farmId: (json['farmId'] ?? '').toString(),
      hardwareId: (json['hardwareId'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      lastCalibration: json['lastCalibration'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'farmId': farmId,
    'hardwareId': hardwareId,
    'sensorType': sensorType,
    if (lastCalibration != null) 'lastCalibration': lastCalibration,
  };
}

/// Sensor statistics
class SensorStatistics {
  final int total;
  final int active;
  final int inactive;
  final int lowBattery;
  final Map<String, int>? byType;
  final Map<String, int>? byFarm;

  const SensorStatistics({
    this.total = 0,
    this.active = 0,
    this.inactive = 0,
    this.lowBattery = 0,
    this.byType,
    this.byFarm,
  });

  factory SensorStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return SensorStatistics(
      total: (json['total'] ?? 0) as int,
      active: (json['active'] ?? 0) as int,
      inactive: (json['inactive'] ?? 0) as int,
      lowBattery: (json['lowBattery'] ?? 0) as int,
      byType: parseMap(json['byType']),
      byFarm: parseMap(json['byFarm']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'active': active,
    'inactive': inactive,
    'lowBattery': lowBattery,
    if (byType != null) 'byType': byType,
    if (byFarm != null) 'byFarm': byFarm,
  };
}

/// Telemetry data for charts
class TelemetryData {
  final List<SensorReading> readings;
  final String sensorId;
  final String sensorType;
  final String? farmName;

  const TelemetryData({
    required this.readings,
    required this.sensorId,
    required this.sensorType,
    this.farmName,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    final readingsList = json['readings'] is List
        ? (json['readings'] as List)
            .map((r) => SensorReading.fromJson(r as Map<String, dynamic>))
            .toList()
        : <SensorReading>[];

    return TelemetryData(
      readings: readingsList,
      sensorId: (json['sensorId'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? '').toString(),
      farmName: json['farmName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'readings': readings.map((r) => r.toJson()).toList(),
    'sensorId': sensorId,
    'sensorType': sensorType,
    if (farmName != null) 'farmName': farmName,
  };
}

/// Sensor filter options
class SensorFilters {
  final String? farmId;
  final String? sensorType;
  final bool? isActive;

  const SensorFilters({
    this.farmId,
    this.sensorType,
    this.isActive,
  });

  factory SensorFilters.fromJson(Map<String, dynamic> json) {
    return SensorFilters(
      farmId: json['farmId'] as String?,
      sensorType: json['sensorType'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (farmId != null) 'farmId': farmId,
    if (sensorType != null) 'sensorType': sensorType,
    if (isActive != null) 'isActive': isActive,
  };

  SensorFilters copyWith({
    String? farmId,
    String? sensorType,
    bool? isActive,
  }) {
    return SensorFilters(
      farmId: farmId ?? this.farmId,
      sensorType: sensorType ?? this.sensorType,
      isActive: isActive ?? this.isActive,
    );
  }
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
