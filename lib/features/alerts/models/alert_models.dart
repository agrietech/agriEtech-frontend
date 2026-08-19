import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_models.freezed.dart';
part 'alert_models.g.dart';

/// Alert model representing emergency warnings
@freezed
class AlertModel with _$AlertModel {
  const factory AlertModel({
    required String id,
    required String woredaId,
    required String hazardType,
    required String severity,
    required String title,
    required String message,
    @Default([]) List<String> actionItems,
    @Default(1) int priority,
    String? validUntil,
    @Default(true) bool isActive,
    @Default([]) List<AlertDeliveryLog> deliveryLogs,
    required String createdAt,
    required String updatedAt,
    // Nested woreda details
    WoredaBasicInfo? woreda,
  }) = _AlertModel;

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
}

/// Basic woreda information for alerts
@freezed
class WoredaBasicInfo with _$WoredaBasicInfo {
  const factory WoredaBasicInfo({
    required String id,
    required String name,
  }) = _WoredaBasicInfo;

  factory WoredaBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$WoredaBasicInfoFromJson(json);
}

/// Alert delivery log tracking
@freezed
class AlertDeliveryLog with _$AlertDeliveryLog {
  const factory AlertDeliveryLog({
    required String id,
    required String alertId,
    required String userId,
    required String channel,
    required String status,
    String? errorMessage,
    Map<String, dynamic>? responsePayload,
    @Default(0) int retryCount,
    String? sentAt,
    String? deliveredAt,
    required String createdAt,
    required String updatedAt,
  }) = _AlertDeliveryLog;

  factory AlertDeliveryLog.fromJson(Map<String, dynamic> json) =>
      _$AlertDeliveryLogFromJson(json);
}

/// Request model for creating alerts
@freezed
class CreateAlertRequest with _$CreateAlertRequest {
  const factory CreateAlertRequest({
    String? woredaId,
    String? woredaName,
    @Default('DROUGHT') String hazardType,
    @Default('HIGH') String severity,
    String? titleEn,
    String? titleAm,
    String? messageEn,
    String? messageAm,
    String? headline,
    String? message,
    @Default([]) List<String> targetPhones,
    @Default([]) List<String> actionItems,
    @Default(1) int priority,
    @Default('en') String language,
  }) = _CreateAlertRequest;

  factory CreateAlertRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAlertRequestFromJson(json);
}

/// Alert statistics model
@freezed
class AlertStatistics with _$AlertStatistics {
  const factory AlertStatistics({
    @Default(0) int total,
    @Default(0) int critical,
    @Default(0) int high,
    @Default(0) int moderate,
    @Default(0) int low,
    @Default(0) int active,
    @Default(0) int expired,
    Map<String, int>? byHazardType,
    Map<String, int>? byWoreda,
  }) = _AlertStatistics;

  factory AlertStatistics.fromJson(Map<String, dynamic> json) =>
      _$AlertStatisticsFromJson(json);
}

/// Alert filter options
@freezed
class AlertFilters with _$AlertFilters {
  const factory AlertFilters({
    String? woredaId,
    String? severity,
    String? hazardType,
    bool? isActive,
    int? limit,
  }) = _AlertFilters;

  factory AlertFilters.fromJson(Map<String, dynamic> json) =>
      _$AlertFiltersFromJson(json);
}
