import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnosis_models.freezed.dart';
part 'diagnosis_models.g.dart';

/// Disease diagnosis model
@freezed
class DiagnosisModel with _$DiagnosisModel {
  const factory DiagnosisModel({
    required String id,
    required String farmId,
    required String imageUrl,
    String? cropIdentified,
    String? diseaseName,
    double? confidenceScore,
    String? treatment,
    String? preventionTips,
    Map<String, dynamic>? rawResponse,
    @Default('PENDING') String diagnosisStatus,
    required String createdAt,
    // Nested farm details
    FarmBasicInfo? farm,
  }) = _DiagnosisModel;

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisModelFromJson(json);
}

/// Basic farm information for diagnosis
@freezed
class FarmBasicInfo with _$FarmBasicInfo {
  const factory FarmBasicInfo({
    required String id,
    required String farmName,
    String? primaryCrop,
  }) = _FarmBasicInfo;

  factory FarmBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$FarmBasicInfoFromJson(json);
}

/// Request model for creating diagnosis
@freezed
class CreateDiagnosisRequest with _$CreateDiagnosisRequest {
  const factory CreateDiagnosisRequest({
    required String farmId,
    required String imageBase64,
    String? cropType,
  }) = _CreateDiagnosisRequest;

  factory CreateDiagnosisRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDiagnosisRequestFromJson(json);
}

/// Diagnosis statistics
@freezed
class DiagnosisStatistics with _$DiagnosisStatistics {
  const factory DiagnosisStatistics({
    @Default(0) int total,
    @Default(0) int pending,
    @Default(0) int success,
    @Default(0) int failed,
    Map<String, int>? byCrop,
    Map<String, int>? byDisease,
  }) = _DiagnosisStatistics;

  factory DiagnosisStatistics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisStatisticsFromJson(json);
}

/// Diagnosis filter options
@freezed
class DiagnosisFilters with _$DiagnosisFilters {
  const factory DiagnosisFilters({
    String? farmId,
    String? status,
    String? cropType,
    int? limit,
  }) = _DiagnosisFilters;

  factory DiagnosisFilters.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFiltersFromJson(json);
}
