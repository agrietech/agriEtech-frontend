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
      final List<dynamic> data = response.data;
      return data.map((json) => RiskAssessmentModel.fromJson(json)).toList();
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
      final List<dynamic> data = response.data;
      return data.map((json) => RiskAssessmentModel.fromJson(json)).toList();
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
      return RiskStatisticsModel.fromJson(response.data);
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
      return RiskAssessmentModel.fromJson(response.data);
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
