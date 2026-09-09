/// Boundary hierarchical models (pure Dart without Freezed)
library boundary_models;

/// Region model (highest level - e.g., Oromia, Amhara)
class RegionModel {
  final String id;
  final String code;
  final String name;
  final Map<String, dynamic>? geojson;
  final String createdAt;
  final String updatedAt;
  final List<ZoneModel> zones;

  const RegionModel({
    required this.id,
    this.code = '',
    required this.name,
    this.geojson,
    this.createdAt = '',
    this.updatedAt = '',
    this.zones = const [],
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    final zonesList = json['zones'] is List
        ? (json['zones'] as List)
            .map((z) => ZoneModel.fromJson(z as Map<String, dynamic>))
            .toList()
        : <ZoneModel>[];

    return RegionModel(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      geojson: json['geojson'] as Map<String, dynamic>?,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      zones: zonesList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    if (geojson != null) 'geojson': geojson,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'zones': zones.map((z) => z.toJson()).toList(),
  };

  RegionModel copyWith({
    String? id,
    String? code,
    String? name,
    Map<String, dynamic>? geojson,
    String? createdAt,
    String? updatedAt,
    List<ZoneModel>? zones,
  }) {
    return RegionModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      geojson: geojson ?? this.geojson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      zones: zones ?? this.zones,
    );
  }
}

/// Zone model (middle level)
class ZoneModel {
  final String id;
  final String regionId;
  final String name;
  final Map<String, dynamic>? geojson;
  final String createdAt;
  final String updatedAt;
  final List<WoredaModel> woredas;
  final RegionBasicInfo? region;

