import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';
import '../models/risk_models.dart';

/// Risk assessment repository
class RiskRepository {
  final DioClient _dioClient;

  RiskRepository(this._dioClient);

  /// Get risk assessments with optional filters
  Future<List<RiskAssessment>> getRiskAssessments({
    String? woredaId,
    String? hazardType,
    String? riskLevel,
  }) async {
    try {
      AppLogger.info('Fetching risk assessments');
      
      final queryParams = <String, dynamic>{};
      if (woredaId != null) queryParams['woredaId'] = woredaId;
      if (hazardType != null) queryParams['hazardType'] = hazardType;
      if (riskLevel != null) queryParams['riskLevel'] = riskLevel;
      
      final response = await _dioClient.get(
        ApiConstants.riskAssessments,
        queryParameters: queryParams,
      );
      
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      final assessments = data
          .map((json) => RiskAssessment.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Risk assessments fetched: ${assessments.length} assessments');
      
      return assessments;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch risk assessments', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk assessments fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch risk assessments: ${e.toString()}');
    }
  }

  /// Get risk assessments for a specific woreda
  Future<List<RiskAssessment>> getWoredaRiskAssessments(String woredaId) async {
    try {
      AppLogger.info('Fetching risk assessments for woreda: $woredaId');
      
      final response = await _dioClient.get(
        ApiConstants.riskByWoreda(woredaId),
      );
      
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      final assessments = data
          .map((json) => RiskAssessment.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Woreda risk assessments fetched: ${assessments.length} assessments');
      
      return assessments;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch woreda risk assessments', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected woreda risk fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch risk data: ${e.toString()}');
    }
  }

  /// Trigger risk evaluation
  Future<void> evaluateRisk(EvaluateRiskRequest request) async {
    try {
      AppLogger.info('Triggering risk evaluation');
      
      await _dioClient.post(
        ApiConstants.evaluateRisk, data: request.toJson(),
      );
      
      AppLogger.info('Risk evaluation triggered successfully');
    } on DioException catch (e) {
      AppLogger.error('Failed to trigger risk evaluation', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk evaluation error', e, stackTrace);
      throw UnknownError(message: 'Failed to evaluate risk: ${e.toString()}');
    }
  }

  /// Get risk statistics for a period
  Future<RiskStatistics> getRiskStatistics(String period) async {
    try {
      AppLogger.info('Fetching risk statistics for period: $period');
      
      final response = await _dioClient.get(
        ApiConstants.riskStats(period),
      );
      
      final stats = RiskStatistics.fromJson(response.data as Map<String, dynamic>);
      
      AppLogger.info('Risk statistics fetched successfully');
      
      return stats;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch risk statistics', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk statistics error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch statistics: ${e.toString()}');
    }
  }

  /// Get risk trends over time
  Future<List<RiskTrendPoint>> getRiskTrends({
    String? hazardType,
    String? woredaId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      AppLogger.info('Fetching risk trends');
      
      final queryParams = <String, dynamic>{};
      if (hazardType != null) queryParams['hazardType'] = hazardType;
      if (woredaId != null) queryParams['woredaId'] = woredaId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      
      final response = await _dioClient.get(
        ApiConstants.temporalTrends,
        queryParameters: queryParams,
      );
      
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      final trends = data
          .map((json) => RiskTrendPoint.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Risk trends fetched: ${trends.length} data points');
      
      return trends;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch risk trends', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk trends error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch trends: ${e.toString()}');
    }
  }
}

/// Provider for RiskRepository
final riskRepositoryProvider = Provider<RiskRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RiskRepository(dioClient);
});

