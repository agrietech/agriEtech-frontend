import 'package:freezed_annotation/freezed_annotation.dart';

part 'boundary_models.freezed.dart';
part 'boundary_models.g.dart';

/// Region model (highest level - e.g., Oromia, Amhara)
@freezed
class RegionModel with _$RegionModel {
  const factory RegionModel({
    required String id,
    required String code,
    required String name,
    Map<String, dynamic>? geojson,
    required String createdAt,
    required String updatedAt,
    @Default([]) List<ZoneModel> zones,
  }) = _RegionModel;

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
}

/// Zone model (middle level)
@freezed
class ZoneModel with _$ZoneModel {
  const factory ZoneModel({
    required String id,
    required String regionId,
    required String name,
    Map<String, dynamic>? geojson,
    required String createdAt,
    required String updatedAt,
    @Default([]) List<WoredaModel> woredas,
    // Nested region details
    RegionBasicInfo? region,
  }) = _ZoneModel;

  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneModelFromJson(json);
}

/// Woreda model (lowest level - district)
@freezed
class WoredaModel with _$WoredaModel {
  const factory WoredaModel({
    required String id,
    required String zoneId,
    required String name,
    Map<String, dynamic>? geojson,
    required double centerLat,
    required double centerLng,
    int? population,
    required String createdAt,
    required String updatedAt,
    // Nested zone details
    ZoneBasicInfo? zone,
  }) = _WoredaModel;

  factory WoredaModel.fromJson(Map<String, dynamic> json) =>
      _$WoredaModelFromJson(json);
}

/// Basic region information
@freezed
class RegionBasicInfo with _$RegionBasicInfo {
  const factory RegionBasicInfo({
    required String id,
    required String code,
    required String name,
  }) = _RegionBasicInfo;

  factory RegionBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$RegionBasicInfoFromJson(json);
}

/// Basic zone information
@freezed
class ZoneBasicInfo with _$ZoneBasicInfo {
  const factory ZoneBasicInfo({
    required String id,
    required String name,
    RegionBasicInfo? region,
  }) = _ZoneBasicInfo;

  factory ZoneBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$ZoneBasicInfoFromJson(json);
}

/// Boundary hierarchy for display
@freezed
class BoundaryHierarchy with _$BoundaryHierarchy {
  const factory BoundaryHierarchy({
    RegionModel? selectedRegion,
    ZoneModel? selectedZone,
    WoredaModel? selectedWoreda,
    @Default([]) List<RegionModel> regions,
    @Default([]) List<ZoneModel> zones,
    @Default([]) List<WoredaModel> woredas,
  }) = _BoundaryHierarchy;

  factory BoundaryHierarchy.fromJson(Map<String, dynamic> json) =>
      _$BoundaryHierarchyFromJson(json);
}

/// Boundary statistics
@freezed
class BoundaryStatistics with _$BoundaryStatistics {
  const factory BoundaryStatistics({
    @Default(0) int totalRegions,
    @Default(0) int totalZones,
    @Default(0) int totalWoredas,
    @Default(0) int totalPopulation,
    Map<String, int>? woredasByZone,
    Map<String, int>? zonesByRegion,
  }) = _BoundaryStatistics;

  factory BoundaryStatistics.fromJson(Map<String, dynamic> json) =>
      _$BoundaryStatisticsFromJson(json);
}
