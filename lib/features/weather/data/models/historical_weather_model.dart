/// Historical weather model from CHIRPS/Open-Meteo satellite data
library historical_weather_model;

class HistoricalWeatherModel {
  final String period;
  final double rainfallMm;
  final double avgTempC;
  final double maxTempC;
  final double minTempC;
  final String source;

  HistoricalWeatherModel({
    required this.period, required this.rainfallMm, required this.avgTempC,
    required this.maxTempC, required this.minTempC, required this.source,
  });

  factory HistoricalWeatherModel.fromJson(Map<String, dynamic> json) {
    final maxT = ((json['maxTempC'] ?? json['tempMax'] ?? json['tempMaxC'] ?? json['nasaPowerTempMax'] ?? 0.0) as num).toDouble();
    final minT = ((json['minTempC'] ?? json['tempMin'] ?? json['tempMinC'] ?? json['nasaPowerTempMin'] ?? 0.0) as num).toDouble();
    final avgT = ((json['avgTempC'] ?? json['tempMean'] ?? json['temperature'] ?? (maxT > 0 && minT > 0 ? (maxT + minT) / 2 : 0.0)) as num).toDouble();
    return HistoricalWeatherModel(
      period: json['period'] as String? ?? json['date'] as String? ?? json['observationDate'] as String? ?? json['month'] as String? ?? '',
      rainfallMm: ((json['rainfallMm'] ?? json['chirpsRainfallMm'] ?? json['rainfall'] ?? json['precipitation'] ?? json['annualRainfallMm'] ?? 0.0) as num).toDouble(),
      avgTempC: avgT,
      maxTempC: maxT,
      minTempC: minT,
      source: json['source'] as String? ?? 'CHIRPS',
    );
  }
}
