import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/models/analytics_model.dart' hide TrendDataPoint;
import '../../../core/utils/logger.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

/// Dashboard state
class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final bool isRefreshing;
  final AppError? error;
  final DateTime? lastUpdated;

  DashboardState({
    this.data,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    bool? isRefreshing,
    AppError? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasData => data != null;
  bool get hasError => error != null;
}

/// Dashboard state notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(DashboardState()) {
    loadDashboard();
  }

  /// Load dashboard data
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Loading dashboard');
      
      final data = await _repository.getDashboardData();
      
      state = state.copyWith(
        data: data,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Dashboard loaded successfully');
    } on AppError catch (e) {
      AppLogger.error('Dashboard load failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected dashboard load error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to load dashboard',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    if (state.isLoading || state.isRefreshing) return;
    
    state = state.copyWith(isRefreshing: true, clearError: true);
    
    try {
      AppLogger.info('Refreshing dashboard');
      
      final data = await _repository.getDashboardData();
      
      state = state.copyWith(
        data: data,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Dashboard refreshed successfully');
    } on AppError catch (e) {
      AppLogger.error('Dashboard refresh failed', e);
      
      state = state.copyWith(
        isRefreshing: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected dashboard refresh error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to refresh dashboard',
        details: e,
      );
      
      state = state.copyWith(
        isRefreshing: false,
        error: error,
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Dashboard provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

/// Regional breakdown provider
final regionalBreakdownProvider = FutureProvider<List<RegionalBreakdown>>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getRegionalBreakdown();
});

/// Temporal trends provider
final temporalTrendsProvider = FutureProvider.family<List<TrendDataPoint>, TemporalTrendsParams>(
  (ref, params) async {
    final repository = ref.watch(dashboardRepositoryProvider);
    return await repository.getTemporalTrends(
      hazardType: params.hazardType,
      startDate: params.startDate,
      endDate: params.endDate,
      woredaId: params.woredaId,
    );
  },
);

/// Agronomic advisories provider
final agronomicAdvisoriesProvider = FutureProvider.family<List<AgronomicAdvisory>, AdvisoryParams>(
  (ref, params) async {
    final repository = ref.watch(dashboardRepositoryProvider);
    return await repository.getAgronomicAdvisories(
      category: params.category,
      cropType: params.cropType,
      hazardType: params.hazardType,
      limit: params.limit,
    );
  },
);

/// Risk statistics provider
final riskStatisticsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, period) async {
    final repository = ref.watch(dashboardRepositoryProvider);
    return await repository.getRiskStatistics(period);
  },
);

/// Parameters for temporal trends query
class TemporalTrendsParams {
  final String? hazardType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? woredaId;

  TemporalTrendsParams({
    this.hazardType,
    this.startDate,
    this.endDate,
    this.woredaId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemporalTrendsParams &&
          runtimeType == other.runtimeType &&
          hazardType == other.hazardType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          woredaId == other.woredaId;

  @override
  int get hashCode =>
      hazardType.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      woredaId.hashCode;
}

/// Parameters for agronomic advisories query
class AdvisoryParams {
  final String? category;
  final String? cropType;
  final String? hazardType;
  final int? limit;

  AdvisoryParams({
    this.category,
    this.cropType,
    this.hazardType,
    this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisoryParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          cropType == other.cropType &&
          hazardType == other.hazardType &&
          limit == other.limit;

  @override
  int get hashCode =>
      category.hashCode ^
      cropType.hashCode ^
      hazardType.hashCode ^
      limit.hashCode;
}

/// Provider for dashboard analytics
final dashboardAnalyticsProvider = FutureProvider<DashboardAnalyticsModel>((ref) async {
  return DashboardAnalyticsModel(
    riskOverview: const RiskOverviewModel(
      lowRisk: 12,
      moderateRisk: 8,
      highRisk: 4,
      criticalRisk: 1,
      total: 25,
      avgScore: 2.1,
      dominantHazard: 'DROUGHT',
    ),
    regionalBreakdown: const [
      RegionalRiskModel(
        regionId: '1',
        regionName: 'Oromia',
        totalWoredas: 10,
        lowRisk: 5,
        moderateRisk: 3,
        highRisk: 2,
        criticalRisk: 0,
        avgRiskScore: 1.8,
      ),
      RegionalRiskModel(
        regionId: '2',
        regionName: 'Amhara',
        totalWoredas: 8,
        lowRisk: 4,
        moderateRisk: 2,
        highRisk: 1,
        criticalRisk: 1,
        avgRiskScore: 2.4,
      ),
    ],
    weatherSummary: const WeatherSummaryModel(
      avgTemperature: 22.0,
      minTemperature: 15.0,
      maxTemperature: 28.0,
      totalRainfall: 15.5,
      avgHumidity: 60.0,
      avgWindSpeed: 10.0,
      weatherCondition: 'Partly Cloudy',
    ),
    recentAlerts: const [],
    cropCalendar: CropCalendarModel(
      currentSeason: 'Meher',
      cropStage: 'Vegetative',
      recommendedActivities: const ['Weeding', 'Fertilizer application'],
      seasonStart: DateTime(2026, 6, 1),
      seasonEnd: DateTime(2026, 11, 30),
      daysRemaining: 75,
    ),
  );
});

/// Provider for temporal trends in professional dashboard
final dashboardTrendsProvider = FutureProvider.family<DashboardTrendsModel, String>((ref, period) async {
  final now = DateTime.now();
  return DashboardTrendsModel(
    riskTrend: List.generate(30, (i) => TrendValue(date: now.subtract(Duration(days: 29 - i)), value: 1.5 + (i % 5) * 0.4)),
    rainfallTrend: List.generate(30, (i) => TrendValue(date: now.subtract(Duration(days: 29 - i)), value: (i % 7 == 0) ? 15.0 : (i % 3) * 3.5)),
    temperatureTrend: List.generate(30, (i) => TrendValue(date: now.subtract(Duration(days: 29 - i)), value: 22.0 + (i % 6))),
    ndviTrend: List.generate(30, (i) => TrendValue(date: now.subtract(Duration(days: 29 - i)), value: 0.45 + (i % 4) * 0.08)),
  );
});
