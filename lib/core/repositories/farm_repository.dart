import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../error/app_error.dart';
import '../utils/logger.dart';
import '../models/farm_model.dart';

/// Farm repository
class FarmRepository {
  final DioClient _dioClient;

  FarmRepository(this._dioClient);

  /// Get all farms for the current user
  Future<List<FarmModel>> getFarms() async {
    try {
      AppLogger.info('Fetching user farms');
      
      final response = await _dioClient.get(ApiConstants.farms);
      
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      final farms = data
          .map((json) => FarmModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Farms fetched: ${farms.length} farms');
      
      return farms;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch farms', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farms fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch farms: ${e.toString()}');
    }
  }

  /// Get farm by ID
  Future<FarmModel> getFarmById(String farmId) async {
    try {
      AppLogger.info('Fetching farm: $farmId');
      
      final response = await _dioClient.get(ApiConstants.farmById(farmId));
      
      final rawData = response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;
      final farm = FarmModel.fromJson(rawData as Map<String, dynamic>);
      
      AppLogger.info('Farm fetched successfully: ${farm.farmName}');
      
      return farm;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch farm', e);
      
      if (e.response?.statusCode == 404) {
        throw const UnknownError(message: 'Farm not found');
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farm fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch farm: ${e.toString()}');
    }
  }

  /// Create a new farm
  Future<FarmModel> createFarm(CreateFarmRequest request) async {
    try {
      AppLogger.info('Creating farm: ${request.farmName}');
      
      final response = await _dioClient.post(
        ApiConstants.farms, data: request.toJson(),
      );
      
      dynamic raw = response.data;
      Map<String, dynamic> farmJson = {};
      
      if (raw is Map) {
        final rawMap = Map<String, dynamic>.from(raw);
        if (rawMap['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(rawMap['data'] as Map);
          farmJson = dataMap['farm'] is Map
              ? Map<String, dynamic>.from(dataMap['farm'] as Map)
              : dataMap;
        } else if (rawMap['farm'] is Map) {
          farmJson = Map<String, dynamic>.from(rawMap['farm'] as Map);
        } else {
          farmJson = rawMap;
        }
      }
      
      // If server returned partial data, inject request data to guarantee clean model
      if ((farmJson['farmName'] == null && farmJson['name'] == null) || farmJson['farmName'] == 'Farm Plot') {
        farmJson['farmName'] = request.farmName;
      }
      if (farmJson['primaryCrop'] == null && farmJson['cropType'] == null) {
        farmJson['primaryCrop'] = request.primaryCrop;
      }
      if (farmJson['areaHectares'] == null && farmJson['size'] == null) {
        farmJson['areaHectares'] = request.areaHectares;
      }
      if (farmJson['latitude'] == null && farmJson['lat'] == null) {
        farmJson['latitude'] = request.latitude;
      }
      if (farmJson['longitude'] == null && farmJson['lng'] == null) {
        farmJson['longitude'] = request.longitude;
      }
      if (farmJson['woredaId'] == null && request.woredaId != null) {
        farmJson['woredaId'] = request.woredaId;
      }
      if (farmJson['id'] == null && farmJson['_id'] == null) {
        farmJson['id'] = 'farm_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      final farm = FarmModel.fromJson(farmJson);
      
      AppLogger.info('Farm created successfully: ${farm.id}');
      
      return farm;
    } on DioException catch (e) {
      AppLogger.error('Failed to create farm', e);
      
      if (e.response?.statusCode == 422) {
        throw ValidationError.fromResponse(e.response!.data);
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      AppLogger.error('Unexpected farm creation error', e, stackTrace);
      throw UnknownError(message: 'Failed to create farm: ${e.toString()}');
    }
  }

  /// Update farm
  Future<FarmModel> updateFarm(String farmId, UpdateFarmRequest request) async {
    try {
      AppLogger.info('Updating farm: $farmId');
      
      final response = await _dioClient.put(
        ApiConstants.farmById(farmId), data: request.toJson(),
      );
      
      final farm = FarmModel.fromJson(response.data as Map<String, dynamic>);
      
      AppLogger.info('Farm updated successfully');
      
      return farm;
    } on DioException catch (e) {
      AppLogger.error('Failed to update farm', e);
      
      if (e.response?.statusCode == 404) {
        throw const UnknownError(message: 'Farm not found');
      }
      
      if (e.response?.statusCode == 422) {
        throw ValidationError.fromResponse(e.response!.data);
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farm update error', e, stackTrace);
      throw UnknownError(message: 'Failed to update farm: ${e.toString()}');
    }
  }

  /// Delete farm
  Future<void> deleteFarm(String farmId) async {
    try {
      AppLogger.info('Deleting farm: $farmId');
      
      await _dioClient.delete(ApiConstants.farmById(farmId));
      
      AppLogger.info('Farm deleted successfully');
    } on DioException catch (e) {
      AppLogger.error('Failed to delete farm', e);
      
      if (e.response?.statusCode == 404) {
        throw const UnknownError(message: 'Farm not found');
      }
      
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farm deletion error', e, stackTrace);
      throw UnknownError(message: 'Failed to delete farm: ${e.toString()}');
    }
  }

  /// Get farms with risk assessment
  Future<List<FarmModel>> getFarmsWithRisk() async {
    try {
      AppLogger.info('Fetching farms with risk assessment');
      
      final response = await _dioClient.get(
        ApiConstants.farms,
        queryParameters: {'includeRisk': true},
      );
      
      final rawData = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final List<dynamic> data = rawData is List ? rawData : [];
      final farms = data
          .map((json) => FarmModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      AppLogger.info('Farms with risk fetched: ${farms.length} farms');
      
      return farms;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch farms with risk', e);
      throw NetworkError.fromDioException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected farms with risk fetch error', e, stackTrace);
      throw UnknownError(message: 'Failed to fetch farms: ${e.toString()}');
    }
  }
}

/// Provider for FarmRepository
final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FarmRepository(dioClient);
});

