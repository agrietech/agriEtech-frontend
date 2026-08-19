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

  DashboardRepository(this._dioClient);

  /// Get dashboard summary data
  Future<DashboardData> getDashboardData() async {
    try {
      AppLogger.info('Fetching dashboard data');
      
      final response = await _dioClient.get(ApiConstants.dashboard);
      
      final data = DashboardData.fromJson(response.data);
      
      AppLogger.info('Dashboard data fetched successfully');
      
      return data;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch dashboard data', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected dashboard fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch dashboard: ${e.toString()}');
    }
  }

  /// Get regional breakdown statistics
  Future<List<RegionalBreakdown>> getRegionalBreakdown() async {
    try {
      AppLogger.info('Fetching regional breakdown');
      
      final response = await _dioClient.get(ApiConstants.regionalBreakdown);
      
      final List<dynamic> data = response.data as List<dynamic>;
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
      
      final List<dynamic> data = response.data as List<dynamic>;
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
      
      final List<dynamic> data = response.data as List<dynamic>;
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
      
      return response.data as Map<String, dynamic>;
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
