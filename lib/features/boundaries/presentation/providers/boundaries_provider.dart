/// Boundaries state management
library boundaries_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/region_model.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/woreda_model.dart';
import '../../data/repositories/boundaries_repository.dart';

class BoundariesState {
  final List<RegionModel> regions;
  final List<ZoneModel> zones;
  final List<WoredaModel> woredas;
  final bool isLoading;
  final String? error;

  const BoundariesState({this.regions = const [], this.zones = const [], this.woredas = const [], this.isLoading = false, this.error});

  BoundariesState copyWith({List<RegionModel>? regions, List<ZoneModel>? zones, List<WoredaModel>? woredas, bool? isLoading, String? error}) =>
      BoundariesState(regions: regions ?? this.regions, zones: zones ?? this.zones, woredas: woredas ?? this.woredas, isLoading: isLoading ?? this.isLoading, error: error);
}

class BoundariesNotifier extends StateNotifier<BoundariesState> {
  final BoundariesRepository _repo;
  BoundariesNotifier(this._repo) : super(const BoundariesState());

  Future<void> loadRegions() async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(regions: await _repo.getRegions(), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> loadZones(String regionId) async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(zones: await _repo.getZones(regionId: regionId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }

  Future<void> loadWoredas(String zoneId) async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(woredas: await _repo.getWoredas(zoneId: zoneId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }
}

final boundariesProvider = StateNotifierProvider<BoundariesNotifier, BoundariesState>((ref) {
  return BoundariesNotifier(ref.watch(boundariesRepositoryProvider));
});
