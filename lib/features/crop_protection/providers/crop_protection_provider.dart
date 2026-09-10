import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/crop_protection_models.dart';

/// Repository for Crop Protection & Precision Management API calls
class CropProtectionRepository {
  final DioClient _dioClient;

  CropProtectionRepository(this._dioClient);

  /// 1. Weed Registry & Detection
  Future<List<WeedModel>> fetchWeedDatabase({String? cropType, String? weedType}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.weedDatabase,
        queryParameters: {
          if (cropType != null && cropType.isNotEmpty) 'cropType': cropType,
          if (weedType != null && weedType.isNotEmpty) 'weedType': weedType,
        },
      );
      final list = (response.data?['data']?['weeds'] as List<dynamic>?) ?? [];
      return list.map((e) => WeedModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch weed database: $e');
      rethrow;
    }
  }

  Future<WeedDetectionResult> detectWeed({
    String? imagePath,
    String? imageBase64,
    required String cropType,
    required double areaHectares,
    String language = 'en',
  }) async {
    try {
      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        response = await _dioClient.uploadFile(
          ApiConstants.weedDetect,
          imagePath,
          fieldName: 'image',
          data: {
            'cropType': cropType,
            'areaHectares': areaHectares.toString(),
            'language': language,
          },
        );
      } else {
        response = await _dioClient.post(
          ApiConstants.weedDetect,
          data: {
            if (imageBase64 != null) 'imageBase64': imageBase64,
            'cropType': cropType,
            'areaHectares': areaHectares,
            'language': language,
          },
        );
      }
      return WeedDetectionResult.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to detect weed: $e');
      rethrow;
    }
  }

  /// 2. Spray Window Weather Advisory
  Future<SprayWindowData> fetchSprayWindow({double? lat, double? lng, String? farmId}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.sprayWindow,
        queryParameters: {
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
          if (farmId != null) 'farmId': farmId,
        },
      );
      return SprayWindowData.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to fetch spray window advisory: $e');
      rethrow;
    }
  }

  /// 3. Nutrient Deficiency Diagnostics
  Future<List<NutrientDeficiencyModel>> fetchNutrientDatabase() async {
    try {
      final response = await _dioClient.get(ApiConstants.nutrientDatabase);
      final list = (response.data?['data']?['deficiencies'] as List<dynamic>?) ?? [];
      return list.map((e) => NutrientDeficiencyModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch nutrient database: $e');
      rethrow;
    }
  }

  Future<NutrientDeficiencyResult> scanNutrientDeficiency({
    String? imagePath,
    String? imageBase64,
    required String cropType,
    required String leafPosition,
    required String pattern,
    double soilPh = 6.5,
    String language = 'en',
  }) async {
    try {
      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        response = await _dioClient.uploadFile(
          ApiConstants.nutrientScan,
          imagePath,
          fieldName: 'image',
          data: {
            'cropType': cropType,
            'leafPosition': leafPosition,
            'pattern': pattern,
            'soilPh': soilPh.toString(),
            'language': language,
          },
        );
      } else {
        response = await _dioClient.post(
          ApiConstants.nutrientScan,
          data: {
            if (imageBase64 != null) 'imageBase64': imageBase64,
            'cropType': cropType,
            'leafPosition': leafPosition,
            'pattern': pattern,
            'soilPh': soilPh,
            'language': language,
          },
        );
      }
      return NutrientDeficiencyResult.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to scan nutrient deficiency: $e');
      rethrow;
    }
  }

  /// 4. Pest Database & ETL Scout
  Future<List<PestModel>> fetchPestDatabase() async {
    try {
      final response = await _dioClient.get(ApiConstants.pestDatabase);
      final list = (response.data?['data']?['pests'] as List<dynamic>?) ?? [];
      return list.map((e) => PestModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch pest database: $e');
      rethrow;
    }
  }

  Future<PestScoutResult> scoutPest({
    String? imagePath,
    String? imageBase64,
    String? pestId,
    required String cropType,
    required String cropStage,
    required double observedDamagePercent,
    int? infestedPlantsCount,
    int? totalSampledPlants,
    String language = 'en',
  }) async {
    try {
      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        response = await _dioClient.uploadFile(
          ApiConstants.pestScout,
          imagePath,
          fieldName: 'image',
          data: {
            if (pestId != null) 'pestId': pestId,
            'cropType': cropType,
            'cropStage': cropStage,
            'observedDamagePercent': observedDamagePercent.toString(),
            if (infestedPlantsCount != null) 'infestedPlantsCount': infestedPlantsCount.toString(),
            if (totalSampledPlants != null) 'totalSampledPlants': totalSampledPlants.toString(),
            'language': language,
          },
        );
      } else {
        response = await _dioClient.post(
          ApiConstants.pestScout,
          data: {
            if (imageBase64 != null) 'imageBase64': imageBase64,
            if (pestId != null) 'pestId': pestId,
            'cropType': cropType,
            'cropStage': cropStage,
            'observedDamagePercent': observedDamagePercent,
            if (infestedPlantsCount != null) 'infestedPlantsCount': infestedPlantsCount,
            if (totalSampledPlants != null) 'totalSampledPlants': totalSampledPlants,
            'language': language,
          },
        );
      }
      return PestScoutResult.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to scout pest: $e');
      rethrow;
    }
  }

  /// 5. Tank-Mix Compatibility
  Future<List<AgrochemicalModel>> fetchAgrochemicals() async {
    try {
      final response = await _dioClient.get(ApiConstants.tankMixChemicals);
      final list = (response.data?['data']?['chemicals'] as List<dynamic>?) ?? [];
      return list.map((e) => AgrochemicalModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch agrochemicals: $e');
      rethrow;
    }
  }

  Future<TankMixValidationResult> validateTankMix({
    required List<String> productIds,
    double waterVolumeLiters = 16.0,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.tankMixValidate,
        data: {
          'productIds': productIds,
          'waterVolumeLiters': waterVolumeLiters,
        },
      );
      return TankMixValidationResult.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to validate tank mix: $e');
      rethrow;
    }
  }

  /// 6. Seed Calculator
  Future<List<CropAgronomyModel>> fetchSeedCrops() async {
    try {
      final response = await _dioClient.get(ApiConstants.seedCrops);
      final list = (response.data?['data']?['crops'] as List<dynamic>?) ?? [];
      return list.map((e) => CropAgronomyModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.error('Failed to fetch seed crops: $e');
      rethrow;
    }
  }

  Future<SeedCalculationResult> calculateSeedPlan({
    required String cropId,
    required double areaValue,
    required String areaUnit,
    required String plantingMethod,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.seedCalculator,
        data: {
          'cropId': cropId,
          'areaValue': areaValue,
          'areaUnit': areaUnit,
          'plantingMethod': plantingMethod,
        },
      );
      return SeedCalculationResult.fromJson(response.data?['data'] as Map<String, dynamic>? ?? {});
    } catch (e) {
      AppLogger.error('Failed to calculate seed plan: $e');
      rethrow;
    }
  }
}

