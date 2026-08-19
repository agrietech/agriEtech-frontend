import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../models/alert_model.dart';
import '../network/dio_client.dart';

class AlertRepository {
  final DioClient _dioClient;

  AlertRepository(this._dioClient);

  /// Get user's alerts
  Future<List<AlertModel>> getAlerts({
    String? severity,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (severity != null) queryParams['severity'] = severity;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dioClient.get(
        ApiConstants.alerts,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      return data.map((json) => AlertModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get alert by ID
  Future<AlertModel> getAlertById(String id) async {
    try {
      final response = await _dioClient.get('${ApiConstants.alerts}/$id');
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      return AlertModel.fromJson(rawData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark alert as read
  Future<void> markAsRead(String id) async {
    try {
      await _dioClient.put('${ApiConstants.alerts}/$id/read');
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

/// Provider for AlertRepository
final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AlertRepository(dioClient);
});
