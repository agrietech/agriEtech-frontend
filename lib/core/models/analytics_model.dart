import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_model.freezed.dart';
part 'analytics_model.g.dart';

@freezed
class DashboardAnalyticsModel with _$DashboardAnalyticsModel {
  const factory DashboardAnalyticsModel({
    required RiskOverviewModel riskOverview,
    required List<RegionalRiskModel> regionalBreakdown,
    required WeatherSummaryModel weatherSummary,
    required List<AlertSummaryModel> recentAlerts,
    required CropCalendarModel cropCalendar,
    int? totalFarms,
    int? totalWoredas,
    double? averageRiskScore,
  }) = _DashboardAnalyticsModel;

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardAnalyticsModelFromJson(json);
}

@freezed
class RiskOverviewModel with _$RiskOverviewModel {
  const factory RiskOverviewModel({
    required int lowRisk,
    required int moderateRisk,
    required int highRisk,
    required int criticalRisk,
    required int total,
    required double avgScore,
    String? dominantHazard,
    Map<String, int>? hazardBreakdown,
  }) = _RiskOverviewModel;

  factory RiskOverviewModel.fromJson(Map<String, dynamic> json) =>
      _$RiskOverviewModelFromJson(json);
}

@freezed
class RegionalRiskModel with _$RegionalRiskModel {
  const factory RegionalRiskModel({
    required String regionId,
    required String regionName,
    required int totalWoredas,
    required int lowRisk,
    required int moderateRisk,
    required int highRisk,
    required int criticalRisk,
    required double avgRiskScore,
    String? dominantHazard,
  }) = _RegionalRiskModel;

  factory RegionalRiskModel.fromJson(Map<String, dynamic> json) =>
      _$RegionalRiskModelFromJson(json);
}

@freezed
class WeatherSummaryModel with _$WeatherSummaryModel {
  const factory WeatherSummaryModel({
    required double avgTemperature,
    required double minTemperature,
    required double maxTemperature,
    required double totalRainfall,
    required double avgHumidity,
    required double avgWindSpeed,
    String? weatherCondition,
    List<DailyForecastModel>? forecast,
  }) = _WeatherSummaryModel;

  factory WeatherSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherSummaryModelFromJson(json);
}

@freezed
class DailyForecastModel with _$DailyForecastModel {
  const factory DailyForecastModel({
    required String date,
    required double tempMax,
    required double tempMin,
    required double precipitation,
    required double humidity,
    String? condition,
  }) = _DailyForecastModel;

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastModelFromJson(json);
}

@freezed
class AlertSummaryModel with _$AlertSummaryModel {
  const factory AlertSummaryModel({
    required String severity,
    required String hazardType,
    required int count,
    required int affected,
  }) = _AlertSummaryModel;

  factory AlertSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$AlertSummaryModelFromJson(json);
}

@freezed
class CropCalendarModel with _$CropCalendarModel {
  const factory CropCalendarModel({
    required String currentSeason,
    required String cropStage,
    required List<String> recommendedActivities,
    required DateTime seasonStart,
    required DateTime seasonEnd,
    int? daysRemaining,
  }) = _CropCalendarModel;

  factory CropCalendarModel.fromJson(Map<String, dynamic> json) =>
      _$CropCalendarModelFromJson(json);
}

@freezed
class TemporalTrendModel with _$TemporalTrendModel {
  const factory TemporalTrendModel({
    required String period,
    required List<TrendDataPoint> riskTrend,
    required List<TrendDataPoint> rainfallTrend,
    required List<TrendDataPoint> temperatureTrend,
    required List<TrendDataPoint> ndviTrend,
  }) = _TemporalTrendModel;

  factory TemporalTrendModel.fromJson(Map<String, dynamic> json) =>
      _$TemporalTrendModelFromJson(json);
}

@freezed
class TrendDataPoint with _$TrendDataPoint {
  const factory TrendDataPoint({
    required String date,
    required double value,
    String? label,
  }) = _TrendDataPoint;

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointFromJson(json);
}
