import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/weather_model.dart';

/// Single day forecast item
class DailyForecastItem {
  final DateTime date;
  final double temperature;
  final double temperatureMax;
  final double temperatureMin;
  final double rainfall;
  final double humidity;
  final double windSpeed;

  const DailyForecastItem({
    required this.date,
    required this.temperature,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.rainfall,
    required this.humidity,
    required this.windSpeed,
  });
}

/// Weather screen state
class WeatherState {
  final WeatherForecastModel? forecast;
  final bool isLoading;
  final String? error;

  WeatherState({
    this.forecast,
    this.isLoading = false,
    this.error,
  });

  List<DailyForecastItem> get days {
    if (forecast == null) return [];
    final daily = forecast!.daily;
    return List.generate(daily.time.length, (i) {
      final date = DateTime.tryParse(daily.time[i]) ??
          DateTime.now().add(Duration(days: i));
      final max =
          daily.temperatureMax.length > i ? daily.temperatureMax[i] : 25.0;
      final min =
          daily.temperatureMin.length > i ? daily.temperatureMin[i] : 15.0;
      final rain =
          daily.precipitationSum.length > i ? daily.precipitationSum[i] : 0.0;
      final hum = daily.relativeHumidity.length > i
          ? daily.relativeHumidity[i]
          : 50.0;
      final wind = (daily.windspeedMax != null && daily.windspeedMax!.length > i)
          ? daily.windspeedMax![i]
          : 10.0;
      return DailyForecastItem(
        date: date,
        temperature: (max + min) / 2,
        temperatureMax: max,
        temperatureMin: min,
        rainfall: rain,
        humidity: hum,
        windSpeed: wind,
      );
    });
  }

  WeatherState copyWith({
    WeatherForecastModel? forecast,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Weather state notifier
class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier() : super(WeatherState());

  /// Load forecast data
  Future<void> loadForecast({
    String? woredaId,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Mock forecast data for display
      final now = DateTime.now();
      final dates = List.generate(
          7,
          (i) => now
              .add(Duration(days: i))
              .toIso8601String()
              .substring(0, 10));
      final daily = DailyWeatherModel(
        time: dates,
        temperatureMax: [26.0, 27.5, 25.0, 24.0, 26.5, 28.0, 27.0],
        temperatureMin: [14.0, 15.0, 13.5, 13.0, 14.5, 15.0, 14.0],
        precipitationSum: [0.0, 2.5, 8.0, 12.0, 1.0, 0.0, 0.0],
        relativeHumidity: [55.0, 60.0, 75.0, 80.0, 65.0, 50.0, 52.0],
        windspeedMax: [12.0, 15.0, 18.0, 10.0, 14.0, 11.0, 13.0],
      );

      final forecast = WeatherForecastModel(
        source: 'Open-Meteo',
        latitude: latitude ?? 9.03,
        longitude: longitude ?? 38.74,
        generatedAt: now.toIso8601String(),
        daily: daily,
      );

      state = state.copyWith(
        forecast: forecast,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider for weather screen
final weatherProviderProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});
