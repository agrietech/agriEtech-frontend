import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_error.dart';
import '../../../core/utils/logger.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/repositories/farm_repository.dart';

/// Farms state
class FarmsState {
  final List<FarmModel> farms;
  final bool isLoading;
  final bool isRefreshing;
  final AppError? error;
  final DateTime? lastUpdated;

  FarmsState({
    this.farms = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  FarmsState copyWith({
    List<FarmModel>? farms,
    bool? isLoading,
    bool? isRefreshing,
    AppError? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return FarmsState(
      farms: farms ?? this.farms,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasFarms => farms.isNotEmpty;
  bool get hasError => error != null;
}

/// Farms state notifier
class FarmsNotifier extends StateNotifier<FarmsState> {
  final FarmRepository _repository;

  FarmsNotifier(this._repository) : super(FarmsState()) {
    loadFarms();
  }

  /// Load all farms
  Future<void> loadFarms() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      AppLogger.info('Loading farms');
      
      final farms = await _repository.getFarms();
      
      state = state.copyWith(
        farms: farms,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Farms loaded successfully: ${farms.length} farms');
    } on AppError catch (e) {
      AppLogger.error('Farms load failed', e);
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farms load error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to load farms',
        details: e,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: error,
      );
    }
  }

  /// Refresh farms
  Future<void> refreshFarms() async {
    if (state.isLoading || state.isRefreshing) return;
    
    state = state.copyWith(isRefreshing: true, clearError: true);
    
    try {
      AppLogger.info('Refreshing farms');
      
      final farms = await _repository.getFarms();
      
      state = state.copyWith(
        farms: farms,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Farms refreshed successfully');
    } on AppError catch (e) {
      AppLogger.error('Farms refresh failed', e);
      
      state = state.copyWith(
        isRefreshing: false,
        error: e,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farms refresh error', e, stackTrace);
      
      final error = UnknownError(
        message: 'Failed to refresh farms',
        details: e,
      );
      
      state = state.copyWith(
        isRefreshing: false,
        error: error,
      );
    }
  }

  /// Create farm
  Future<FarmModel> createFarm(CreateFarmRequest request) async {
    try {
      AppLogger.info('Creating farm');
      
      final farm = await _repository.createFarm(request);
      
      // Add to local state
      state = state.copyWith(
        farms: [...state.farms, farm],
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Farm created successfully');
      
      return farm;
    } on AppError catch (e) {
      AppLogger.error('Farm creation failed', e);
      rethrow;
    }
  }

  /// Update farm
  Future<FarmModel> updateFarm(String farmId, UpdateFarmRequest request) async {
    try {
      AppLogger.info('Updating farm: $farmId');
      
      final updatedFarm = await _repository.updateFarm(farmId, request);
      
      // Update in local state
      final updatedFarms = state.farms.map((farm) {
        return farm.id == farmId ? updatedFarm : farm;
      }).toList();
      
      state = state.copyWith(
        farms: updatedFarms,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Farm updated successfully');
      
      return updatedFarm;
    } on AppError catch (e) {
      AppLogger.error('Farm update failed', e);
      rethrow;
    }
  }

  /// Delete farm
  Future<void> deleteFarm(String farmId) async {
    try {
      AppLogger.info('Deleting farm: $farmId');
      
      await _repository.deleteFarm(farmId);
      
      // Remove from local state
      final updatedFarms = state.farms.where((farm) => farm.id != farmId).toList();
      
      state = state.copyWith(
        farms: updatedFarms,
        lastUpdated: DateTime.now(),
      );
      
      AppLogger.info('Farm deleted successfully');
    } on AppError catch (e) {
      AppLogger.error('Farm deletion failed', e);
      rethrow;
    }
  }

  /// Get farm by ID from state
  FarmModel? getFarmById(String farmId) {
    try {
      return state.farms.firstWhere((farm) => farm.id == farmId);
    } catch (e) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Farms provider
final farmsProvider = StateNotifierProvider<FarmsNotifier, FarmsState>((ref) {
  final repository = ref.watch(farmRepositoryProvider);
  return FarmsNotifier(repository);
});

/// Individual farm provider
final farmProvider = FutureProvider.family<FarmModel, String>((ref, farmId) async {
  final repository = ref.watch(farmRepositoryProvider);
  return await repository.getFarmById(farmId);
});

/// Farms with risk provider
final farmsWithRiskProvider = FutureProvider<List<FarmModel>>((ref) async {
  final repository = ref.watch(farmRepositoryProvider);
  return await repository.getFarmsWithRisk();
});

/// Farm statistics provider
final farmStatisticsProvider = Provider<FarmStatistics>((ref) {
  final farmsState = ref.watch(farmsProvider);
  
  if (farmsState.farms.isEmpty) {
    return FarmStatistics(
      totalFarms: 0,
      totalArea: 0.0,
      farmsAtRisk: 0,
      cropDistribution: {},
    );
  }
  
  final totalArea = farmsState.farms.fold<double>(
    0.0,
    (sum, farm) => sum + farm.areaHectares,
  );
  
  final cropDistribution = <String, int>{};
  for (final farm in farmsState.farms) {
    cropDistribution[farm.primaryCrop] = 
        (cropDistribution[farm.primaryCrop] ?? 0) + 1;
  }
  
  return FarmStatistics(
    totalFarms: farmsState.farms.length,
    totalArea: totalArea,
    farmsAtRisk: 0, // Will be calculated with risk data
    cropDistribution: cropDistribution,
  );
});

/// Farm statistics model
class FarmStatistics {
  final int totalFarms;
  final double totalArea;
  final int farmsAtRisk;
  final Map<String, int> cropDistribution;

  FarmStatistics({
    required this.totalFarms,
    required this.totalArea,
    required this.farmsAtRisk,
    required this.cropDistribution,
  });
}
