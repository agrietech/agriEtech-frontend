/// Weather data models (pure Dart without Freezed)
library weather_model;

class WeatherForecastModel {
  final String source;
  final double latitude;
  final double longitude;
  final String generatedAt;
  final DailyWeatherModel daily;
  final String? timezone;
  final double? elevation;

  const WeatherForecastModel({
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.generatedAt,
    required this.daily,
    this.timezone,
    this.elevation,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final dailyRaw = json['daily'] is Map<String, dynamic>
        ? json['daily'] as Map<String, dynamic>
        : <String, dynamic>{};

    return WeatherForecastModel(
      source: (json['source'] ?? 'Open-Meteo').toString(),
      latitude: ((json['latitude'] ?? 9.145) as num).toDouble(),
      longitude: ((json['longitude'] ?? 40.4897) as num).toDouble(),
      generatedAt: (json['generatedAt'] ?? json['generated_at'] ?? DateTime.now().toIso8601String()).toString(),
      daily: DailyWeatherModel.fromJson(dailyRaw),
      timezone: json['timezone'] as String?,
      elevation: json['elevation'] != null
          ? ((json['elevation'] as num).toDouble())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source,
    'latitude': latitude,
    'longitude': longitude,
    'generatedAt': generatedAt,
    'daily': daily.toJson(),
    if (timezone != null) 'timezone': timezone,
    if (elevation != null) 'elevation': elevation,
  };
}

class DailyWeatherModel {
  final List<String> time;
  final List<double> temperatureMax;
  final List<double> temperatureMin;
  final List<double> precipitationSum;
  final List<double> relativeHumidity;
  final List<double>? windspeedMax;

  const DailyWeatherModel({
    required this.time,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationSum,
    required this.relativeHumidity,
    this.windspeedMax,
  });

  factory DailyWeatherModel.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(dynamic raw, T Function(dynamic) conv) {
      if (raw is List) {
        return raw.map(conv).toList();
      }
      return <T>[];
    }

    return DailyWeatherModel(
      time: parseList<String>(json['time'] ?? json['dates'], (e) => e.toString()),
      temperatureMax: parseList<double>(
        json['temperature_2m_max'] ?? json['temperatureMax'] ?? json['tempMax'],
        (e) => (e as num).toDouble(),
      ),
      temperatureMin: parseList<double>(
        json['temperature_2m_min'] ?? json['temperatureMin'] ?? json['tempMin'],
        (e) => (e as num).toDouble(),
      ),
      precipitationSum: parseList<double>(
        json['precipitation_sum'] ?? json['precipitationSum'] ?? json['rainfall'],
        (e) => (e as num).toDouble(),
      ),
      relativeHumidity: parseList<double>(
        json['relative_humidity_2m_mean'] ?? json['relativeHumidity'] ?? json['humidity'],
        (e) => (e as num).toDouble(),
      ),
      windspeedMax: json['windspeed_10m_max'] != null || json['windspeedMax'] != null
          ? parseList<double>(
              json['windspeed_10m_max'] ?? json['windspeedMax'],
              (e) => (e as num).toDouble(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'temperature_2m_max': temperatureMax,
    'temperature_2m_min': temperatureMin,
    'precipitation_sum': precipitationSum,
    'relative_humidity_2m_mean': relativeHumidity,
    if (windspeedMax != null) 'windspeed_10m_max': windspeedMax,
  };
}
