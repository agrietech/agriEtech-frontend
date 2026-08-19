/// Desert locust proximity alert model
library locust_alert_model;

class LocustAlertModel {
  final String woredaId;
  final double swarmDistanceKm;
  final String riskLevel;
  final String swarmSource;
  final bool activeInfestation;
  final DateTime reportedAt;

  LocustAlertModel({
    required this.woredaId, required this.swarmDistanceKm, required this.riskLevel,
    required this.swarmSource, required this.activeInfestation, required this.reportedAt,
  });

  factory LocustAlertModel.fromJson(Map<String, dynamic> json) => LocustAlertModel(
    woredaId: json['woredaId'] as String? ?? '',
    swarmDistanceKm: ((json['swarmDistanceKm'] ?? json['proximityKm'] ?? 999.0) as num).toDouble(),
    riskLevel: (json['riskLevel'] ?? json['locustRiskLevel'] ?? 'LOW') as String,
    swarmSource: json['swarmSource'] as String? ?? 'UNKNOWN',
    activeInfestation: json['activeInfestation'] as bool? ?? false,
    reportedAt: json['reportedAt'] != null ? DateTime.parse(json['reportedAt'] as String) : DateTime.now(),
  );
}
