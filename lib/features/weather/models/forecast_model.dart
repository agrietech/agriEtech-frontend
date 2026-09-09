/// Weather forecast model enriched with world-standard meteorological telemetry
library forecast_model;

import 'dart:math' as math;
import '../theme/weather_theme.dart';

class ForecastModel {
  final String date;
  final double maxTempC;
  final double minTempC;
  final double precipitationMm;
  final double windSpeedKmh;
  final String weatherCode;
  final String description;

  // World-Standard Metrics
  final double? apparentTempMaxC;
  final double? apparentTempMinC;
  final double precipitationProbability; // 0 to 100 %
  final double relativeHumidity; // 0 to 100 %
  final double windDirectionDeg; // 0 to 360 degrees
  final double? windGustsKmh;
  final double uvIndex; // 0 to 11+
  final double surfacePressureHpa; // Standard ~ 1013.25 hPa
  final double? dewPointC;
  final double cloudCover; // 0 to 100 %
  final bool isDay;

  ForecastModel({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.description,
    this.apparentTempMaxC,
    this.apparentTempMinC,
    this.precipitationProbability = 0.0,
    this.relativeHumidity = 55.0,
    this.windDirectionDeg = 120.0,
    this.windGustsKmh,
    this.uvIndex = 5.0,
    this.surfacePressureHpa = 1013.0,
    this.dewPointC,
    this.cloudCover = 20.0,
    this.isDay = true,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final maxTemp = ((json['maxTempC'] ??
            json['tempMaxC'] ??
            json['tempMax'] ??
            json['temperature2mMax'] ??
            json['temperature_2m_max'] ??
            json['nasaPowerTempMax'] ??
            24.0) as num)
        .toDouble();

    final minTemp = ((json['minTempC'] ??
            json['tempMinC'] ??
            json['tempMin'] ??
            json['temperature2mMin'] ??
            json['temperature_2m_min'] ??
            json['nasaPowerTempMin'] ??
            14.0) as num)
        .toDouble();

    final rain = ((json['precipitationMm'] ??
            json['rainfallMm'] ??
            json['precipitation'] ??
            json['precipitation_sum'] ??
            json['rainfall'] ??
            json['chirpsRainfallMm'] ??
            0.0) as num)
        .toDouble();

    final wind = ((json['windSpeedKmh'] ??
            json['windspeed_10m_max'] ??
            json['windSpeed10mMax'] ??
            json['wind_speed_10m'] ??
            12.0) as num)
        .toDouble();

    final humidity = ((json['humidity'] ??
            json['relativeHumidity'] ??
            json['relative_humidity_2m_mean'] ??
            json['relative_humidity_2m'] ??
            58.0) as num)
        .toDouble();

    final precipProb = ((json['precipitationProbability'] ??
            json['precipitation_probability_max'] ??
            json['precipProb'] ??
            (rain > 5.0 ? 80.0 : (rain > 0.5 ? 45.0 : 5.0))) as num)
        .toDouble();

    final uv = ((json['uvIndex'] ??
            json['uv_index_max'] ??
            json['uv_index'] ??
            (rain > 5.0 ? 3.0 : 6.5)) as num)
        .toDouble();

    final pressure = ((json['surfacePressureHpa'] ??
            json['surface_pressure_mean'] ??
            json['surface_pressure'] ??
            json['pressure'] ??
            1013.0) as num)
        .toDouble();

    final windDir = ((json['windDirectionDeg'] ??
            json['wind_direction_10m_dominant'] ??
            json['wind_direction_10m'] ??
            135.0) as num)
        .toDouble();

    final gust = json['windGustsKmh'] != null
        ? (json['windGustsKmh'] as num).toDouble()
        : (json['wind_gusts_10m'] != null
            ? (json['wind_gusts_10m'] as num).toDouble()
            : (wind * 1.5).roundToDouble());

    final cloud = ((json['cloudCover'] ??
            json['cloud_cover'] ??
            (rain > 5.0 ? 90.0 : (rain > 0.5 ? 65.0 : 25.0))) as num)
        .toDouble();

    final wCode = (json['weatherCode'] ??
            json['weather_code'] ??
            (rain > 10.0 ? '65' : (rain > 1.0 ? '61' : '0')))
        .toString();

    final desc = json['description'] as String? ??
        WeatherTheme.resolve(weatherCode: wCode, precipitationMm: rain).nameEn;

    return ForecastModel(
      date: json['date'] as String? ??
          json['period'] as String? ??
          json['observationDate'] as String? ??
          DateTime.now().toIso8601String().split('T')[0],
      maxTempC: maxTemp,
      minTempC: minTemp,
      precipitationMm: rain,
      windSpeedKmh: wind,
      weatherCode: wCode,
      description: desc,
      apparentTempMaxC: json['apparentTempMaxC'] != null
          ? (json['apparentTempMaxC'] as num).toDouble()
          : (json['apparent_temperature_max'] != null
              ? (json['apparent_temperature_max'] as num).toDouble()
              : maxTemp - 0.8),
      apparentTempMinC: json['apparentTempMinC'] != null
          ? (json['apparentTempMinC'] as num).toDouble()
          : (json['apparent_temperature_min'] != null
              ? (json['apparent_temperature_min'] as num).toDouble()
              : minTemp - 1.2),
      precipitationProbability: precipProb,
      relativeHumidity: humidity,
      windDirectionDeg: windDir,
      windGustsKmh: gust,
      uvIndex: uv,
      surfacePressureHpa: pressure,
      dewPointC: json['dewPointC'] != null
          ? (json['dewPointC'] as num).toDouble()
          : (json['dew_point_2m'] != null
              ? (json['dew_point_2m'] as num).toDouble()
              : null),
      cloudCover: cloud,
      isDay: json['is_day'] == null || json['is_day'] == 1,
    );
  }

  // --- Computed Meteorological Properties ---

  /// Mean Temperature
  double get temperature => (maxTempC + minTempC) / 2;
  double get rainfall => precipitationMm;
  double get humidity => relativeHumidity;
  double get windSpeed => windSpeedKmh;
  double get temperatureMax => maxTempC;
  double get temperatureMin => minTempC;
  DateTime get parsedDate => DateTime.tryParse(date) ?? DateTime.now();

  /// Apparent "Feels Like" Temperature
  double get apparentTemp {
    if (apparentTempMaxC != null && apparentTempMinC != null) {
      return (apparentTempMaxC! + apparentTempMinC!) / 2;
    }
    // Steadman Apparent Temperature Formula fallback
    final t = temperature;
    final rh = relativeHumidity;
    final wMs = windSpeedKmh / 3.6;
    final e = (rh / 100) * 6.105 * math.exp((17.27 * t) / (237.7 + t));
    return t + 0.33 * e - 0.70 * wMs - 4.00;
  }

  /// Exact Dew Point in °C (Magnus-Tetens formula)
  double get dewPoint {
    if (dewPointC != null) return dewPointC!;
    const a = 17.27;
    const b = 237.7;
    final alpha = ((a * temperature) / (b + temperature)) +
        math.log(math.max(0.01, relativeHumidity / 100.0));
    return (b * alpha) / (a - alpha);
  }

  /// Comfort description for Dew Point
  String getDewPointComfort(String lang) {
    final dp = dewPoint;
    final isAm = lang.toLowerCase() == 'am';
    final isOm = lang.toLowerCase() == 'om';

    if (dp < 10) {
      if (isAm) return 'ደረቅ እና ቀዝቃዛ';
      if (isOm) return 'Gogaa fi Qorraa';
      return 'Dry & Crisp';
    }
    if (dp <= 16) {
      if (isAm) return 'እጅግ ምቹ ሁኔታ';
      if (isOm) return 'Mijaawaa Qilleensaa';
      return 'Comfortable';
    }
    if (dp <= 20) {
      if (isAm) return 'መካከለኛ እርጥበት አዘል';
      if (isOm) return 'Jiidhinsa Giddu-galeessa';
      return 'Somewhat Humid';
    }
    if (isAm) return 'ከፍተኛ እርጥበትና ሙቀት';
    if (isOm) return 'Jiidha Cimaa';
    return 'Muggy & Heavy';
  }

  /// Explains why Feels-Like differs from actual temperature
  String getFeelsLikeSummary(String lang) {
    final diff = apparentTemp - temperature;
    final isAm = lang.toLowerCase() == 'am';
    final isOm = lang.toLowerCase() == 'om';

    if (diff.abs() < 1.0) {
      if (isAm) return 'ከትክክለኛው የሙቀት መጠን ጋር ተቀራራቢ ነው';
      if (isOm) return 'Ho\'ina qabatamaa wajjin wal fakkaata';
      return 'Similar to the actual temperature';
    }
    if (diff < -1.0) {
      if (isAm) return 'በንፋስ ቅዝቃዜ ምክንያት ዝቅ ብሎ ይሰማል';
      if (isOm) return 'Qilleensa qorraa irraa kan ka\'e gadi bu\'ee dhaga\'ama';
      return 'Wind is making it feel cooler';
    }
    if (isAm) return 'በከፍተኛ እርጥበት ምክንያት ሙቀቱ ጎልቶ ይሰማል';
    if (isOm) return 'Jiidhinsa irraa kan ka\'e ho\'i ol ka\'ee dhaga\'ama';
    return 'Humidity is making it feel warmer';
  }

  /// 16-point Compass Cardinal Direction
  String get windDirectionCardinal {
    const cardinals = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((windDirectionDeg + 11.25) % 360 / 22.5).floor();
    return cardinals[index % 16];
  }

  /// Atmospheric Pressure Benchmark evaluation
  String getPressureTendency(String lang) {
    final isAm = lang.toLowerCase() == 'am';
    final isOm = lang.toLowerCase() == 'om';

    if (surfacePressureHpa < 1005) {
      if (isAm) return 'ዝቅተኛ (የዝናብ ዕድል አለ)';
      if (isOm) return 'Gadi Aanaa (Roobni ni jira)';
      return 'Low • Rain likely';
    }
    if (surfacePressureHpa > 1022) {
      if (isAm) return 'ከፍተኛ (ጥርት ያለ ሰማይ)';
      if (isOm) return 'Olaanaa (Qulqulluu)';
      return 'High • Clear & settled';
    }
    if (isAm) return 'መደበኛ የተረጋጋ ጫና';
    if (isOm) return 'Tasgabbaa\'aa';
    return 'Steady • Normal';
  }

  /// Resolved weather condition representation
  WeatherConditionData get conditionData => WeatherTheme.resolve(
        weatherCode: weatherCode,
        description: description,
        precipitationMm: precipitationMm,
        windSpeedKmh: windSpeedKmh,
        minTempC: minTempC,
      );
}
