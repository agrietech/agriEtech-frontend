import 'package:dio/dio.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import 'boundary_local_cache.dart';
import '../models/boundary_models.dart';

/// Boundary Repository managing real database queries and persistent offline caching.
class BoundaryRepository {
  final DioClient _dioClient;

  BoundaryRepository(this._dioClient);

  /// Get all regions from backend database, with persistent disk cache fallback
  Future<List<RegionModel>> getRegions() async {
    try {
      AppLogger.info('Fetching regions from backend database');

      final response = await _dioClient.get('/boundaries/regions');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final regionsList = list
          .map((json) => RegionModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (regionsList.isNotEmpty) {
        AppLogger.success('Fetched ${regionsList.length} regions from backend');
        // Persist to local disk cache for instant offline access
        await BoundaryLocalCache.saveRegions(regionsList);
        return regionsList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch regions from backend, checking local persistent cache: $e');
    }

    // Check local persistent disk cache
    final cached = await BoundaryLocalCache.getRegions();
    if (cached.isNotEmpty) {
      AppLogger.info('Loaded ${cached.length} regions from local disk cache');
      return cached;
    }

    // Cold-boot baseline
    return BoundaryLocalCache.defaultRegions;
  }

  /// Get zones for a region from backend database, with persistent disk cache fallback
  Future<List<ZoneModel>> getZonesByRegion(String regionId) async {
    try {
      AppLogger.info('Fetching zones from backend database for region', {'regionId': regionId});

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
        AppLogger.success('Fetched ${zonesList.length} zones from backend');
        // Persist to local disk cache
        await BoundaryLocalCache.saveZonesByRegion(regionId, zonesList);
        return zonesList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch zones for $regionId, checking local cache: $e');
    }

    // Check local persistent disk cache
    final cached = await BoundaryLocalCache.getZonesByRegion(regionId);
    if (cached.isNotEmpty) {
      AppLogger.info('Loaded ${cached.length} zones from local disk cache for $regionId');
      return cached;
    }

    return [];
  }

  /// Get woredas for a zone from backend database, with persistent disk cache fallback
  Future<List<WoredaModel>> getWoredasByZone(String zoneId) async {
    try {
      AppLogger.info('Fetching woredas from backend database for zone', {'zoneId': zoneId});

      final response = await _dioClient.get(
        '/boundaries/woredas',
        queryParameters: {'zoneId': zoneId, 'limit': 200},
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final woredasList = list
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (woredasList.isNotEmpty) {
        AppLogger.success('Fetched ${woredasList.length} woredas from backend for zone $zoneId');
        // Persist to local disk cache
        await BoundaryLocalCache.saveWoredasByZone(zoneId, woredasList);
        return woredasList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch woredas for $zoneId, checking local cache: $e');
    }

    // Check local persistent disk cache
    final cached = await BoundaryLocalCache.getWoredasByZone(zoneId);
    if (cached.isNotEmpty) {
      AppLogger.info('Loaded ${cached.length} woredas from local disk cache for $zoneId');
      return cached;
    }

    return [];
  }

  /// Get all woredas from backend database, with persistent disk cache fallback
  Future<List<WoredaModel>> getAllWoredas() async {
    try {
      AppLogger.info('Fetching all woredas from backend database');

      final response = await _dioClient.get(
        '/boundaries/woredas',
        queryParameters: {'limit': 1500},
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final woredasList = list
          .map((json) => WoredaModel.fromJson(json as Map<String, dynamic>))
          .toList();

      if (woredasList.isNotEmpty) {
        AppLogger.success('Fetched ${woredasList.length} woredas from backend');
        await BoundaryLocalCache.saveAllWoredas(woredasList);
        return woredasList;
      }
    } catch (e) {
      AppLogger.warning('Failed to fetch all woredas from backend, checking local cache: $e');
    }

    // Check local persistent disk cache
    final cached = await BoundaryLocalCache.getAllWoredas();
    if (cached.isNotEmpty) {
      AppLogger.info('Loaded ${cached.length} all woredas from local disk cache');
      return cached;
    }

    return [];
  }

  /// Get woreda by ID with full details from backend database
  Future<WoredaModel> getWoredaById(String woredaId) async {
    try {
      AppLogger.info('Fetching woreda details from backend database', {'woredaId': woredaId});

      final response = await _dioClient.get('/boundaries/woredas/$woredaId');

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final woreda = WoredaModel.fromJson(raw as Map<String, dynamic>);
      AppLogger.success('Fetched woreda details from backend');
      await BoundaryLocalCache.saveWoredaById(woredaId, woreda);
      return woreda;
    } on DioException catch (e) {
      AppLogger.warning('Dio error fetching woreda $woredaId: $e');
      final cached = await BoundaryLocalCache.getWoredaById(woredaId);
      if (cached != null) return cached;
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.warning('Unexpected error fetching woreda $woredaId: $e');
      final cached = await BoundaryLocalCache.getWoredaById(woredaId);
      if (cached != null) return cached;
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
