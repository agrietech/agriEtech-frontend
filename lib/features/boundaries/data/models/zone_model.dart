/// Zone model matching backend /api/v1/boundaries/zones
library zone_model;

class ZoneModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final String regionId;
  final String code;

  ZoneModel({required this.id, required this.nameEn, required this.nameAm, required this.regionId, required this.code});

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
    id: json['id'] as String? ?? '',
    nameEn: (json['nameEn'] ?? json['name'] ?? '') as String,
    nameAm: (json['nameAm'] ?? json['nameEn'] ?? '') as String,
    regionId: json['regionId'] as String? ?? '',
    code: json['code'] as String? ?? '',
  );

  String localizedName(String lang) => lang == 'am' ? nameAm : nameEn;
}
