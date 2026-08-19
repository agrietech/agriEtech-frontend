/// NDVI vegetation health model from satellite observations
library ndvi_model;

class NdviModel {
  final String woredaId;
  final String period;
  final double ndviValue;
  final double vciValue;
  final String healthStatus; // HEALTHY, STRESSED, SEVERELY_STRESSED
  final DateTime observedAt;

  NdviModel({
    required this.woredaId, required this.period, required this.ndviValue,
    required this.vciValue, required this.healthStatus, required this.observedAt,
  });

  factory NdviModel.fromJson(Map<String, dynamic> json) => NdviModel(
    woredaId: json['woredaId'] as String? ?? '',
    period: json['period'] as String? ?? json['date'] as String? ?? '',
    ndviValue: ((json['ndviValue'] ?? json['ndvi'] ?? json['value'] ?? 0.0) as num).toDouble(),
    vciValue: ((json['vciValue'] ?? json['vci'] ?? 0.0) as num).toDouble(),
    healthStatus: json['healthStatus'] as String? ?? json['classification'] as String? ?? 'HEALTHY',
    observedAt: json['observedAt'] != null ? DateTime.parse(json['observedAt'] as String) : DateTime.now(),
  );
}
