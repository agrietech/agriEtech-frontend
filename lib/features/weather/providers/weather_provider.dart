/// Weather state management
library weather_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/historical_weather_model.dart';
import '../models/forecast_model.dart';
import '../models/weather_forecast_model.dart';
import '../repositories/weather_repository.dart';

class WeatherState {
  final List<HistoricalWeatherModel> historical;
  final List<ForecastModel> forecast;
  final bool isLoading;
  final String? error;
  final double? latitude;
  final double? longitude;

  const WeatherState({
    this.historical = const [],
    this.forecast = const [],
    this.isLoading = false,
    this.error,
    this.latitude,
    this.longitude,
  });

  List<ForecastModel> get days => forecast;

  WeatherForecastModel? get forecastModel {
    if (forecast.isEmpty) return null;
    return WeatherForecastModel(
      source: 'Open-Meteo',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      generatedAt: DateTime.now().toIso8601String(),
      daily: DailyWeatherModel(
        time: forecast.map((f) => f.date).toList(),
        temperatureMax: forecast.map((f) => f.maxTempC).toList(),
        temperatureMin: forecast.map((f) => f.minTempC).toList(),
        precipitationSum: forecast.map((f) => f.precipitationMm).toList(),
        relativeHumidity: forecast.map((f) => 0.0).toList(),
        windspeedMax: forecast.map((f) => f.windSpeedKmh).toList(),
      ),
    );
  }

  WeatherState copyWith({
    List<HistoricalWeatherModel>? historical,
    List<ForecastModel>? forecast,
    bool? isLoading,
    String? error,
    double? latitude,
    double? longitude,
  }) =>
      WeatherState(
        historical: historical ?? this.historical,
        forecast: forecast ?? this.forecast,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repo;
  WeatherNotifier(this._repo) : super(const WeatherState());

  void setMissingWoredaError() {
    state = state.copyWith(
      isLoading: false,
      error: 'No woreda assigned. Please select a woreda to view weather forecasts.',
    );
  }

  Future<void> load(String woredaId, {double? lat, double? lng}) async {
    if (woredaId.isEmpty) {
      setMissingWoredaError();
      return;
    }
    state = state.copyWith(isLoading: true, error: null, latitude: lat, longitude: lng);
    try {
      final hist = await _repo.getHistorical(woredaId);
      final fcast = await _repo.getForecast(woredaId, lat: lat, lng: lng);
      state = state.copyWith(historical: hist, forecast: fcast, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadForecast({
    String? woredaId,
    double? latitude,
    double? longitude,
  }) async {
    if (woredaId == null || woredaId.isEmpty) {
      setMissingWoredaError();
      return;
    }
    await load(woredaId, lat: latitude, lng: longitude);
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref.watch(weatherRepositoryProvider));
});