  const ZoneModel({
    required this.id,
    this.regionId = '',
    required this.name,
    this.geojson,
    this.createdAt = '',
    this.updatedAt = '',
    this.woredas = const [],
    this.region,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final woredasList = json['woredas'] is List
        ? (json['woredas'] as List)
            .map((w) => WoredaModel.fromJson(w as Map<String, dynamic>))
            .toList()
        : <WoredaModel>[];

    return ZoneModel(
      id: (json['id'] ?? '').toString(),
      regionId: (json['regionId'] ?? json['region']?['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      geojson: json['geojson'] as Map<String, dynamic>?,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      woredas: woredasList,
      region: json['region'] is Map<String, dynamic>
          ? RegionBasicInfo.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'regionId': regionId,
    'name': name,
    if (geojson != null) 'geojson': geojson,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'woredas': woredas.map((w) => w.toJson()).toList(),
    if (region != null) 'region': region!.toJson(),
  };

  ZoneModel copyWith({
    String? id,
    String? regionId,
    String? name,
    Map<String, dynamic>? geojson,
    String? createdAt,
    String? updatedAt,
    List<WoredaModel>? woredas,
    RegionBasicInfo? region,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      regionId: regionId ?? this.regionId,
      name: name ?? this.name,
      geojson: geojson ?? this.geojson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      woredas: woredas ?? this.woredas,
      region: region ?? this.region,
    );
  }
}

/// Woreda model (lowest level - district)
class WoredaModel {
  final String id;
  final String zoneId;
  final String name;
  final Map<String, dynamic>? geojson;
  final double centerLat;
  final double centerLng;
  final int? population;
  final String createdAt;
  final String updatedAt;
  final ZoneBasicInfo? zone;

  const WoredaModel({
    required this.id,
    this.zoneId = '',
    required this.name,
    this.geojson,
    this.centerLat = 8.54,
    this.centerLng = 39.27,
    this.population,
    this.createdAt = '',
    this.updatedAt = '',
    this.zone,
  });

  factory WoredaModel.fromJson(Map<String, dynamic> json) {
    return WoredaModel(
      id: (json['id'] ?? '').toString(),
      zoneId: (json['zoneId'] ?? json['zone']?['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      geojson: json['geojson'] as Map<String, dynamic>?,
      centerLat: ((json['centerLat'] ?? json['latitude'] ?? 8.54) as num).toDouble(),
      centerLng: ((json['centerLng'] ?? json['longitude'] ?? 39.27) as num).toDouble(),
      population: json['population'] as int?,
      createdAt: (json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      updatedAt: (json['updatedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      zone: json['zone'] is Map<String, dynamic>
          ? ZoneBasicInfo.fromJson(json['zone'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'zoneId': zoneId,
    'name': name,
    if (geojson != null) 'geojson': geojson,
    'centerLat': centerLat,
    'centerLng': centerLng,
    if (population != null) 'population': population,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    if (zone != null) 'zone': zone!.toJson(),
  };

  WoredaModel copyWith({
    String? id,
    String? zoneId,
    String? name,
    Map<String, dynamic>? geojson,
    double? centerLat,
    double? centerLng,
    int? population,
    String? createdAt,
    String? updatedAt,
    ZoneBasicInfo? zone,
  }) {
    return WoredaModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      name: name ?? this.name,
      geojson: geojson ?? this.geojson,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      population: population ?? this.population,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      zone: zone ?? this.zone,
    );
  }
}

/// Kebele model (Admin 4 - Peasant Association with AgroZone & Elevation)
class KebeleModel {
  final String id;
  final String woredaId;
  final String name;
  final double elevationMeters;
  final String agroZone;
  final String dominantSoilType;
  final double soilPh;
  final String? ftcName;
  final double centerLat;
  final double centerLng;

  const KebeleModel({
    required this.id,
    required this.woredaId,
    required this.name,
    this.elevationMeters = 1800,
    this.agroZone = 'WEINA_DEGA',
    this.dominantSoilType = 'Nitisol / Vertisol',
    this.soilPh = 6.5,
    this.ftcName,
    this.centerLat = 8.54,
    this.centerLng = 39.27,
  });

  factory KebeleModel.fromJson(Map<String, dynamic> json) {
    return KebeleModel(
      id: (json['id'] ?? '').toString(),
      woredaId: (json['woredaId'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      elevationMeters: json['elevationMeters'] != null ? (json['elevationMeters'] as num).toDouble() : 1800.0,
      agroZone: (json['agroZone'] ?? 'WEINA_DEGA').toString(),
      dominantSoilType: (json['dominantSoilType'] ?? 'Nitisol / Vertisol').toString(),
      soilPh: json['soilPh'] != null ? (json['soilPh'] as num).toDouble() : 6.5,
      ftcName: json['ftcName'] as String?,
      centerLat: json['centerLat'] != null ? (json['centerLat'] as num).toDouble() : 8.54,
      centerLng: json['centerLng'] != null ? (json['centerLng'] as num).toDouble() : 39.27,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'woredaId': woredaId,
    'name': name,
    'elevationMeters': elevationMeters,
    'agroZone': agroZone,
    'dominantSoilType': dominantSoilType,
    'soilPh': soilPh,
    if (ftcName != null) 'ftcName': ftcName,
    'centerLat': centerLat,
    'centerLng': centerLng,
  };
}

/// Basic region information
class RegionBasicInfo {
  final String id;
  final String code;
  final String name;

  const RegionBasicInfo({
    required this.id,
    this.code = '',
    required this.name,
  });

  factory RegionBasicInfo.fromJson(Map<String, dynamic> json) {
    return RegionBasicInfo(
      id: (json['id'] ?? '').toString(),
      code: (json['code'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
  };
}

/// Basic zone information
class ZoneBasicInfo {
  final String id;
  final String name;
  final RegionBasicInfo? region;

  const ZoneBasicInfo({
    required this.id,
    required this.name,
    this.region,
  });

  factory ZoneBasicInfo.fromJson(Map<String, dynamic> json) {
    return ZoneBasicInfo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['nameEn'] ?? json['nameAm'] ?? '').toString(),
      region: json['region'] is Map<String, dynamic>
          ? RegionBasicInfo.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (region != null) 'region': region!.toJson(),
  };
}

/// Boundary hierarchy for display
class BoundaryHierarchy {
  final RegionModel? selectedRegion;
  final ZoneModel? selectedZone;
  final WoredaModel? selectedWoreda;
  final List<RegionModel> regions;
  final List<ZoneModel> zones;
  final List<WoredaModel> woredas;

  const BoundaryHierarchy({
    this.selectedRegion,
    this.selectedZone,
    this.selectedWoreda,
    this.regions = const [],
    this.zones = const [],
    this.woredas = const [],
  });

  factory BoundaryHierarchy.fromJson(Map<String, dynamic> json) {
    return BoundaryHierarchy(
      selectedRegion: json['selectedRegion'] is Map<String, dynamic>
          ? RegionModel.fromJson(json['selectedRegion'] as Map<String, dynamic>)
          : null,
      selectedZone: json['selectedZone'] is Map<String, dynamic>
          ? ZoneModel.fromJson(json['selectedZone'] as Map<String, dynamic>)
          : null,
      selectedWoreda: json['selectedWoreda'] is Map<String, dynamic>
          ? WoredaModel.fromJson(json['selectedWoreda'] as Map<String, dynamic>)
          : null,
      regions: json['regions'] is List
          ? (json['regions'] as List)
              .map((r) => RegionModel.fromJson(r as Map<String, dynamic>))
              .toList()
          : const [],
      zones: json['zones'] is List
          ? (json['zones'] as List)
              .map((z) => ZoneModel.fromJson(z as Map<String, dynamic>))
              .toList()
          : const [],
      woredas: json['woredas'] is List
          ? (json['woredas'] as List)
              .map((w) => WoredaModel.fromJson(w as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    if (selectedRegion != null) 'selectedRegion': selectedRegion!.toJson(),
    if (selectedZone != null) 'selectedZone': selectedZone!.toJson(),
    if (selectedWoreda != null) 'selectedWoreda': selectedWoreda!.toJson(),
    'regions': regions.map((r) => r.toJson()).toList(),
    'zones': zones.map((z) => z.toJson()).toList(),
    'woredas': woredas.map((w) => w.toJson()).toList(),
  };

  BoundaryHierarchy copyWith({
    RegionModel? selectedRegion,
    ZoneModel? selectedZone,
    WoredaModel? selectedWoreda,
    List<RegionModel>? regions,
    List<ZoneModel>? zones,
    List<WoredaModel>? woredas,
  }) {
    return BoundaryHierarchy(
      selectedRegion: selectedRegion ?? this.selectedRegion,
      selectedZone: selectedZone ?? this.selectedZone,
      selectedWoreda: selectedWoreda ?? this.selectedWoreda,
      regions: regions ?? this.regions,
      zones: zones ?? this.zones,
      woredas: woredas ?? this.woredas,
    );
  }
}

/// Boundary statistics
class BoundaryStatistics {
  final int totalRegions;
  final int totalZones;
  final int totalWoredas;
  final int totalPopulation;
  final Map<String, int>? woredasByZone;
  final Map<String, int>? zonesByRegion;

  const BoundaryStatistics({
    this.totalRegions = 0,
    this.totalZones = 0,
    this.totalWoredas = 0,
    this.totalPopulation = 0,
    this.woredasByZone,
    this.zonesByRegion,
  });

  factory BoundaryStatistics.fromJson(Map<String, dynamic> json) {
    Map<String, int>? parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
      }
      return null;
    }

    return BoundaryStatistics(
      totalRegions: (json['totalRegions'] ?? 0) as int,
      totalZones: (json['totalZones'] ?? 0) as int,
      totalWoredas: (json['totalWoredas'] ?? 0) as int,
      totalPopulation: (json['totalPopulation'] ?? 0) as int,
      woredasByZone: parseMap(json['woredasByZone']),
      zonesByRegion: parseMap(json['zonesByRegion']),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRegions': totalRegions,
    'totalZones': totalZones,
    'totalWoredas': totalWoredas,
    'totalPopulation': totalPopulation,
    if (woredasByZone != null) 'woredasByZone': woredasByZone,
    if (zonesByRegion != null) 'zonesByRegion': zonesByRegion,
  };

  BoundaryStatistics copyWith({
    int? totalRegions,
    int? totalZones,
    int? totalWoredas,
    int? totalPopulation,
    Map<String, int>? woredasByZone,
    Map<String, int>? zonesByRegion,
  }) {
    return BoundaryStatistics(
      totalRegions: totalRegions ?? this.totalRegions,
      totalZones: totalZones ?? this.totalZones,
      totalWoredas: totalWoredas ?? this.totalWoredas,
      totalPopulation: totalPopulation ?? this.totalPopulation,
      woredasByZone: woredasByZone ?? this.woredasByZone,
      zonesByRegion: zonesByRegion ?? this.zonesByRegion,
    );
  }
}
