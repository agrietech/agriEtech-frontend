import 'package:dio/dio.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/boundary_models.dart';

class BoundaryRepository {
  final DioClient _dioClient;

  BoundaryRepository(this._dioClient);

  /// Get all regions
  Future<List<RegionModel>> getRegions() async {
    try {
      AppLogger.info('Fetching regions');

      final response = await _dioClient.get('/boundaries/regions');

      final regionsList = (response.data['data'] as List)
          .map((json) => RegionModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${regionsList.length} regions');
      return regionsList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch regions', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching regions', e);
      throw const UnknownError(
        message: 'Failed to fetch regions',
      );
    }
  }

  /// Get zones by region
  Future<List<ZoneModel>> getZonesByRegion(String regionId) async {
    try {
      AppLogger.info('Fetching zones for region', {'regionId': regionId});

      final response = await _dioClient.get(
        '/boundaries/zones',
        queryParameters: {'regionId': regionId},
      );

      final zonesList = (response.data['data'] as List)
          .map((json) => ZoneModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${zonesList.length} zones');
      return zonesList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch zones', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching zones', e);
      throw const UnknownError(
        message: 'Failed to fetch zones',
      );
    }
  }

  /// Get woredas by zone
  Future<List<WoredaModel>> getWoredasByZone(String zoneId) async {
    try {
      AppLogger.info('Fetching woredas for zone', {'zoneId': zoneId});

      final response = await _dioClient.get(
        '/boundaries/woredas',
        queryParameters: {'zoneId': zoneId},
      );

      final woredasList = (response.data['data'] as List)
          .map((json) => WoredaModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${woredasList.length} woredas');
      return woredasList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch woredas', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching woredas', e);
      throw const UnknownError(
        message: 'Failed to fetch woredas',
      );
    }
  }

  /// Get all woredas
  Future<List<WoredaModel>> getAllWoredas() async {
    try {
      AppLogger.info('Fetching all woredas');

      final response = await _dioClient.get('/boundaries/woredas');

      final woredasList = (response.data['data'] as List)
          .map((json) => WoredaModel.fromJson(json))
          .toList();

      AppLogger.success('Fetched ${woredasList.length} woredas');
      return woredasList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch woredas', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching woredas', e);
      throw const UnknownError(
        message: 'Failed to fetch woredas',
      );
    }
  }

  /// Get woreda by ID with full details
  Future<WoredaModel> getWoredaById(String woredaId) async {
    try {
      AppLogger.info('Fetching woreda by ID', {'woredaId': woredaId});

      final response = await _dioClient.get('/boundaries/woredas/$woredaId');

      final woreda = WoredaModel.fromJson(response.data['data']);
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
