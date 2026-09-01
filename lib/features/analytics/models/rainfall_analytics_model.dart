/// Rainfall analytics data model matching backend temporal-trends response
library rainfall_analytics_model;

class RainfallAnalyticsModel {
  final String period;
  final double rainfallMm;
  final double anomalyPercent;
  final String classification; // NORMAL, BELOW_NORMAL, ABOVE_NORMAL

  RainfallAnalyticsModel({
    required this.period,
    required this.rainfallMm,
    required this.anomalyPercent,
    required this.classification,
  });

  factory RainfallAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return RainfallAnalyticsModel(
      period: json['period'] as String? ?? json['date'] as String? ?? '',
      rainfallMm: ((json['rainfallMm'] ?? json['rainfall'] ?? json['value'] ?? 0.0) as num).toDouble(),
      anomalyPercent: ((json['anomalyPercent'] ?? json['anomaly'] ?? 0.0) as num).toDouble(),
      classification: json['classification'] as String? ?? 'NORMAL',
    );
  }
}
