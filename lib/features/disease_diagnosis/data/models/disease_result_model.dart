import 'package:freezed_annotation/freezed_annotation.dart';

part 'disease_result_model.freezed.dart';
part 'disease_result_model.g.dart';

@freezed
class DiseaseResultModel with _$DiseaseResultModel {
  const factory DiseaseResultModel({
    required String id,
    required String userId,
    String? farmId,
    required String cropType,
    required String diseaseDetected,
    String? description,
    double? confidence,
    List<String>? recommendations,
    String? treatment,
    String? imageUrl,
    String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DiseaseResultModel;

  factory DiseaseResultModel.fromJson(Map<String, dynamic> json) =>
      _$DiseaseResultModelFromJson(json);
}
