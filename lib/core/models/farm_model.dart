/// Farm data models (pure Dart without Freezed)
library farm_model;

/// Farm model
class FarmModel {
  final String id;
  final String userId;
  final String farmName;
  final String primaryCrop;
  final double areaHectares;
  final double latitude;
  final double longitude;
  final String? soilType;
  final String? irrigationType;
  final String? additionalCrops;
  final String? woredaId;
  final WoredaInfo? woreda;
  final Map<String, dynamic>? geoJsonBoundary;
  final List<SensorModel>? sensors;
  final List<DiagnosisHistory>? diagnosisHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmModel({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.primaryCrop,
    required this.areaHectares,
    required this.latitude,
    required this.longitude,
    this.soilType,
    this.irrigationType,
    this.additionalCrops,
    this.woredaId,
    this.woreda,
    this.geoJsonBoundary,
    this.sensors,
    this.diagnosisHistory,
    this.createdAt,
    this.updatedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      farmName: (json['farmName'] ?? json['name'] ?? 'Farm Plot').toString(),
      primaryCrop: (json['primaryCrop'] ?? 'Mixed').toString(),
      areaHectares: ((json['areaHectares'] ?? 1.0) as num).toDouble(),
      latitude: ((json['latitude'] ?? 8.54) as num).toDouble(),
      longitude: ((json['longitude'] ?? 39.27) as num).toDouble(),
      soilType: json['soilType'] as String?,
      irrigationType: json['irrigationType'] as String?,
      additionalCrops: json['additionalCrops'] as String?,
      woredaId: (json['woredaId'] ?? json['woreda']?['id']) as String?,
      woreda: json['woreda'] is Map<String, dynamic>
          ? WoredaInfo.fromJson(json['woreda'] as Map<String, dynamic>)
          : null,
      geoJsonBoundary: json['geoJsonBoundary'] is Map<String, dynamic>
          ? json['geoJsonBoundary'] as Map<String, dynamic>
          : (json['polygonGeojson'] as Map<String, dynamic>?),
      sensors: json['sensors'] is List
          ? (json['sensors'] as List)
              .map((s) => SensorModel.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      diagnosisHistory: json['diagnosisHistory'] is List
          ? (json['diagnosisHistory'] as List)
              .map((d) => DiagnosisHistory.fromJson(d as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'farmName': farmName,
    'primaryCrop': primaryCrop,
    'areaHectares': areaHectares,
    'latitude': latitude,
    'longitude': longitude,
    if (soilType != null) 'soilType': soilType,
    if (irrigationType != null) 'irrigationType': irrigationType,
    if (additionalCrops != null) 'additionalCrops': additionalCrops,
    if (woredaId != null) 'woredaId': woredaId,
    if (woreda != null) 'woreda': woreda!.toJson(),
    if (geoJsonBoundary != null) 'geoJsonBoundary': geoJsonBoundary,
    if (sensors != null) 'sensors': sensors!.map((s) => s.toJson()).toList(),
    if (diagnosisHistory != null)
      'diagnosisHistory': diagnosisHistory!.map((d) => d.toJson()).toList(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  FarmModel copyWith({
    String? id,
    String? userId,
    String? farmName,
    String? primaryCrop,
    double? areaHectares,
    double? latitude,
    double? longitude,
    String? soilType,
    String? irrigationType,
    String? additionalCrops,
    String? woredaId,
    WoredaInfo? woreda,
    Map<String, dynamic>? geoJsonBoundary,
    List<SensorModel>? sensors,
    List<DiagnosisHistory>? diagnosisHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      farmName: farmName ?? this.farmName,
      primaryCrop: primaryCrop ?? this.primaryCrop,
      areaHectares: areaHectares ?? this.areaHectares,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      additionalCrops: additionalCrops ?? this.additionalCrops,
      woredaId: woredaId ?? this.woredaId,
      woreda: woreda ?? this.woreda,
      geoJsonBoundary: geoJsonBoundary ?? this.geoJsonBoundary,
      sensors: sensors ?? this.sensors,
      diagnosisHistory: diagnosisHistory ?? this.diagnosisHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Woreda info (lightweight)
class WoredaInfo {
  final String id;
  final String name;

  const WoredaInfo({
    required this.id,
    required this.name,
  });

  factory WoredaInfo.fromJson(Map<String, dynamic> json) {
    return WoredaInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// Sensor model
class SensorModel {
  final String id;
  final String sensorType;
  final String hardwareId;
  final bool isActive;
  final double? batteryLevel;
  final DateTime? lastReading;
  final Map<String, dynamic>? calibrationData;

  const SensorModel({
    required this.id,
    required this.sensorType,
    required this.hardwareId,
    this.isActive = true,
    this.batteryLevel,
    this.lastReading,
    this.calibrationData,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: (json['id'] ?? '').toString(),
      sensorType: (json['sensorType'] ?? json['type'] ?? 'SOIL_MOISTURE').toString(),
      hardwareId: (json['hardwareId'] ?? json['nodeId'] ?? json['id'] ?? '').toString(),
      isActive: json['isActive'] is bool ? json['isActive'] as bool : true,
      batteryLevel: json['batteryLevel'] != null
          ? ((json['batteryLevel'] as num).toDouble())
          : null,
      lastReading: json['lastReading'] != null
          ? DateTime.tryParse(json['lastReading'].toString())
          : null,
      calibrationData: json['calibrationData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sensorType': sensorType,
    'hardwareId': hardwareId,
    'isActive': isActive,
    if (batteryLevel != null) 'batteryLevel': batteryLevel,
    if (lastReading != null) 'lastReading': lastReading!.toIso8601String(),
    if (calibrationData != null) 'calibrationData': calibrationData,
  };
}

/// Diagnosis history
class DiagnosisHistory {
  final String id;
  final String disease;
  final double confidence;
  final String? treatment;
  final DateTime? diagnosedAt;

  const DiagnosisHistory({
    required this.id,
    required this.disease,
    required this.confidence,
    this.treatment,
    this.diagnosedAt,
  });

  factory DiagnosisHistory.fromJson(Map<String, dynamic> json) {
    return DiagnosisHistory(
      id: (json['id'] ?? '').toString(),
      disease: (json['disease'] ?? json['diseaseName'] ?? 'Unknown').toString(),
      confidence: ((json['confidence'] ?? json['confidenceScore'] ?? 0.85) as num).toDouble(),
      treatment: (json['treatment'] ?? json['treatmentEn'] ?? json['treatmentAm']) as String?,
      diagnosedAt: json['diagnosedAt'] != null
          ? DateTime.tryParse(json['diagnosedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'disease': disease,
    'confidence': confidence,
    if (treatment != null) 'treatment': treatment,
    if (diagnosedAt != null) 'diagnosedAt': diagnosedAt!.toIso8601String(),
  };
}

/// Create farm request
class CreateFarmRequest {
  final String farmName;
  final String primaryCrop;
  final double areaHectares;
  final double latitude;
  final double longitude;
  final String? woredaId;
  final String? soilType;
  final String? irrigationType;
  final String? additionalCrops;
  final Map<String, dynamic>? geoJsonBoundary;

  const CreateFarmRequest({
    required this.farmName,
    required this.primaryCrop,
    required this.areaHectares,
    required this.latitude,
    required this.longitude,
    this.woredaId,
    this.soilType,
    this.irrigationType,
    this.additionalCrops,
    this.geoJsonBoundary,
  });

  factory CreateFarmRequest.fromJson(Map<String, dynamic> json) {
    return CreateFarmRequest(
      farmName: (json['farmName'] ?? json['name'] ?? '').toString(),
      primaryCrop: (json['primaryCrop'] ?? '').toString(),
      areaHectares: ((json['areaHectares'] ?? 1.0) as num).toDouble(),
      latitude: ((json['latitude'] ?? 0.0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 0.0) as num).toDouble(),
      woredaId: json['woredaId'] as String?,
      soilType: json['soilType'] as String?,
      irrigationType: json['irrigationType'] as String?,
      additionalCrops: json['additionalCrops'] as String?,
      geoJsonBoundary: json['geoJsonBoundary'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'farmName': farmName,
    'name': farmName,
    'primaryCrop': primaryCrop,
    'cropType': primaryCrop,
    'areaHectares': areaHectares,
    'size': areaHectares,
    'latitude': latitude,
    'longitude': longitude,
    if (woredaId != null) 'woredaId': woredaId,
    if (soilType != null) 'soilType': soilType,
    if (irrigationType != null) 'irrigationType': irrigationType,
    if (additionalCrops != null) 'additionalCrops': additionalCrops,
    if (geoJsonBoundary != null) 'geoJsonBoundary': geoJsonBoundary,
    if (geoJsonBoundary != null) 'polygonGeojson': geoJsonBoundary,
  };
}

/// Update farm request
class UpdateFarmRequest {
  final String? farmName;
  final String? primaryCrop;
  final double? areaHectares;
  final double? latitude;
  final double? longitude;
  final String? woredaId;
  final String? soilType;
  final String? irrigationType;
  final String? additionalCrops;
  final Map<String, dynamic>? geoJsonBoundary;

  const UpdateFarmRequest({
    this.farmName,
    this.primaryCrop,
    this.areaHectares,
    this.latitude,
    this.longitude,
    this.woredaId,
    this.soilType,
    this.irrigationType,
    this.additionalCrops,
    this.geoJsonBoundary,
  });

  factory UpdateFarmRequest.fromJson(Map<String, dynamic> json) {
    return UpdateFarmRequest(
      farmName: json['farmName'] as String?,
      primaryCrop: json['primaryCrop'] as String?,
      areaHectares: json['areaHectares'] != null
          ? ((json['areaHectares'] as num).toDouble())
          : null,
      latitude: json['latitude'] != null
          ? ((json['latitude'] as num).toDouble())
          : null,
      longitude: json['longitude'] != null
          ? ((json['longitude'] as num).toDouble())
          : null,
      woredaId: json['woredaId'] as String?,
      soilType: json['soilType'] as String?,
      irrigationType: json['irrigationType'] as String?,
      additionalCrops: json['additionalCrops'] as String?,
      geoJsonBoundary: json['geoJsonBoundary'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (farmName != null) 'farmName': farmName,
    if (primaryCrop != null) 'primaryCrop': primaryCrop,
    if (areaHectares != null) 'areaHectares': areaHectares,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (woredaId != null) 'woredaId': woredaId,
    if (soilType != null) 'soilType': soilType,
    if (irrigationType != null) 'irrigationType': irrigationType,
    if (additionalCrops != null) 'additionalCrops': additionalCrops,
    if (geoJsonBoundary != null) 'geoJsonBoundary': geoJsonBoundary,
    if (geoJsonBoundary != null) 'polygonGeojson': geoJsonBoundary,
  };
}

/// Common crop types in Ethiopia
class CropTypes {
  static const List<String> common = [
    'Teff',
    'Wheat',
    'Barley',
    'Maize',
    'Sorghum',
    'Coffee',
    'Sesame',
    'Chickpeas',
    'Lentils',
    'Faba Beans',
    'Oilseeds',
    'Vegetables',
    'Fruits',
  ];

  static const List<String> ethiopianCrops = common;
}

/// Soil types in Ethiopia
class SoilTypes {
  static const Map<String, String> displayNames = {
    'CLAY': 'Clay (Vertisol / Black Cotton)',
    'LOAM': 'Loam (Nitisol / Red Clay)',
    'SANDY': 'Sandy / Arenosol',
    'SILT': 'Silt / Fluvisol',
    'VOLCANIC': 'Volcanic Ash (Andosol)',
  };
}

/// Irrigation types in Ethiopia
class IrrigationTypes {
  static const Map<String, String> displayNames = {
    'RAIN_FED': 'Rain-fed Only',
    'DRIP': 'Drip Irrigation',
    'SPRINKLER': 'Sprinkler Irrigation',
    'CANAL': 'Canal / Gravity Furrow',
    'GROUNDWATER_PUMP': 'Groundwater Solar/Motor Pump',
  };
}
