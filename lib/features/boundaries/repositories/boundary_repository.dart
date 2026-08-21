import 'package:dio/dio.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../data/ethiopia_boundaries_data.dart';
import '../models/boundary_models.dart';

class BoundaryRepository {
  final DioClient _dioClient;

  BoundaryRepository(this._dioClient);

  /// Get all regions
  Future<List<RegionModel>> getRegions() async {
    try {
      AppLogger.info('Fetching regions');

      final response = await _dioClient.get('/boundaries/regions');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final regionsList = list
          .map((json) => RegionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (regionsList.isNotEmpty) {
        AppLogger.success('Fetched ${regionsList.length} regions');
        return regionsList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch regions from backend, using preloaded data: $e');
    }
    return EthiopiaBoundariesData.defaultRegions;
  }

  /// Get zones by region
  Future<List<ZoneModel>> getZonesByRegion(String regionId) async {
    try {
      AppLogger.info('Fetching zones for region', {'regionId': regionId});

      final response = await _dioClient.get(
        '/boundaries/zones',
        queryParameters: {'regionId': regionId},
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final zonesList = list
          .map((json) => ZoneModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (zonesList.isNotEmpty) {
        AppLogger.success('Fetched ${zonesList.length} zones');
        return zonesList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch zones for $regionId, using preloaded data: $e');
    }
    return EthiopiaBoundariesData.getFallbackZones(regionId);
  }

  /// Get woredas by zone
  Future<List<WoredaModel>> getWoredasByZone(String zoneId) async {
    try {
      AppLogger.info('Fetching woredas for zone', {'zoneId': zoneId});

      final response = await _dioClient.get(
        '/boundaries/woredas',
        queryParameters: {'zoneId': zoneId},
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final woredasList = list
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (woredasList.isNotEmpty) {
        AppLogger.success('Fetched ${woredasList.length} woredas');
        return woredasList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch woredas for $zoneId, using preloaded data: $e');
    }
    return EthiopiaBoundariesData.getFallbackWoredas(zoneId);
  }

  /// Get all woredas
  Future<List<WoredaModel>> getAllWoredas() async {
    try {
      AppLogger.info('Fetching all woredas');

      final response = await _dioClient.get('/boundaries/woredas');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final woredasList = list
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (woredasList.isNotEmpty) {
        AppLogger.success('Fetched ${woredasList.length} woredas');
        return woredasList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch all woredas, using preloaded data: $e');
    }
    final all = <WoredaModel>[];
    for (final list in EthiopiaBoundariesData.defaultWoredasByZone.values) {
      all.addAll(list);
    }
    return all;
  }

  /// Get woreda by ID with full details
  Future<WoredaModel> getWoredaById(String woredaId) async {
    try {
      AppLogger.info('Fetching woreda by ID', {'woredaId': woredaId});

      final response = await _dioClient.get('/boundaries/woredas/$woredaId');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final woreda = WoredaModel.fromJson(raw as Map<String, dynamic>);
      AppLogger.success('Fetched woreda details');
      return woreda;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch woreda', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching woreda', e);
      throw const UnknownError(
        message: 'Failed to fetch woreda details',
      );
    }
  }

  /// Calculate boundary statistics
  BoundaryStatistics calculateStatistics(
    List<RegionModel> regions,
    List<ZoneModel> zones,
    List<WoredaModel> woredas,
  ) {
    final woredasByZone = <String, int>{};
    final zonesByRegion = <String, int>{};
    int totalPopulation = 0;

    // Count woredas by zone
    for (final woreda in woredas) {
      if (woreda.zone != null) {
        final zoneName = woreda.zone!.name;
        woredasByZone[zoneName] = (woredasByZone[zoneName] ?? 0) + 1;
      }
      if (woreda.population != null) {
        totalPopulation += woreda.population!;
      }
    }

    // Count zones by region
    for (final zone in zones) {
      if (zone.region != null) {
        final regionName = zone.region!.name;
        zonesByRegion[regionName] = (zonesByRegion[regionName] ?? 0) + 1;
      }
    }

    return BoundaryStatistics(
      totalRegions: regions.length,
      totalZones: zones.length,
      totalWoredas: woredas.length,
      totalPopulation: totalPopulation,
      woredasByZone: woredasByZone,
      zonesByRegion: zonesByRegion,
    );
  }
}
