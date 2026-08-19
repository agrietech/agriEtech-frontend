import 'package:freezed_annotation/freezed_annotation.dart';

part 'risk_models.freezed.dart';
part 'risk_models.g.dart';

/// Hazard types
enum HazardType {
  @JsonValue('DROUGHT')
  drought,
  @JsonValue('FLOOD')
  flood,
  @JsonValue('LOCUST_PEST')
  locustPest,
  @JsonValue('VEGETATION_STRESS')
  vegetationStress,
  @JsonValue('FROST')
  frost,
  @JsonValue('HEAT_STRESS')
  heatStress,
}

/// Risk levels
enum RiskLevel {
  @JsonValue('LOW')
  low,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
}

/// Risk assessment model
@freezed
class RiskAssessment with _$RiskAssessment {
  const factory RiskAssessment({
    required String id,
    required String woredaId,
    required String hazardType,
    required String riskLevel,
    required double riskScore,
    required double confidence,
    String? description,
    Map<String, dynamic>? indicators,
    int? affectedPopulation,
    @JsonKey(name: 'assessedAt') required DateTime assessedAt,
    @JsonKey(name: 'woreda') WoredaDetails? woreda,
  }) = _RiskAssessment;

  factory RiskAssessment.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentFromJson(json);
}

/// Woreda details
@freezed
class WoredaDetails with _$WoredaDetails {
  const factory WoredaDetails({
    required String id,
    required String name,
    String? zoneName,
    String? regionName,
  }) = _WoredaDetails;

  factory WoredaDetails.fromJson(Map<String, dynamic> json) =>
      _$WoredaDetailsFromJson(json);
}

/// Evaluate risk request
@freezed
class EvaluateRiskRequest with _$EvaluateRiskRequest {
  const factory EvaluateRiskRequest({
    String? woredaId,
    String? hazardType,
  }) = _EvaluateRiskRequest;

  factory EvaluateRiskRequest.fromJson(Map<String, dynamic> json) =>
      _$EvaluateRiskRequestFromJson(json);
}

/// Risk statistics response
@freezed
class RiskStatistics with _$RiskStatistics {
  const factory RiskStatistics({
    required String period,
    @Default(0) int totalAssessments,
    @Default(0) int lowRisk,
    @Default(0) int moderateRisk,
    @Default(0) int highRisk,
    @Default(0) int criticalRisk,
    Map<String, HazardStats>? hazardBreakdown,
    Map<String, int>? regionBreakdown,
  }) = _RiskStatistics;

  factory RiskStatistics.fromJson(Map<String, dynamic> json) =>
      _$RiskStatisticsFromJson(json);
}

/// Hazard statistics
@freezed
class HazardStats with _$HazardStats {
  const factory HazardStats({
    @Default(0) int count,
    @Default(0.0) double averageRisk,
    @Default(0) int affectedWoredas,
  }) = _HazardStats;

  factory HazardStats.fromJson(Map<String, dynamic> json) =>
      _$HazardStatsFromJson(json);
}

/// Risk trend data point
@freezed
class RiskTrendPoint with _$RiskTrendPoint {
  const factory RiskTrendPoint({
    required DateTime date,
    required String hazardType,
    required double riskScore,
    @Default(0) int affectedWoredas,
  }) = _RiskTrendPoint;

  factory RiskTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$RiskTrendPointFromJson(json);
}

/// Hazard type utilities
class HazardTypeUtils {
  static const Map<String, String> displayNames = {
    'DROUGHT': 'Drought',
    'FLOOD': 'Flood',
    'LOCUST_PEST': 'Locust/Pest',
    'VEGETATION_STRESS': 'Vegetation Stress',
    'FROST': 'Frost',
    'HEAT_STRESS': 'Heat Stress',
  };

  static const Map<String, String> descriptions = {
    'DROUGHT': 'Low rainfall and water scarcity',
    'FLOOD': 'Excessive rainfall and flooding',
    'LOCUST_PEST': 'Locust swarms and pest infestation',
    'VEGETATION_STRESS': 'Poor crop health and vegetation',
    'FROST': 'Low temperatures and frost damage',
    'HEAT_STRESS': 'High temperatures affecting crops',
  };

  static String getDisplayName(String hazardType) {
    return displayNames[hazardType] ?? hazardType;
  }

  static String getDescription(String hazardType) {
    return descriptions[hazardType] ?? '';
  }

  static List<String> get allHazardTypes => displayNames.keys.toList();
}

/// Risk level utilities
class RiskLevelUtils {
  static const Map<String, String> displayNames = {
    'LOW': 'Low Risk',
    'MODERATE': 'Moderate Risk',
    'HIGH': 'High Risk',
    'CRITICAL': 'Critical Risk',
  };

  static String getDisplayName(String riskLevel) {
    return displayNames[riskLevel] ?? riskLevel;
  }

  static int getRiskPriority(String riskLevel) {
    switch (riskLevel) {
      case 'CRITICAL':
        return 4;
      case 'HIGH':
        return 3;
      case 'MODERATE':
        return 2;
      case 'LOW':
        return 1;
      default:
        return 0;
    }
  }
}
