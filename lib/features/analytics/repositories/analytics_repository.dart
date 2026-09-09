import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';
import '../models/analytics_model.dart';

class AnalyticsRepository {
  final DioClient _dioClient;

  AnalyticsRepository(this._dioClient);

  /// Get dashboard analytics
  Future<DashboardAnalyticsModel> getDashboardAnalytics() async {
    try {
      final response = await _dioClient.get(ApiConstants.dashboard);
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      return DashboardAnalyticsModel.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get temporal trends
  Future<TemporalTrendModel> getTemporalTrends(String period) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.temporalTrends,
        queryParameters: {'timeframe': period.toUpperCase()},
      );
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      return TemporalTrendModel.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get regional breakdown
  Future<List<RegionalRiskModel>> getRegionalBreakdown() async {
    try {
      final response = await _dioClient.get(ApiConstants.regionalBreakdown);
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      return data.map((json) => RegionalRiskModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get agronomic advisories
  Future<List<String>> getAgronomicAdvisories({String? woredaId}) async {
    try {
      final queryParams = woredaId != null ? {'woredaId': woredaId} : null;
      final response = await _dioClient.get(
        ApiConstants.agronomicAdvisories,
        queryParameters: queryParams,
      );
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      if (rawData is Map && rawData['advisories'] is List) {
        return (rawData['advisories'] as List)
            .map((adv) => (adv['actionEn'] ?? adv['titleEn'] ?? adv.toString()).toString())
            .toList();
      }
      if (rawData is List) {
        return rawData.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch Gemini 2.5 Flash AI graph insights for a woreda
  Future<Map<String, dynamic>> fetchAiInsights({
    required String woredaId,
    String timeframe = 'MONTHLY',
    String language = 'am',
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.analyticsAiInsights,
        data: {'woredaId': woredaId, 'timeframe': timeframe, 'language': language},
      );
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return rawData;
    } on DioException catch (e) {
      AppLogger.error('AI insights fetch failed', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stack) {
      AppLogger.error('Unexpected AI insights error', e, stack);
      throw UnknownError(message: 'Failed to fetch AI insights: ${e.toString()}');
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final message =
          error.response?.data['message'] ?? error.response?.data['error'];
      return message ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}

/// Provider for AnalyticsRepository
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnalyticsRepository(dioClient);
});
