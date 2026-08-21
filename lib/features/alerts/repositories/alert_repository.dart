import 'package:dio/dio.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/alert_models.dart';

class AlertRepository {
  final DioClient _dioClient;

  AlertRepository(this._dioClient);

  /// Create a new alert (Officers/Agents/Admin only)
  Future<AlertModel> createAlert(CreateAlertRequest request) async {
    try {
      AppLogger.info('Creating alert', {
        'hazardType': request.hazardType,
        'severity': request.severity,
        'woredaId': request.woredaId,
      });

      final response = await _dioClient.post(
        '/alerts',
        data: request.toJson(),
      );

      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      final map = Map<String, dynamic>.from(raw);
      map['title'] = map['title'] ?? map['titleEn'] ?? map['titleAm'] ?? 'Alert';
      map['message'] = map['message'] ?? map['messageEn'] ?? map['messageAm'] ?? '';
      map['createdAt'] = map['createdAt'] ?? map['sentAt'] ?? DateTime.now().toIso8601String();
      map['updatedAt'] = map['updatedAt'] ?? map['createdAt'];
      map['woredaId'] = map['woredaId'] ?? '';
      map['hazardType'] = map['hazardType'] ?? 'GENERAL';
      map['severity'] = map['severity'] ?? 'LOW';
      final alert = AlertModel.fromJson(map);
      AppLogger.success('Alert created successfully', {'alertId': alert.id});
      return alert;
    } on DioException catch (e) {
      AppLogger.error('Failed to create alert', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error creating alert', e);
      throw const UnknownError(
        message: 'Failed to create alert',
      );
    }
  }

  /// Get alerts with optional filters
  Future<List<AlertModel>> getAlerts({
    String? woredaId,
    String? severity,
    String? hazardType,
  }) async {
    try {
      AppLogger.info('Fetching alerts', {
        'woredaId': woredaId,
        'severity': severity,
        'hazardType': hazardType,
      });

      final queryParams = <String, dynamic>{};
      if (woredaId != null) queryParams['woredaId'] = woredaId;
      if (severity != null) queryParams['severity'] = severity;
      if (hazardType != null) queryParams['hazardType'] = hazardType;

      final response = await _dioClient.get(
        '/alerts',
        queryParameters: queryParams,
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final alertsList = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['title'] = map['title'] ?? map['titleEn'] ?? map['titleAm'] ?? 'Alert';
        map['message'] = map['message'] ?? map['messageEn'] ?? map['messageAm'] ?? '';
        map['createdAt'] = map['createdAt'] ?? map['sentAt'] ?? DateTime.now().toIso8601String();
        map['updatedAt'] = map['updatedAt'] ?? map['createdAt'];
        map['woredaId'] = map['woredaId'] ?? '';
        map['hazardType'] = map['hazardType'] ?? 'GENERAL';
        map['severity'] = map['severity'] ?? 'LOW';
        return AlertModel.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${alertsList.length} alerts');
      return alertsList;
    } catch (e) {
      AppLogger.warning('Failed to fetch alerts from backend, returning empty list: $e');
      return [];
    }
  }

  /// Get active alerts only
  Future<List<AlertModel>> getActiveAlerts({
    String? woredaId,
    String? severity,
  }) async {
    final alerts = await getAlerts(
      woredaId: woredaId,
      severity: severity,
    );
    return alerts.where((alert) => alert.isActive).toList();
  }

  /// Get alerts by hazard type
  Future<List<AlertModel>> getAlertsByHazardType(String hazardType) async {
    return getAlerts(hazardType: hazardType);
  }

  /// Get critical alerts
  Future<List<AlertModel>> getCriticalAlerts({String? woredaId}) async {
    return getAlerts(woredaId: woredaId, severity: 'CRITICAL');
  }

  /// Calculate alert statistics
  AlertStatistics calculateStatistics(List<AlertModel> alerts) {
    int critical = 0;
    int high = 0;
    int moderate = 0;
    int low = 0;
    int active = 0;
    int expired = 0;

    final byHazardType = <String, int>{};
    final byWoreda = <String, int>{};

    for (final alert in alerts) {
      // Count by severity
      switch (alert.severity) {
        case 'CRITICAL':
          critical++;
          break;
        case 'HIGH':
          high++;
          break;
        case 'MODERATE':
          moderate++;
          break;
        case 'LOW':
          low++;
          break;
      }

      // Count active/expired
      if (alert.isActive) {
        active++;
        if (alert.validUntil != null) {
          final validUntil = DateTime.tryParse(alert.validUntil!);
          if (validUntil != null && validUntil.isBefore(DateTime.now())) {
            expired++;
            active--;
          }
        }
      } else {
        expired++;
      }

      // Count by hazard type
      byHazardType[alert.hazardType] =
          (byHazardType[alert.hazardType] ?? 0) + 1;

      // Count by woreda
      if (alert.woreda != null) {
        final woredaName = alert.woreda!.name;
        byWoreda[woredaName] = (byWoreda[woredaName] ?? 0) + 1;
      }
    }

    return AlertStatistics(
      total: alerts.length,
      critical: critical,
      high: high,
      moderate: moderate,
      low: low,
      active: active,
      expired: expired,
      byHazardType: byHazardType,
      byWoreda: byWoreda,
    );
  }
}
