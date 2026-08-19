import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

/// Dashboard summary data
@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required RiskSummary riskSummary,
    required List<RecentAlert> recentAlerts,
    required WeatherSummary weatherSummary,
    required FarmSummary farmSummary,
    required SystemHealth systemHealth,
    @JsonKey(name: 'updatedAt') DateTime? updatedAt,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

/// Risk summary statistics
@freezed
class RiskSummary with _$RiskSummary {
  const factory RiskSummary({
    @Default(0) int totalWoredas,
    @Default(0) int lowRisk,
    @Default(0) int moderateRisk,
    @Default(0) int highRisk,
    @Default(0) int criticalRisk,
    @Default(0) int affectedPopulation,
    Map<String, HazardSummary>? hazardBreakdown,
  }) = _RiskSummary;

  factory RiskSummary.fromJson(Map<String, dynamic> json) =>
      _$RiskSummaryFromJson(json);
}

/// Hazard-specific summary
@freezed
class HazardSummary with _$HazardSummary {
  const factory HazardSummary({
    required String hazardType,
    @Default(0) int affectedWoredas,
    @Default(0.0) double averageRisk,
    @Default(0) int activeAlerts,
  }) = _HazardSummary;

  factory HazardSummary.fromJson(Map<String, dynamic> json) =>
      _$HazardSummaryFromJson(json);
}

/// Recent alert preview
@freezed
class RecentAlert with _$RecentAlert {
  const factory RecentAlert({
    required String id,
    required String title,
    required String message,
    required String severity,
    required String hazardType,
    String? woredaName,
    String? zoneName,
    String? regionName,
    @Default(false) bool isRead,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _RecentAlert;

  factory RecentAlert.fromJson(Map<String, dynamic> json) =>
      _$RecentAlertFromJson(json);
}

/// Weather summary
@freezed
class WeatherSummary with _$WeatherSummary {
  const factory WeatherSummary({
    CurrentWeather? current,
    List<DailyForecast>? forecast,
    WeatherAlerts? alerts,
  }) = _WeatherSummary;

  factory WeatherSummary.fromJson(Map<String, dynamic> json) =>
      _$WeatherSummaryFromJson(json);
}

/// Current weather conditions
@freezed
class CurrentWeather with _$CurrentWeather {
  const factory CurrentWeather({
    @Default(0.0) double temperature,
    @Default(0.0) double humidity,
    @Default(0.0) double rainfall,
    @Default(0.0) double windSpeed,
    String? condition,
    String? iconCode,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}

/// Daily weather forecast
@freezed
class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required DateTime date,
    @Default(0.0) double tempMax,
    @Default(0.0) double tempMin,
    @Default(0.0) double rainfall,
    @Default(0.0) double humidity,
    String? condition,
    String? iconCode,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
}

/// Weather alerts
@freezed
class WeatherAlerts with _$WeatherAlerts {
  const factory WeatherAlerts({
    @Default(false) bool hasAlerts,
    List<String>? warnings,
  }) = _WeatherAlerts;

  factory WeatherAlerts.fromJson(Map<String, dynamic> json) =>
      _$WeatherAlertsFromJson(json);
}

/// Farm summary statistics
@freezed
class FarmSummary with _$FarmSummary {
  const factory FarmSummary({
    @Default(0) int totalFarms,
    @Default(0.0) double totalArea,
    @Default(0) int farmsAtRisk,
    @Default(0) int activeSensors,
    Map<String, int>? cropDistribution,
  }) = _FarmSummary;

  factory FarmSummary.fromJson(Map<String, dynamic> json) =>
      _$FarmSummaryFromJson(json);
}

/// System health indicators
@freezed
class SystemHealth with _$SystemHealth {
  const factory SystemHealth({
    @Default('OPERATIONAL') String status,
    @Default(0) int activeUsers,
    @Default(0) int dataPointsToday,
    DateTime? lastDataUpdate,
    @Default(true) bool apiHealthy,
  }) = _SystemHealth;

  factory SystemHealth.fromJson(Map<String, dynamic> json) =>
      _$SystemHealthFromJson(json);
}

/// Regional breakdown data
@freezed
class RegionalBreakdown with _$RegionalBreakdown {
  const factory RegionalBreakdown({
    required String regionId,
    required String regionName,
    @Default(0) int totalWoredas,
    @Default(0) int lowRisk,
    @Default(0) int moderateRisk,
    @Default(0) int highRisk,
    @Default(0) int criticalRisk,
    @Default(0) int affectedPopulation,
    Map<String, int>? hazardCounts,
  }) = _RegionalBreakdown;

  factory RegionalBreakdown.fromJson(Map<String, dynamic> json) =>
      _$RegionalBreakdownFromJson(json);
}

/// Temporal trend data point
@freezed
class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    required DateTime date,
    required String hazardType,
    @Default(0.0) double riskScore,
    @Default(0) int affectedWoredas,
  }) = _TrendDataPoint;

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointFromJson(json);
}

/// Agronomic advisory
@freezed
class AgronomicAdvisory with _$AgronomicAdvisory {
  const factory AgronomicAdvisory({
    required String id,
    required String title,
    required String content,
    required String category,
    List<String>? tags,
    String? cropType,
    String? hazardType,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _AgronomicAdvisory;

  factory AgronomicAdvisory.fromJson(Map<String, dynamic> json) =>
      _$AgronomicAdvisoryFromJson(json);
}

/// Simple trend value point with a date and numeric value
class TrendValue {
  final DateTime date;
  final double value;

  const TrendValue({required this.date, required this.value});
}

/// Comprehensive trends model for professional dashboard
class DashboardTrendsModel {
  final List<TrendValue> riskTrend;
  final List<TrendValue> rainfallTrend;
  final List<TrendValue> temperatureTrend;
  final List<TrendValue> ndviTrend;

  const DashboardTrendsModel({
    this.riskTrend = const [],
    this.rainfallTrend = const [],
    this.temperatureTrend = const [],
    this.ndviTrend = const [],
  });
}
