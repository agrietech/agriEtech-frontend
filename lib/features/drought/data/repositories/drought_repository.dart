/// Drought repository — fetches SPI and risk data from backend
library drought_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/drought_risk_model.dart';

class DroughtRepository {
  final DioClient _dio;
  DroughtRepository(this._dio);

  Future<DroughtRiskModel> getWoredaDroughtRisk(String woredaId) async {
    final r = await _dio.get(ApiEndpoints.riskByWoreda(woredaId));
    final raw = r.data is Map && r.data['data'] != null
        ? r.data['data'] : r.data;
    // Extract drought-specific fields from composite risk response
    final data = raw is List ? (raw.isNotEmpty ? raw.first : {}) : raw;
    return DroughtRiskModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getWoredaSatelliteObs(String woredaId, {String source = 'CHIRPS'}) async {
    final r = await _dio.get(ApiEndpoints.satelliteObservations, queryParameters: {'woredaId': woredaId, 'source': source});
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).cast<Map<String, dynamic>>();
  }
}

final droughtRepositoryProvider = Provider<DroughtRepository>((ref) {
  return DroughtRepository(ref.watch(dioClientProvider));
});
