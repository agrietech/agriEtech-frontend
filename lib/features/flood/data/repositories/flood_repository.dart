/// Flood repository — GloFAS discharge and risk data
library flood_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/flood_risk_model.dart';

class FloodRepository {
  final DioClient _dio;
  FloodRepository(this._dio);

  Future<FloodRiskModel> getFloodRisk(String woredaId) async {
    final r = await _dio.get(ApiEndpoints.riskByWoreda(woredaId));
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    final data = raw is List ? (raw.isNotEmpty ? raw.first : <String, dynamic>{}) : raw;
    return FloodRiskModel.fromJson(data as Map<String, dynamic>);
  }
}

final floodRepositoryProvider = Provider<FloodRepository>((ref) {
  return FloodRepository(ref.watch(dioClientProvider));
});
