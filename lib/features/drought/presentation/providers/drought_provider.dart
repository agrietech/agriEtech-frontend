/// Drought risk state management
library drought_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/drought_risk_model.dart';
import '../../data/repositories/drought_repository.dart';

class DroughtState {
  final DroughtRiskModel? risk;
  final List<Map<String, dynamic>> series;
  final bool isLoading;
  final String? error;

  const DroughtState({this.risk, this.series = const [], this.isLoading = false, this.error});
  DroughtState copyWith({DroughtRiskModel? risk, List<Map<String, dynamic>>? series, bool? isLoading, String? error}) =>
      DroughtState(risk: risk ?? this.risk, series: series ?? this.series, isLoading: isLoading ?? this.isLoading, error: error);
}

class DroughtNotifier extends StateNotifier<DroughtState> {
  final DroughtRepository _repo;
  DroughtNotifier(this._repo) : super(const DroughtState());

  Future<void> load(String woredaId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final risk = await _repo.getWoredaDroughtRisk(woredaId);
      final series = await _repo.getWoredaSatelliteObs(woredaId);
      state = state.copyWith(risk: risk, series: series, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final droughtProvider = StateNotifierProvider<DroughtNotifier, DroughtState>((ref) {
  return DroughtNotifier(ref.watch(droughtRepositoryProvider));
});
