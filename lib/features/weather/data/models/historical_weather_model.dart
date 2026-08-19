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

  factory HistoricalWeatherModel.fromJson(Map<String, dynamic> json) => HistoricalWeatherModel(
    period: json['period'] as String? ?? json['date'] as String? ?? '',
    rainfallMm: ((json['rainfallMm'] ?? json['rainfall'] ?? json['precipitation'] ?? 0.0) as num).toDouble(),
    avgTempC: ((json['avgTempC'] ?? json['tempMean'] ?? json['temperature'] ?? 0.0) as num).toDouble(),
    maxTempC: ((json['maxTempC'] ?? json['tempMax'] ?? 0.0) as num).toDouble(),
    minTempC: ((json['minTempC'] ?? json['tempMin'] ?? 0.0) as num).toDouble(),
    source: json['source'] as String? ?? 'CHIRPS',
  );
}
