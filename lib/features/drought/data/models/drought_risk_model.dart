/// Drought risk model derived from SPI and NDVI satellite observations
library drought_risk_model;

class DroughtRiskModel {
  final String woredaId;
  final double spiValue;
  final String droughtClass; // NORMAL, MODERATE, SEVERE, EXTREME
  final double ndviAnomaly;
  final String riskLevel;
  final DateTime assessedAt;

  DroughtRiskModel({
    required this.woredaId, required this.spiValue, required this.droughtClass,
    required this.ndviAnomaly, required this.riskLevel, required this.assessedAt,
  });

  factory DroughtRiskModel.fromJson(Map<String, dynamic> json) {
    return DroughtRiskModel(
      woredaId: json['woredaId'] as String? ?? '',
      spiValue: ((json['spiValue'] ?? json['spi'] ?? 0.0) as num).toDouble(),
      droughtClass: json['droughtClass'] as String? ?? json['classification'] as String? ?? 'NORMAL',
      ndviAnomaly: ((json['ndviAnomaly'] ?? json['vciValue'] ?? 0.0) as num).toDouble(),
      riskLevel: (json['riskLevel'] ?? json['compositeRiskLevel'] ?? 'LOW') as String,
      assessedAt: json['assessedAt'] != null
          ? DateTime.parse(json['assessedAt'] as String) : DateTime.now(),
    );
  }

  bool get isCritical => riskLevel == 'CRITICAL' || riskLevel == 'HIGH';
}
