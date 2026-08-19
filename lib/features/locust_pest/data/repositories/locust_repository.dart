/// Locust pest repository
library locust_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/locust_alert_model.dart';

class LocustRepository {
  final DioClient _dio;
  LocustRepository(this._dio);

  Future<LocustAlertModel> getLocustRisk(String woredaId) async {
    final r = await _dio.get(ApiEndpoints.riskByWoreda(woredaId));
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    final data = raw is List ? (raw.isNotEmpty ? raw.first : <String, dynamic>{}) : raw;
    return LocustAlertModel.fromJson(data as Map<String, dynamic>);
  }
}

final locustRepositoryProvider = Provider<LocustRepository>((ref) {
  return LocustRepository(ref.watch(dioClientProvider));
});
