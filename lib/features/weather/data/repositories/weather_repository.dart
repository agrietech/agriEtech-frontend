/// Weather repository — historical and forecast data from backend satellite connectors
library weather_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/historical_weather_model.dart';
import '../models/forecast_model.dart';

class WeatherRepository {
  final DioClient _dio;
  WeatherRepository(this._dio);

  Future<List<HistoricalWeatherModel>> getHistorical(String woredaId, {String timeframe = 'MONTHLY'}) async {
    final r = await _dio.get(ApiEndpoints.satelliteObservations, queryParameters: {
      'woredaId': woredaId, 'source': 'CHIRPS', 'timeframe': timeframe,
    });
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => HistoricalWeatherModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<ForecastModel>> getForecast(String woredaId) async {
    // Backend temporal-trends endpoint with AI forecasting
    final r = await _dio.get(ApiEndpoints.analyticsTemporalTrends, queryParameters: {
      'woredaId': woredaId, 'timeframe': 'DAILY',
    });
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    final list = raw is List ? raw : (raw is Map ? (raw['series'] ?? raw['observations'] ?? []) : []);
    return (list as List).map((j) => ForecastModel.fromJson(j as Map<String, dynamic>)).toList();
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository(ref.watch(dioClientProvider));
});
