import 'package:freezed_annotation/freezed_annotation.dart';

part 'boundary_model.freezed.dart';
part 'boundary_model.g.dart';

@freezed
class RegionModel with _$RegionModel {
  const factory RegionModel({
    required String id,
    required String name,
    required String code,
    Map<String, dynamic>? boundary,
    double? centerLat,
    double? centerLng,
    int? population,
  }) = _RegionModel;

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
}

@freezed
class ZoneModel with _$ZoneModel {
  const factory ZoneModel({
    required String id,
    required String name,
    required String code,
    required String regionId,
    Map<String, dynamic>? boundary,
    double? centerLat,
    double? centerLng,
  }) = _ZoneModel;

  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneModelFromJson(json);
}

@freezed
class WoredaModel with _$WoredaModel {
  const factory WoredaModel({
    required String id,
    required String name,
    required String code,
    required String zoneId,
    Map<String, dynamic>? boundary,
    double? centerLat,
    double? centerLng,
    int? population,
  }) = _WoredaModel;

  factory WoredaModel.fromJson(Map<String, dynamic> json) =>
      _$WoredaModelFromJson(json);
}
