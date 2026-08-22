import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/risk_assessment_model.dart';
import '../network/dio_client.dart';

class RiskRepository {
  final DioClient _dioClient;

  RiskRepository(this._dioClient);

  /// Get risk assessments
  Future<List<RiskAssessmentModel>> getRiskAssessments({
    int? limit,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.riskAssessments,
        queryParameters: limit != null ? {'limit': limit} : null,
      );
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      return data.map((json) => RiskAssessmentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get risk assessment by woreda
  Future<List<RiskAssessmentModel>> getRiskByWoreda(String woredaId) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.riskByWoreda(woredaId),
      );
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      return data.map((json) => RiskAssessmentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get risk statistics
  Future<RiskStatisticsModel?> getRiskStatistics(String period) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.riskStats(period),
      );
      if (response.data == null) return null;
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      if (rawData is! Map<String, dynamic>) return null;
      return RiskStatisticsModel.fromJson(rawData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Evaluate risk for woreda
  Future<RiskAssessmentModel> evaluateRisk({
    required String woredaId,
    Map<String, dynamic>? hazardScores,
  }) async {
    try {
      final response = await _dioClient.post(
        '${ApiConstants.riskAssessments}/evaluate',
        data: {
          'woredaId': woredaId,
          if (hazardScores != null) 'hazardScores': hazardScores,
        },
      );
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      return RiskAssessmentModel.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? error.response?.data['error'];
      return message ?? 'An error occurred';
    }
    return error.message ?? 'Network error';
  }
}

/// Provider for RiskRepository
final riskRepositoryProvider = Provider<RiskRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RiskRepository(dioClient);
});
