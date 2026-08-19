/// Weather forecast model from Open-Meteo backend connector
library forecast_model;

class ForecastModel {
  final String date;
  final double maxTempC;
  final double minTempC;
  final double precipitationMm;
  final double windSpeedKmh;
  final String weatherCode;
  final String description;

  ForecastModel({
    required this.date, required this.maxTempC, required this.minTempC,
    required this.precipitationMm, required this.windSpeedKmh,
    required this.weatherCode, required this.description,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) => ForecastModel(
    date: json['date'] as String? ?? json['period'] as String? ?? '',
    maxTempC: ((json['maxTempC'] ?? json['tempMax'] ?? json['temperature2mMax'] ?? 30.0) as num).toDouble(),
    minTempC: ((json['minTempC'] ?? json['tempMin'] ?? json['temperature2mMin'] ?? 15.0) as num).toDouble(),
    precipitationMm: ((json['precipitationMm'] ?? json['precipitation'] ?? 0.0) as num).toDouble(),
    windSpeedKmh: ((json['windSpeedKmh'] ?? json['windSpeed10mMax'] ?? 0.0) as num).toDouble(),
    weatherCode: json['weatherCode'] as String? ?? '0',
    description: json['description'] as String? ?? json['weatherCode'] as String? ?? 'Clear',
  );

  double get temperature => (maxTempC + minTempC) / 2;
  double get rainfall => precipitationMm;
  double get humidity => 60.0;
  double get windSpeed => windSpeedKmh;
  double get temperatureMax => maxTempC;
  double get temperatureMin => minTempC;
  DateTime get parsedDate => DateTime.tryParse(date) ?? DateTime.now();
}
