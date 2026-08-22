import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../data/ethiopia_boundaries_data.dart';
import '../models/boundary_models.dart';
import '../repositories/boundary_repository.dart';

/// Boundary repository provider
final boundaryRepositoryProvider = Provider<BoundaryRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BoundaryRepository(dioClient);
});

/// Regions provider
final regionsProvider = FutureProvider<List<RegionModel>>((ref) async {
  final repository = ref.watch(boundaryRepositoryProvider);
  try {
    final regions = await repository.getRegions();
    if (regions.isNotEmpty) return regions;
  } catch (_) {}
  return EthiopiaBoundariesData.defaultRegions;
});

/// Zones provider (filtered by region)
final zonesByRegionProvider =
    FutureProvider.family<List<ZoneModel>, String?>((ref, regionId) async {
  if (regionId == null) return [];
  final repository = ref.watch(boundaryRepositoryProvider);
  try {
    final zones = await repository.getZonesByRegion(regionId);
    if (zones.isNotEmpty) return zones;
  } catch (_) {}
  return EthiopiaBoundariesData.getFallbackZones(regionId);
});

/// Woredas provider (filtered by zone)
final woredasByZoneProvider =
    FutureProvider.family<List<WoredaModel>, String?>((ref, zoneId) async {
  if (zoneId == null) return [];
  final repository = ref.watch(boundaryRepositoryProvider);
  try {
    final woredas = await repository.getWoredasByZone(zoneId);
    if (woredas.isNotEmpty) return woredas;
  } catch (_) {}
  return EthiopiaBoundariesData.getFallbackWoredas(zoneId);
});

/// All woredas provider
final allWoredasProvider = FutureProvider<List<WoredaModel>>((ref) async {
  final repository = ref.watch(boundaryRepositoryProvider);
  try {
    final woredas = await repository.getAllWoredas();
    if (woredas.isNotEmpty) return woredas;
  } catch (_) {}
  final all = <WoredaModel>[];
  for (final list in EthiopiaBoundariesData.defaultWoredasByZone.values) {
    all.addAll(list);
  }
  return all;
});

/// Woreda details provider
final woredaDetailsProvider =
    FutureProvider.family<WoredaModel, String>((ref, woredaId) async {
  final repository = ref.watch(boundaryRepositoryProvider);
  return await repository.getWoredaById(woredaId);
});

/// Boundary hierarchy state notifier
class BoundaryHierarchyNotifier extends StateNotifier<BoundaryHierarchy> {
  final BoundaryRepository _repository;

  BoundaryHierarchyNotifier(this._repository)
      : super(BoundaryHierarchy(regions: EthiopiaBoundariesData.defaultRegions)) {
    loadRegions();
  }

  /// Load all regions
  Future<void> loadRegions() async {
    try {
      final regions = await _repository.getRegions();
      if (regions.isNotEmpty) {
        state = state.copyWith(regions: regions);
        return;
      }
    } catch (_) {}
    state = state.copyWith(regions: EthiopiaBoundariesData.defaultRegions);
  }

  /// Select region and load its zones
  Future<void> selectRegion(RegionModel? region) async {
    state = state.copyWith(
      selectedRegion: region,
      selectedZone: null,
      selectedWoreda: null,
      zones: [],
      woredas: [],
    );

    if (region != null) {
      try {
        final zones = await _repository.getZonesByRegion(region.id);
        if (zones.isNotEmpty) {
          state = state.copyWith(zones: zones);
          return;
        }
      } catch (_) {}
      final fallbackZones = EthiopiaBoundariesData.getFallbackZones(region.id);
      state = state.copyWith(zones: fallbackZones);
    }
  }

  /// Select zone and load its woredas
  Future<void> selectZone(ZoneModel? zone) async {
    state = state.copyWith(
      selectedZone: zone,
      selectedWoreda: null,
      woredas: [],
    );

    if (zone != null) {
      try {
        final woredas = await _repository.getWoredasByZone(zone.id);
        if (woredas.isNotEmpty) {
          state = state.copyWith(woredas: woredas);
          return;
        }
      } catch (_) {}
      final fallbackWoredas = EthiopiaBoundariesData.getFallbackWoredas(zone.id);
      state = state.copyWith(woredas: fallbackWoredas);
    }
  }

  /// Select woreda
  void selectWoreda(WoredaModel? woreda) {
    state = state.copyWith(selectedWoreda: woreda);
  }

  /// Reset selection
  void reset() {
    state = state.copyWith(
      selectedRegion: null,
      selectedZone: null,
      selectedWoreda: null,
      zones: [],
      woredas: [],
    );
  }

  /// Get current hierarchy as string
  String getHierarchyString() {
    final parts = <String>[];
    if (state.selectedRegion != null) {
      parts.add(state.selectedRegion!.name);
    }
    if (state.selectedZone != null) {
      parts.add(state.selectedZone!.name);
    }
    if (state.selectedWoreda != null) {
      parts.add(state.selectedWoreda!.name);
    }
    return parts.isEmpty ? 'Ethiopia' : parts.join(' > ');
  }
}

/// Boundary hierarchy provider
final boundaryHierarchyProvider =
    StateNotifierProvider<BoundaryHierarchyNotifier, BoundaryHierarchy>((ref) {
  final repository = ref.watch(boundaryRepositoryProvider);
  return BoundaryHierarchyNotifier(repository);
});

/// Boundary statistics provider
final boundaryStatisticsProvider = Provider<BoundaryStatistics>((ref) {
  final regionsAsync = ref.watch(regionsProvider);
  final hierarchy = ref.watch(boundaryHierarchyProvider);
  final repository = ref.watch(boundaryRepositoryProvider);

  return regionsAsync.when(
    data: (regions) => repository.calculateStatistics(
      regions,
      hierarchy.zones,
      hierarchy.woredas,
    ),
    loading: () => const BoundaryStatistics(),
    error: (_, __) => const BoundaryStatistics(),
  );
});
