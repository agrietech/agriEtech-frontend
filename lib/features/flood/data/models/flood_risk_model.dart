/// Flood risk model from GloFAS river discharge data
library flood_risk_model;

class FloodRiskModel {
  final String woredaId;
  final double riverDischarge;
  final double returnPeriodThreshold;
  final String riskLevel;
  final bool floodAlert;
  final DateTime assessedAt;

  FloodRiskModel({
    required this.woredaId, required this.riverDischarge, required this.returnPeriodThreshold,
    required this.riskLevel, required this.floodAlert, required this.assessedAt,
  });

  factory FloodRiskModel.fromJson(Map<String, dynamic> json) => FloodRiskModel(
    woredaId: json['woredaId'] as String? ?? '',
    riverDischarge: ((json['riverDischarge'] ?? json['discharge'] ?? 0.0) as num).toDouble(),
    returnPeriodThreshold: ((json['returnPeriodThreshold'] ?? 0.0) as num).toDouble(),
    riskLevel: (json['riskLevel'] ?? json['floodRiskLevel'] ?? 'LOW') as String,
    floodAlert: json['floodAlert'] as bool? ?? json['riskLevel'] == 'HIGH' || json['riskLevel'] == 'CRITICAL',
    assessedAt: json['assessedAt'] != null ? DateTime.parse(json['assessedAt'] as String) : DateTime.now(),
  );
}
