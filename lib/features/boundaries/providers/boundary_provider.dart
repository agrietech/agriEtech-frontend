import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
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
  return await repository.getRegions();
});

/// Zones provider (filtered by region)
final zonesByRegionProvider =
    FutureProvider.family<List<ZoneModel>, String?>((ref, regionId) async {
  if (regionId == null) return [];
  final repository = ref.watch(boundaryRepositoryProvider);
  return await repository.getZonesByRegion(regionId);
});

/// Woredas provider (filtered by zone)
final woredasByZoneProvider =
    FutureProvider.family<List<WoredaModel>, String?>((ref, zoneId) async {
  if (zoneId == null) return [];
  final repository = ref.watch(boundaryRepositoryProvider);
  return await repository.getWoredasByZone(zoneId);
});

/// All woredas provider
final allWoredasProvider = FutureProvider<List<WoredaModel>>((ref) async {
  final repository = ref.watch(boundaryRepositoryProvider);
  return await repository.getAllWoredas();
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
      : super(const BoundaryHierarchy()) {
    loadRegions();
  }

  /// Load all regions
  Future<void> loadRegions() async {
    try {
      final regions = await _repository.getRegions();
      state = state.copyWith(regions: regions);
    } catch (e) {
      // Error handled by UI
    }
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
        state = state.copyWith(zones: zones);
      } catch (e) {
        // Error handled by UI
      }
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
        state = state.copyWith(woredas: woredas);
      } catch (e) {
        // Error handled by UI
      }
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
