/// Flood risk state management
library flood_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/flood_risk_model.dart';
import '../../data/repositories/flood_repository.dart';

class FloodState {
  final FloodRiskModel? risk;
  final bool isLoading;
  final String? error;

  const FloodState({this.risk, this.isLoading = false, this.error});
  FloodState copyWith({FloodRiskModel? risk, bool? isLoading, String? error}) =>
      FloodState(risk: risk ?? this.risk, isLoading: isLoading ?? this.isLoading, error: error);
}

class FloodNotifier extends StateNotifier<FloodState> {
  final FloodRepository _repo;
  FloodNotifier(this._repo) : super(const FloodState());

  Future<void> load(String woredaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try { state = state.copyWith(risk: await _repo.getFloodRisk(woredaId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }
}

final floodProvider = StateNotifierProvider<FloodNotifier, FloodState>((ref) {
  return FloodNotifier(ref.watch(floodRepositoryProvider));
});
