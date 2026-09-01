/// Temperature analytics data model matching backend temporal-trends response
library temperature_analytics_model;

class TemperatureAnalyticsModel {
  final String period;
  final double maxTempC;
  final double minTempC;
  final double avgTempC;

  TemperatureAnalyticsModel({
    required this.period,
    required this.maxTempC,
    required this.minTempC,
    required this.avgTempC,
  });

  factory TemperatureAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TemperatureAnalyticsModel(
      period: json['period'] as String? ?? json['date'] as String? ?? '',
      maxTempC: ((json['maxTempC'] ?? json['maxTemp'] ?? json['tempMax'] ?? 0.0) as num).toDouble(),
      minTempC: ((json['minTempC'] ?? json['minTemp'] ?? json['tempMin'] ?? 0.0) as num).toDouble(),
      avgTempC: ((json['avgTempC'] ?? json['avgTemp'] ?? json['tempMean'] ?? 0.0) as num).toDouble(),
    );
  }
}
