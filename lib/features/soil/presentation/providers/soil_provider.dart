/// Soil profile state management
library soil_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/soil_profile_model.dart';
import '../../data/repositories/soil_repository.dart';

class SoilState {
  final List<SoilProfileModel> profiles;
  final bool isLoading;
  final String? error;

  const SoilState({this.profiles = const [], this.isLoading = false, this.error});
  SoilState copyWith({List<SoilProfileModel>? profiles, bool? isLoading, String? error}) =>
      SoilState(profiles: profiles ?? this.profiles, isLoading: isLoading ?? this.isLoading, error: error);
}

class SoilNotifier extends StateNotifier<SoilState> {
  final SoilRepository _repo;
  SoilNotifier(this._repo) : super(const SoilState());

  Future<void> load(String farmId) async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(profiles: await _repo.getFarmSoilProfile(farmId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }
}

final soilProvider = StateNotifierProvider<SoilNotifier, SoilState>((ref) {
  return SoilNotifier(ref.watch(soilRepositoryProvider));
});
