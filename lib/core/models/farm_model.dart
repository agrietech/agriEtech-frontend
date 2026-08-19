import 'package:freezed_annotation/freezed_annotation.dart';

part 'farm_model.freezed.dart';
part 'farm_model.g.dart';

/// Farm irrigation methods
enum IrrigationMethod {
  @JsonValue('RAINFED')
  rainfed,
  @JsonValue('DRIP')
  drip,
  @JsonValue('SPRINKLER')
  sprinkler,
  @JsonValue('FLOOD')
  flood,
  @JsonValue('MANUAL')
  manual,
}

/// Soil types
enum SoilType {
  @JsonValue('CLAY')
  clay,
  @JsonValue('LOAM')
  loam,
  @JsonValue('SANDY')
  sandy,
  @JsonValue('SILT')
  silt,
  @JsonValue('PEAT')
  peat,
  @JsonValue('CHALKY')
  chalky,
}

/// Farm model
@freezed
class FarmModel with _$FarmModel {
  const factory FarmModel({
    required String id,
    required String userId,
    required String farmName,
    required String primaryCrop,
    required double areaHectares,
    required double latitude,
    required double longitude,
    String? soilType,
    String? irrigationType,
    String? additionalCrops,
    String? woredaId,
    @JsonKey(name: 'woreda') WoredaInfo? woreda,
    Map<String, dynamic>? geoJsonBoundary,
    List<SensorModel>? sensors,
    List<DiagnosisHistory>? diagnosisHistory,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
    @JsonKey(name: 'updatedAt') DateTime? updatedAt,
  }) = _FarmModel;

  factory FarmModel.fromJson(Map<String, dynamic> json) =>
      _$FarmModelFromJson(json);
}

/// Woreda info (lightweight)
@freezed
class WoredaInfo with _$WoredaInfo {
  const factory WoredaInfo({
    required String id,
    required String name,
  }) = _WoredaInfo;

  factory WoredaInfo.fromJson(Map<String, dynamic> json) =>
      _$WoredaInfoFromJson(json);
}

/// Sensor model
@freezed
class SensorModel with _$SensorModel {
  const factory SensorModel({
    required String id,
    required String sensorType,
    required String hardwareId,
    @JsonKey(name: 'isActive') @Default(true) bool isActive,
    double? batteryLevel,
    DateTime? lastReading,
    Map<String, dynamic>? calibrationData,
  }) = _SensorModel;

  factory SensorModel.fromJson(Map<String, dynamic> json) =>
      _$SensorModelFromJson(json);
}

/// Diagnosis history
@freezed
class DiagnosisHistory with _$DiagnosisHistory {
  const factory DiagnosisHistory({
    required String id,
    required String disease,
    required double confidence,
    String? treatment,
    DateTime? diagnosedAt,
  }) = _DiagnosisHistory;

  factory DiagnosisHistory.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisHistoryFromJson(json);
}

/// Create farm request
@freezed
class CreateFarmRequest with _$CreateFarmRequest {
  const factory CreateFarmRequest({
    required String farmName,
    required String primaryCrop,
    required double areaHectares,
    required double latitude,
    required double longitude,
    String? soilType,
    String? irrigationType,
    String? additionalCrops,
    Map<String, dynamic>? geoJsonBoundary,
  }) = _CreateFarmRequest;

  factory CreateFarmRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateFarmRequestFromJson(json);
}

/// Update farm request
@freezed
class UpdateFarmRequest with _$UpdateFarmRequest {
  const factory UpdateFarmRequest({
    String? farmName,
    String? primaryCrop,
    double? areaHectares,
    double? latitude,
    double? longitude,
    String? soilType,
    String? irrigationType,
    String? additionalCrops,
    Map<String, dynamic>? geoJsonBoundary,
  }) = _UpdateFarmRequest;

  factory UpdateFarmRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateFarmRequestFromJson(json);
}

/// Common crop types in Ethiopia
class CropTypes {
  static const List<String> common = [
    'Teff',
    'Wheat',
    'Barley',
    'Maize',
    'Sorghum',
    'Millet',
    'Coffee',
    'Cotton',
    'Sugarcane',
    'Chat (Khat)',
    'Pulses (Beans)',
    'Vegetables',
    'Fruits',
    'Spices',
  ];

  static const List<String> ethiopianCrops = common;
}

/// Soil types display names
class SoilTypes {
  static const Map<String, String> displayNames = {
    'CLAY': 'Clay',
    'LOAM': 'Loam',
    'SANDY': 'Sandy',
    'SILT': 'Silt',
    'PEAT': 'Peat',
    'CHALKY': 'Chalky',
  };
}

/// Irrigation types display names
class IrrigationTypes {
  static const Map<String, String> displayNames = {
    'RAINFED': 'Rainfed',
    'DRIP': 'Drip Irrigation',
    'SPRINKLER': 'Sprinkler',
    'FLOOD': 'Flood Irrigation',
    'MANUAL': 'Manual Watering',
  };
}
