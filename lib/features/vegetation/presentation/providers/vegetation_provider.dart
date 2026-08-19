/// Vegetation health state management
library vegetation_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ndvi_model.dart';
import '../../data/repositories/vegetation_repository.dart';

class VegetationState {
  final List<NdviModel> series;
  final bool isLoading;
  final String? error;

  const VegetationState({this.series = const [], this.isLoading = false, this.error});
  VegetationState copyWith({List<NdviModel>? series, bool? isLoading, String? error}) =>
      VegetationState(series: series ?? this.series, isLoading: isLoading ?? this.isLoading, error: error);
}

class VegetationNotifier extends StateNotifier<VegetationState> {
  final VegetationRepository _repo;
  VegetationNotifier(this._repo) : super(const VegetationState());

  Future<void> load(String woredaId) async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(series: await _repo.getNdviSeries(woredaId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }
}

final vegetationProvider = StateNotifierProvider<VegetationNotifier, VegetationState>((ref) {
  return VegetationNotifier(ref.watch(vegetationRepositoryProvider));
});
