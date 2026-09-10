/// Weather state management — clean architecture Riverpod provider
library weather_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/historical_weather_model.dart';
import '../models/forecast_model.dart';
import '../models/hourly_forecast_model.dart';
import '../models/weather_forecast_model.dart';
import '../repositories/weather_repository.dart';

class WeatherState {
  final List<HistoricalWeatherModel> historical;
  final List<ForecastModel> forecast;
  final List<HourlyForecastModel> hourly;
  final ForecastModel? current;
  final Map<String, dynamic>? location;
  final String? selectedWoredaId;
  final String? selectedWoredaName;
  final String? dataSources;
  final bool isLoading;
  final String? error;
  final double? latitude;
  final double? longitude;
  final DateTime? lastUpdated;

  const WeatherState({
    this.historical = const [],
    this.forecast = const [],
    this.hourly = const [],
    this.current,
    this.location,
    this.selectedWoredaId,
    this.selectedWoredaName,
    this.dataSources,
    this.isLoading = false,
    this.error,
    this.latitude,
    this.longitude,
    this.lastUpdated,
  });

  List<ForecastModel> get days => forecast;

  WeatherForecastModel? get forecastModel {
    if (forecast.isEmpty) return null;
    return WeatherForecastModel(
      source: dataSources ?? 'National Meteorological Telemetry',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      generatedAt: DateTime.now().toIso8601String(),
      daily: DailyWeatherModel(
        time: forecast.map((f) => f.date).toList(),
        temperatureMax: forecast.map((f) => f.maxTempC).toList(),
        temperatureMin: forecast.map((f) => f.minTempC).toList(),
        precipitationSum: forecast.map((f) => f.precipitationMm).toList(),
        relativeHumidity: forecast.map((f) => f.relativeHumidity).toList(),
        windspeedMax: forecast.map((f) => f.windSpeedKmh).toList(),
        precipitationProbabilityMax: forecast.map((f) => f.precipitationProbability).toList(),
        uvIndexMax: forecast.map((f) => f.uvIndex).toList(),
        windDirectionDominant: forecast.map((f) => f.windDirectionDeg).toList(),
        weatherCodes: forecast.map((f) => f.weatherCode).toList(),
      ),
    );
  }

  WeatherState copyWith({
    List<HistoricalWeatherModel>? historical,
    List<ForecastModel>? forecast,
    List<HourlyForecastModel>? hourly,
    ForecastModel? current,
    Map<String, dynamic>? location,
    String? selectedWoredaId,
    String? selectedWoredaName,
    String? dataSources,
    bool? isLoading,
    String? error,
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
  }) =>
      WeatherState(
        historical: historical ?? this.historical,
        forecast: forecast ?? this.forecast,
        hourly: hourly ?? this.hourly,
        current: current ?? this.current,
        location: location ?? this.location,
        selectedWoredaId: selectedWoredaId ?? this.selectedWoredaId,
        selectedWoredaName: selectedWoredaName ?? this.selectedWoredaName,
        dataSources: dataSources ?? this.dataSources,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repo;
  WeatherNotifier(this._repo) : super(const WeatherState());

  Future<void> loadForecast({
    String? woredaId,
    double? latitude,
    double? longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      latitude: latitude,
      longitude: longitude,
    );

    try {
      final result = await _repo.getWeatherForecast(
        woredaId: woredaId,
        lat: latitude,
        lng: longitude,
        days: 7,
      );

      final loc = result.location;
      final resolvedWoredaId = loc?['woredaId']?.toString() ?? woredaId ?? 'ET_ADDIS';
      final resolvedWoredaName = loc?['nameEn']?.toString() ?? 'Addis Ababa';

      // Load historical CHIRPS data in parallel for trend charts
      List<HistoricalWeatherModel> hist = [];
      try {
        hist = await _repo.getHistorical(resolvedWoredaId);
      } catch (_) {}

      state = state.copyWith(
        forecast: result.daily,
        hourly: result.hourly,
        current: result.current ?? (result.daily.isNotEmpty ? result.daily.first : null),
        historical: hist,
        location: loc,
        selectedWoredaId: resolvedWoredaId,
        selectedWoredaName: resolvedWoredaName,
        dataSources: result.dataSources,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Select a new woreda interactively from the UI
  Future<void> selectWoreda(String woredaId, {String? woredaName}) async {
    if (woredaName != null) {
      state = state.copyWith(selectedWoredaId: woredaId, selectedWoredaName: woredaName);
    }
    await loadForecast(woredaId: woredaId);
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref.watch(weatherRepositoryProvider));
});
