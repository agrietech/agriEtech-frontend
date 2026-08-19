/// Alerts repository — fetches from /api/v1/alerts
library alerts_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/alert_model.dart';

class AlertsRepository {
  final DioClient _dio;
  AlertsRepository(this._dio);

  Future<List<AlertModel>> getAlerts({String? severity, String? hazardType, int page = 1}) async {
    final params = <String, dynamic>{'page': page, 'limit': 20};
    if (severity != null) params['severity'] = severity;
    if (hazardType != null) params['hazardType'] = hazardType;

    final response = await _dio.get(ApiEndpoints.alerts, queryParameters: params);
    final raw = response.data is Map && response.data['data'] != null
        ? response.data['data'] : response.data;
    final list = raw is List ? raw : (raw is Map ? (raw['alerts'] ?? []) : []);
    return (list as List).map((j) => AlertModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<AlertModel> createAlert(Map<String, dynamic> payload) async {
    final response = await _dio.post(ApiEndpoints.alerts, data: payload);
    final raw = response.data is Map && response.data['data'] != null
        ? response.data['data'] as Map<String, dynamic>
        : response.data as Map<String, dynamic>;
    return AlertModel.fromJson(raw);
  }
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(dioClientProvider));
});
