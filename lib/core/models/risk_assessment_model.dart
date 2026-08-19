import 'package:freezed_annotation/freezed_annotation.dart';

part 'risk_assessment_model.freezed.dart';
part 'risk_assessment_model.g.dart';

@freezed
class RiskAssessmentModel with _$RiskAssessmentModel {
  const factory RiskAssessmentModel({
    required String id,
    required String woredaId,
    required DateTime assessmentDate,
    required String hazardType,
    required String riskLevel,
    required double riskScore,
    required double confidence,
    double? spi30Day,
    double? spi90Day,
    double? dischargeAnomaly,
    double? ndviAnomaly,
    double? vci,
    double? locustRiskRadius,
    double? temperature,
    double? humidity,
    String? recommendations,
    int? processingTimeMs,
    DateTime? createdAt,
  }) = _RiskAssessmentModel;

  factory RiskAssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$RiskAssessmentModelFromJson(json);
}

@freezed
class RiskStatisticsModel with _$RiskStatisticsModel {
  const factory RiskStatisticsModel({
    required String id,
    required String periodType,
    required DateTime periodDate,
    String? regionId,
    String? zoneId,
    required int totalAssessments,
    required int lowRisk,
    required int moderateRisk,
    required int highRisk,
    required int criticalRisk,
    required double avgRiskScore,
    required double avgConfidence,
    String? dominantHazard,
    DateTime? createdAt,
  }) = _RiskStatisticsModel;

  factory RiskStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$RiskStatisticsModelFromJson(json);
}
