/// Region model matching backend /api/v1/boundaries/regions
library region_model;

class RegionModel {
  final String id;
  final String nameEn;
  final String nameAm;
  final String code;

  RegionModel({required this.id, required this.nameEn, required this.nameAm, required this.code});

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: json['id'] as String? ?? '',
    nameEn: (json['nameEn'] ?? json['name'] ?? '') as String,
    nameAm: (json['nameAm'] ?? json['nameEn'] ?? json['name'] ?? '') as String,
    code: json['code'] as String? ?? '',
  );

  String localizedName(String lang) => lang == 'am' ? nameAm : nameEn;
}
