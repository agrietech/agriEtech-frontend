/// Risk dashboard repository — fetches composite risk assessments
library risk_dashboard_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/risk_assessment_model.dart';

class RiskDashboardRepository {
  final DioClient _dio;
  RiskDashboardRepository(this._dio);

  Future<List<RiskAssessmentModel>> getWoredaRisks(String woredaId) async {
    final r = await _dio.get(ApiEndpoints.riskByWoreda(woredaId));
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    final list = raw is List ? raw : [];
    return list.map((j) => RiskAssessmentModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> evaluateRisk(String woredaId) async {
    final r = await _dio.post(ApiEndpoints.evaluateRisk, data: {'woredaId': woredaId});
    return r.data is Map && r.data['data'] != null
        ? r.data['data'] as Map<String, dynamic>
        : r.data as Map<String, dynamic>;
  }
}

final riskDashboardRepositoryProvider = Provider<RiskDashboardRepository>((ref) {
  return RiskDashboardRepository(ref.watch(dioClientProvider));
});
