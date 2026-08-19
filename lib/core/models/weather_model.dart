import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_model.freezed.dart';
part 'weather_model.g.dart';

@freezed
class WeatherForecastModel with _$WeatherForecastModel {
  const factory WeatherForecastModel({
    required String source,
    required double latitude,
    required double longitude,
    required String generatedAt,
    required DailyWeatherModel daily,
    String? timezone,
    double? elevation,
  }) = _WeatherForecastModel;

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastModelFromJson(json);
}

@freezed
class DailyWeatherModel with _$DailyWeatherModel {
  const factory DailyWeatherModel({
    required List<String> time,
    @JsonKey(name: 'temperature_2m_max') required List<double> temperatureMax,
    @JsonKey(name: 'temperature_2m_min') required List<double> temperatureMin,
    @JsonKey(name: 'precipitation_sum') required List<double> precipitationSum,
    @JsonKey(name: 'relative_humidity_2m_mean')
    required List<double> relativeHumidity,
    @JsonKey(name: 'windspeed_10m_max') List<double>? windspeedMax,
  }) = _DailyWeatherModel;

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$DailyWeatherModelFromJson(json);
}
