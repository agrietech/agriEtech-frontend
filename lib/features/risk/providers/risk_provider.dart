import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';
import '../models/risk_models.dart';
import '../repositories/risk_repository.dart';

/// Risk assessments state
class RiskAssessmentsState {
  final List<RiskAssessment> assessments;
  final bool isLoading;
  final bool isRefreshing;
  final AppError? error;
  final DateTime? lastUpdated;
  final String? currentWoredaId;

  RiskAssessmentsState({
    this.assessments = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
    this.currentWoredaId,
  });

  RiskAssessmentsState copyWith({
    List<RiskAssessment>? assessments,
    bool? isLoading,
    bool? isRefreshing,
    AppError? error,
    bool clearError = false,
    DateTime? lastUpdated,
    String? currentWoredaId,
  }) {
    return RiskAssessmentsState(
      assessments: assessments ?? this.assessments,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentWoredaId: currentWoredaId ?? this.currentWoredaId,
    );
  }

  bool get hasAssessments => assessments.isNotEmpty;
  bool get hasError => error != null;

  List<RiskAssessment> getByHazardType(String hazardType) {
    return assessments
        .where((a) => a.hazardType == hazardType)
        .toList();
  }

  List<RiskAssessment> getByRiskLevel(String riskLevel) {
    return assessments
        .where((a) => a.riskLevel == riskLevel)
        .toList();
  }

  Map<String, int> get hazardCounts {
    final counts = <String, int>{};
    for (final assessment in assessments) {
      counts[assessment.hazardType] = (counts[assessment.hazardType] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get riskLevelCounts {
    final counts = <String, int>{};
    for (final assessment in assessments) {
      counts[assessment.riskLevel] = (counts[assessment.riskLevel] ?? 0) + 1;
    }
    return counts;
  }
}

/// Risk assessments notifier
class RiskAssessmentsNotifier extends StateNotifier<RiskAssessmentsState> {
  final RiskRepository _repository;

  RiskAssessmentsNotifier(this._repository) : super(RiskAssessmentsState());

  /// Load risk assessments with optional filters
  Future<void> loadAssessments({
    String? woredaId,
    String? hazardType,
    String? riskLevel,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Loading risk assessments');
      
      final assessments = await _repository.getRiskAssessments(
        woredaId: woredaId,
        hazardType: hazardType,
        riskLevel: riskLevel,
      );
      
      state = state.copyWith(
        assessments: assessments,
        isLoading: false,
        lastUpdated: DateTime.now(),
        currentWoredaId: woredaId,
      );
      
      AppLogger.info('Risk assessments loaded: ${assessments.length} assessments');
    } on AppError catch (e) {
      AppLogger.error('Risk assessments load failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected risk assessments load error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to load risk assessments',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  /// Load woreda-specific risk assessments
  Future<void> loadWoredaAssessments(String woredaId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Loading woreda risk assessments');
      
      final assessments = await _repository.getWoredaRiskAssessments(woredaId);
      
      state = state.copyWith(
        assessments: assessments,
        isLoading: false,
        lastUpdated: DateTime.now(),
        currentWoredaId: woredaId,
      );
      
      AppLogger.info('Woreda risk assessments loaded');
    } on AppError catch (e) {
      AppLogger.error('Woreda risk assessments load failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected woreda risk load error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to load woreda risk data',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  /// Refresh risk assessments
  Future<void> refreshAssessments() async {
    if (state.isLoading || state.isRefreshing) return;
    
    state = state.copyWith(isRefreshing: true, clearError: true);
    
    try {
      AppLogger.info('Refreshing risk assessments');
      
      final assessments = state.currentWoredaId != null
          ? await _repository.getWoredaRiskAssessments(state.currentWoredaId!)
          : await _repository.getRiskAssessments();
      
      state = state.copyWith(
        assessments: assessments,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Risk assessments refreshed');
    } on AppError catch (e) {
      AppLogger.error('Risk assessments refresh failed', e);
      
      state = state.copyWith(
        isRefreshing: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected refresh error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to refresh risk data',
        details: e,
      );
      
      state = state.copyWith(
        isRefreshing: false,
        error: error,
      );
    }
  }

  /// Trigger risk evaluation
  Future<void> evaluateRisk({String? woredaId, String? hazardType}) async {
    try {
      AppLogger.info('Triggering risk evaluation');
      
      final request = EvaluateRiskRequest(
        woredaId: woredaId,
        hazardType: hazardType,
      );
      
      await _repository.evaluateRisk(request);
      
      AppLogger.info('Risk evaluation triggered');
      
      // Refresh assessments after evaluation
      await refreshAssessments();
    } on AppError catch (e) {
      AppLogger.error('Risk evaluation failed', e);
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Risk assessments provider
final riskAssessmentsProvider = 
    StateNotifierProvider<RiskAssessmentsNotifier, RiskAssessmentsState>((ref) {
  final repository = ref.watch(riskRepositoryProvider);
  return RiskAssessmentsNotifier(repository);
});

/// Risk statistics provider
final riskStatisticsProvider = FutureProvider.family<RiskStatistics, String>(
  (ref, period) async {
    final repository = ref.watch(riskRepositoryProvider);
    return await repository.getRiskStatistics(period);
  },
);

/// Risk trends provider
final riskTrendsProvider = FutureProvider.family<List<RiskTrendPoint>, RiskTrendsParams>(
  (ref, params) async {
    final repository = ref.watch(riskRepositoryProvider);
    return await repository.getRiskTrends(
      hazardType: params.hazardType,
      woredaId: params.woredaId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

/// Risk trends parameters
class RiskTrendsParams {
  final String? hazardType;
  final String? woredaId;
  final DateTime? startDate;
  final DateTime? endDate;

  RiskTrendsParams({
    this.hazardType,
    this.woredaId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskTrendsParams &&
          runtimeType == other.runtimeType &&
          hazardType == other.hazardType &&
          woredaId == other.woredaId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      hazardType.hashCode ^
      woredaId.hashCode ^
      startDate.hashCode ^
      endDate.hashCode;
}
