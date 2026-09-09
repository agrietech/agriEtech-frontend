/// Hourly weather forecast model for 24-hour meteorological trends
library hourly_forecast_model;

import '../theme/weather_theme.dart';

class HourlyForecastModel {
  final String time;
  final String hourLabel;
  final double temperatureC;
  final double precipitationProbability;
  final double relativeHumidity;
  final double windSpeedKmh;
  final String weatherCode;
  final String conditionEn;
  final String conditionAm;
  final String conditionType;

  HourlyForecastModel({
    required this.time,
    required this.hourLabel,
    required this.temperatureC,
    required this.precipitationProbability,
    required this.relativeHumidity,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.conditionEn,
    required this.conditionAm,
    required this.conditionType,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      time: json['time']?.toString() ?? '',
      hourLabel: json['hourLabel']?.toString() ?? '',
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 20.0,
      precipitationProbability: (json['precipitationProbability'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relativeHumidity'] as num?)?.toDouble() ?? 50.0,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble() ?? 10.0,
      weatherCode: json['weatherCode']?.toString() ?? '0',
      conditionEn: json['conditionEn']?.toString() ?? 'Clear',
      conditionAm: json['conditionAm']?.toString() ?? 'ጥርት ያለ',
      conditionType: json['conditionType']?.toString() ?? 'sunny',
    );
  }

  WeatherConditionData get conditionData {
    return WeatherTheme.resolve(weatherCode: weatherCode);
  }
}