/// Repository Provider
final cropProtectionRepositoryProvider = Provider<CropProtectionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CropProtectionRepository(dioClient);
});

/// 1. Weed Detection State
class WeedDetectorState {
  final bool isLoading;
  final String? error;
  final WeedDetectionResult? result;

  const WeedDetectorState({this.isLoading = false, this.error, this.result});

  WeedDetectorState copyWith({bool? isLoading, String? error, WeedDetectionResult? result}) {
    return WeedDetectorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class WeedDetectorNotifier extends StateNotifier<WeedDetectorState> {
  final CropProtectionRepository _repo;

  WeedDetectorNotifier(this._repo) : super(const WeedDetectorState());

  Future<void> detect({
    String? imagePath,
    String? imageBase64,
    required String cropType,
    required double areaHectares,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.detectWeed(
        imagePath: imagePath,
        imageBase64: imageBase64,
        cropType: cropType,
        areaHectares: areaHectares,
      );
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const WeedDetectorState();
  }
}

final weedDetectorStateProvider = StateNotifierProvider<WeedDetectorNotifier, WeedDetectorState>((ref) {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return WeedDetectorNotifier(repo);
});

final weedListFutureProvider = FutureProvider.autoDispose<List<WeedModel>>((ref) async {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return repo.fetchWeedDatabase();
});

/// 2. Spray Window Future Provider
final sprayWindowFutureProvider = FutureProvider.family.autoDispose<SprayWindowData, ({double? lat, double? lng, String? farmId})>(
  (ref, params) async {
    final repo = ref.watch(cropProtectionRepositoryProvider);
    return repo.fetchSprayWindow(lat: params.lat, lng: params.lng, farmId: params.farmId);
  },
);

/// 3. Nutrient Scanner State
class NutrientScannerState {
  final bool isLoading;
  final String? error;
  final NutrientDeficiencyResult? result;

  const NutrientScannerState({this.isLoading = false, this.error, this.result});

  NutrientScannerState copyWith({bool? isLoading, String? error, NutrientDeficiencyResult? result}) {
    return NutrientScannerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class NutrientScannerNotifier extends StateNotifier<NutrientScannerState> {
  final CropProtectionRepository _repo;

  NutrientScannerNotifier(this._repo) : super(const NutrientScannerState());

  Future<void> scan({
    String? imagePath,
    String? imageBase64,
    required String cropType,
    required String leafPosition,
    required String pattern,
    double soilPh = 6.5,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.scanNutrientDeficiency(
        imagePath: imagePath,
        imageBase64: imageBase64,
        cropType: cropType,
        leafPosition: leafPosition,
        pattern: pattern,
        soilPh: soilPh,
      );
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const NutrientScannerState();
  }
}

final nutrientScannerStateProvider = StateNotifierProvider<NutrientScannerNotifier, NutrientScannerState>((ref) {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return NutrientScannerNotifier(repo);
});

final nutrientDatabaseFutureProvider = FutureProvider.autoDispose<List<NutrientDeficiencyModel>>((ref) async {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return repo.fetchNutrientDatabase();
});

/// 4. Pest Scout State
class PestScoutState {
  final bool isLoading;
  final String? error;
  final PestScoutResult? result;

  const PestScoutState({this.isLoading = false, this.error, this.result});

  PestScoutState copyWith({bool? isLoading, String? error, PestScoutResult? result}) {
    return PestScoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class PestScoutNotifier extends StateNotifier<PestScoutState> {
  final CropProtectionRepository _repo;

  PestScoutNotifier(this._repo) : super(const PestScoutState());

  Future<void> scout({
    String? imagePath,
    String? imageBase64,
    String? pestId,
    required String cropType,
    required String cropStage,
    required double observedDamagePercent,
    int? infestedPlantsCount,
    int? totalSampledPlants,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.scoutPest(
        imagePath: imagePath,
        imageBase64: imageBase64,
        pestId: pestId,
        cropType: cropType,
        cropStage: cropStage,
        observedDamagePercent: observedDamagePercent,
        infestedPlantsCount: infestedPlantsCount,
        totalSampledPlants: totalSampledPlants,
      );
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const PestScoutState();
  }
}

final pestScoutStateProvider = StateNotifierProvider<PestScoutNotifier, PestScoutState>((ref) {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return PestScoutNotifier(repo);
});

final pestDatabaseFutureProvider = FutureProvider.autoDispose<List<PestModel>>((ref) async {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return repo.fetchPestDatabase();
});

/// 5. Tank Mix State
class TankMixState {
  final bool isLoading;
  final String? error;
  final TankMixValidationResult? result;

  const TankMixState({this.isLoading = false, this.error, this.result});

  TankMixState copyWith({bool? isLoading, String? error, TankMixValidationResult? result}) {
    return TankMixState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class TankMixNotifier extends StateNotifier<TankMixState> {
  final CropProtectionRepository _repo;

  TankMixNotifier(this._repo) : super(const TankMixState());

  Future<void> validate({
    required List<String> productIds,
    double waterVolumeLiters = 16.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.validateTankMix(
        productIds: productIds,
        waterVolumeLiters: waterVolumeLiters,
      );
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const TankMixState();
  }
}

final tankMixStateProvider = StateNotifierProvider<TankMixNotifier, TankMixState>((ref) {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return TankMixNotifier(repo);
});

final agrochemicalListFutureProvider = FutureProvider.autoDispose<List<AgrochemicalModel>>((ref) async {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return repo.fetchAgrochemicals();
});

/// 6. Seed Calculator State
class SeedCalculatorState {
  final bool isLoading;
  final String? error;
  final SeedCalculationResult? result;

  const SeedCalculatorState({this.isLoading = false, this.error, this.result});

  SeedCalculatorState copyWith({bool? isLoading, String? error, SeedCalculationResult? result}) {
    return SeedCalculatorState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class SeedCalculatorNotifier extends StateNotifier<SeedCalculatorState> {
  final CropProtectionRepository _repo;

  SeedCalculatorNotifier(this._repo) : super(const SeedCalculatorState());

  Future<void> calculate({
    required String cropId,
    required double areaValue,
    required String areaUnit,
    required String plantingMethod,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.calculateSeedPlan(
        cropId: cropId,
        areaValue: areaValue,
        areaUnit: areaUnit,
        plantingMethod: plantingMethod,
      );
      state = state.copyWith(isLoading: false, result: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const SeedCalculatorState();
  }
}

final seedCalculatorStateProvider = StateNotifierProvider<SeedCalculatorNotifier, SeedCalculatorState>((ref) {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return SeedCalculatorNotifier(repo);
});

final seedCropsFutureProvider = FutureProvider.autoDispose<List<CropAgronomyModel>>((ref) async {
  final repo = ref.watch(cropProtectionRepositoryProvider);
  return repo.fetchSeedCrops();
});
