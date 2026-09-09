import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';
import '../models/dashboard_models.dart';

/// Dashboard data repository
class DashboardRepository {
  final DioClient _dioClient;
  DashboardData? _cachedData;

  DashboardRepository(this._dioClient);

  /// Get cached dashboard data if available
  DashboardData? get cachedData => _cachedData;

  /// Get dashboard summary data with offline fallback and jurisdiction filtering
  Future<DashboardData> getDashboardData({
    String? woredaId,
    String? zoneId,
    String? regionId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedData != null && woredaId == null && zoneId == null && regionId == null) {
      // Return cached data immediately if available and fresh (< 2 mins)
      final age = DateTime.now().difference(_cachedData!.updatedAt ?? DateTime.now());
      if (age.inMinutes < 2) {
        return _cachedData!;
      }
    }

    try {
      AppLogger.info('Fetching dashboard data from backend');
      final queryParams = <String, dynamic>{};
      if (woredaId != null) queryParams['woredaId'] = woredaId;
      if (zoneId != null) queryParams['zoneId'] = zoneId;
      if (regionId != null) queryParams['regionId'] = regionId;

      final response = await _dioClient.get(
        ApiConstants.dashboard,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final data = DashboardData.fromJson(raw as Map<String, dynamic>);

      _cachedData = data;
      AppLogger.info('Dashboard data fetched and cached successfully');

      return data;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch dashboard data', e);
      if (_cachedData != null) {
        AppLogger.warn('Returning stale cached dashboard data due to network error');
        return _cachedData!;
      }
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected dashboard fetch error', e, stackTrace);
      if (_cachedData != null) {
        return _cachedData!;
      }
      throw UnknownError(message: 'Failed to fetch dashboard: ${e.toString()}');
    }
  }

  /// Get regional breakdown statistics
  Future<List<RegionalBreakdown>> getRegionalBreakdown() async {
    try {
      AppLogger.info('Fetching regional breakdown');
      
      final response = await _dioClient.get(ApiConstants.regionalBreakdown);
      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = raw is List ? raw : [];
      final breakdown = data
          .map((json) => RegionalBreakdown.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Regional breakdown fetched: ${breakdown.length} regions');
      
      return breakdown;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch regional breakdown', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected regional breakdown error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch regional data: ${e.toString()}');
    }
  }

  /// Get temporal trends for hazards
  Future<List<TrendDataPoint>> getTemporalTrends({
    String? hazardType,
    DateTime? startDate,
    DateTime? endDate,
    String? woredaId,
  }) async {
    try {
      AppLogger.info('Fetching temporal trends');
      
      final queryParams = <String, dynamic>{};
      if (hazardType != null) queryParams['hazardType'] = hazardType;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (woredaId != null) queryParams['woredaId'] = woredaId;
      
      final response = await _dioClient.get(
        ApiConstants.temporalTrends,
        queryParameters: queryParams,
      );
      
      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = raw is List ? raw : (raw is Map ? (raw['metrics'] ?? raw['series'] ?? []) : []);
      final trends = data
          .map((json) => TrendDataPoint.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Temporal trends fetched: ${trends.length} data points');
      
      return trends;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch temporal trends', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected temporal trends error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch trends: ${e.toString()}');
    }
  }

  /// Get agronomic advisories
  Future<List<AgronomicAdvisory>> getAgronomicAdvisories({
    String? category,
    String? cropType,
    String? hazardType,
    int? limit,
  }) async {
    try {
      AppLogger.info('Fetching agronomic advisories');
      
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (cropType != null) queryParams['cropType'] = cropType;
      if (hazardType != null) queryParams['hazardType'] = hazardType;
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await _dioClient.get(
        ApiConstants.agronomicAdvisories,
        queryParameters: queryParams,
      );
      
      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = raw is List ? raw : (raw is Map ? (raw['advisories'] ?? []) : []);
      final advisories = data
          .map((json) => AgronomicAdvisory.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Agronomic advisories fetched: ${advisories.length} items');
      
      return advisories;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch agronomic advisories', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected advisories fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch advisories: ${e.toString()}');
    }
  }

  /// Get risk statistics for a specific period
  Future<Map<String, dynamic>> getRiskStatistics(String period) async {
    try {
      AppLogger.info('Fetching risk statistics for period: $period');
      
      final response = await _dioClient.get(
        ApiConstants.riskStats(period),
      );
      
      AppLogger.info('Risk statistics fetched successfully');
      
      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      return raw as Map<String, dynamic>;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch risk statistics', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk statistics error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch statistics: ${e.toString()}');
    }
  }
}

/// Provider for DashboardRepository
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRepository(dioClient);
});
