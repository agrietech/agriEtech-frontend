import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../analytics/models/analytics_model.dart' hide TrendDataPoint;
import '../../../core/utils/logger.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';
import '../../analytics/repositories/analytics_repository.dart';

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

/// Provider for dashboard analytics from live backend API
final dashboardAnalyticsProvider = FutureProvider<DashboardAnalyticsModel>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return await repo.getDashboardAnalytics();
});

/// Provider for temporal trends in professional dashboard from live backend API
final dashboardTrendsProvider = FutureProvider.family<DashboardTrendsModel, String>((ref, period) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final trendModel = await repo.getTemporalTrends(period);
  return DashboardTrendsModel(
    riskTrend: trendModel.riskTrend.map((s) => TrendValue(
      date: DateTime.tryParse(s.date) ?? DateTime.now(),
      value: s.value,
    )).toList(),
    rainfallTrend: trendModel.rainfallTrend.map((s) => TrendValue(
      date: DateTime.tryParse(s.date) ?? DateTime.now(),
      value: s.value,
    )).toList(),
    temperatureTrend: trendModel.temperatureTrend.map((s) => TrendValue(
      date: DateTime.tryParse(s.date) ?? DateTime.now(),
      value: s.value,
    )).toList(),
    ndviTrend: trendModel.ndviTrend.map((s) => TrendValue(
      date: DateTime.tryParse(s.date) ?? DateTime.now(),
      value: s.value,
    )).toList(),
  );
});
