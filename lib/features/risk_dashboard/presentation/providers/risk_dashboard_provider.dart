/// Risk dashboard state management
library risk_dashboard_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/risk_assessment_model.dart';
import '../../data/repositories/risk_dashboard_repository.dart';

class RiskDashboardState {
  final List<RiskAssessmentModel> risks;
  final bool isLoading;
  final String? error;
  final String? currentWoredaId;

  const RiskDashboardState({this.risks = const [], this.isLoading = false, this.error, this.currentWoredaId});

  RiskDashboardState copyWith({List<RiskAssessmentModel>? risks, bool? isLoading, String? error, String? currentWoredaId}) =>
      RiskDashboardState(risks: risks ?? this.risks, isLoading: isLoading ?? this.isLoading, error: error, currentWoredaId: currentWoredaId ?? this.currentWoredaId);
}

class RiskDashboardNotifier extends StateNotifier<RiskDashboardState> {
  final RiskDashboardRepository _repo;
  RiskDashboardNotifier(this._repo) : super(const RiskDashboardState());

  Future<void> loadRisks(String woredaId) async {
    state = state.copyWith(isLoading: true, error: null, currentWoredaId: woredaId);
    try {
      final risks = await _repo.getWoredaRisks(woredaId);
      state = state.copyWith(risks: risks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> triggerEvaluation(String woredaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.evaluateRisk(woredaId);
      await loadRisks(woredaId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final riskDashboardProvider = StateNotifierProvider<RiskDashboardNotifier, RiskDashboardState>((ref) {
  return RiskDashboardNotifier(ref.watch(riskDashboardRepositoryProvider));
});
