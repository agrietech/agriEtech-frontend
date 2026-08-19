import 'package:freezed_annotation/freezed_annotation.dart';

part 'disease_diagnosis_model.freezed.dart';
part 'disease_diagnosis_model.g.dart';

@freezed
class DiseaseDiagnosisModel with _$DiseaseDiagnosisModel {
  const factory DiseaseDiagnosisModel({
    required String id,
    required String farmId,
    required String cropType,
    required String imageUrl,
    required List<DiagnosisResult> results,
    required double confidence,
    String? treatmentRecommendation,
    String? preventionAdvice,
    DateTime? diagnosedAt,
    DateTime? createdAt,
  }) = _DiseaseDiagnosisModel;

  factory DiseaseDiagnosisModel.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDiagnosisModelFromJson(json);
}

@freezed
class DiagnosisResult with _$DiagnosisResult {
  const factory DiagnosisResult({
    required String diseaseName,
    required double probability,
    String? description,
    List<String>? symptoms,
  }) = _DiagnosisResult;

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisResultFromJson(json);
}

@freezed
class DiagnosisRequest with _$DiagnosisRequest {
  const factory DiagnosisRequest({
    required String farmId,
    required String cropType,
    required String imageBase64,
  }) = _DiagnosisRequest;

  factory DiagnosisRequest.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisRequestFromJson(json);
}
