/// Soil profile model from IoT sensor telemetry
library soil_profile_model;

class SoilProfileModel {
  final String sensorId;
  final String farmId;
  final double soilMoisturePercent;
  final double soilTempC;
  final double? phLevel;
  final double? electricalConductivity;
  final DateTime recordedAt;

  SoilProfileModel({
    required this.sensorId, required this.farmId, required this.soilMoisturePercent,
    required this.soilTempC, this.phLevel, this.electricalConductivity, required this.recordedAt,
  });

  factory SoilProfileModel.fromJson(Map<String, dynamic> json) => SoilProfileModel(
    sensorId: json['sensorId'] as String? ?? '',
    farmId: json['farmId'] as String? ?? '',
    soilMoisturePercent: ((json['soilMoisturePercent'] ?? json['soilMoisture'] ?? json['value'] ?? 0.0) as num).toDouble(),
    soilTempC: ((json['soilTempC'] ?? json['temperature'] ?? 25.0) as num).toDouble(),
    phLevel: (json['phLevel'] as num?)?.toDouble(),
    electricalConductivity: (json['electricalConductivity'] as num?)?.toDouble(),
    recordedAt: json['recordedAt'] != null ? DateTime.parse(json['recordedAt'] as String) : DateTime.now(),
  );

  bool get isMoistureLow => soilMoisturePercent < 20.0;
  bool get isMoistureHigh => soilMoisturePercent > 85.0;
}
