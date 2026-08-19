/// Woreda model matching backend /api/v1/boundaries/woredas
library woreda_model;

class WoredaModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final String zoneId;
  final String regionId;
  final double? centerLat;
  final double? centerLng;

  WoredaModel({
    required this.id, required this.nameEn, required this.nameAm,
    required this.zoneId, required this.regionId, this.centerLat, this.centerLng,
  });

  factory WoredaModel.fromJson(Map<String, dynamic> json) => WoredaModel(
    id: json['id'] as String? ?? '',
    nameEn: (json['nameEn'] ?? json['name'] ?? '') as String,
    nameAm: (json['nameAm'] ?? json['nameEn'] ?? '') as String,
    zoneId: (json['zoneId'] ?? '') as String,
    regionId: (json['regionId'] ?? '') as String,
    centerLat: ((json['centerLat'] ?? json['lat']) as num?)?.toDouble(),
    centerLng: ((json['centerLng'] ?? json['lng']) as num?)?.toDouble(),
  );

  String localizedName(String lang) => lang == 'am' ? nameAm : nameEn;
}
