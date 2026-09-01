import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agrietech/core/network/dio_client.dart';
import 'package:agrietech/core/storage/secure_storage_service.dart';
import 'package:agrietech/features/boundaries/models/boundary_models.dart';
import 'package:agrietech/features/boundaries/repositories/boundary_local_cache.dart';
import 'package:agrietech/features/boundaries/repositories/boundary_repository.dart';

void main() {
  late BoundaryRepository boundaryRepository;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final secureStorage = SecureStorageService(storage);
    final dioClient = DioClient(secureStorage);
    boundaryRepository = BoundaryRepository(dioClient);
    await BoundaryLocalCache.clearCache();
  });

  group('BoundaryRepository - calculateStatistics', () {
    test('calculates correct boundary counts and aggregates', () {
      final regions = [
        const RegionModel(id: 'r1', name: 'Oromia', code: 'OR', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
        const RegionModel(id: 'r2', name: 'Amhara', code: 'AM', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
      ];

      final zones = [
        const ZoneModel(
          id: 'z1',
          name: 'East Shewa',
          regionId: 'r1',
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          region: RegionBasicInfo(id: 'r1', name: 'Oromia', code: 'OR'),
        ),
        const ZoneModel(
          id: 'z2',
          name: 'North Shewa',
          regionId: 'r2',
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          region: RegionBasicInfo(id: 'r2', name: 'Amhara', code: 'AM'),
        ),
      ];

      final woredas = [
        const WoredaModel(
          id: 'w1',
          name: 'Adama',
          zoneId: 'z1',
          centerLat: 8.54,
          centerLng: 39.27,
          population: 150000,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          zone: ZoneBasicInfo(id: 'z1', name: 'East Shewa'),
        ),
        const WoredaModel(
          id: 'w2',
          name: 'Bishoftu',
          zoneId: 'z1',
          centerLat: 8.75,
          centerLng: 38.98,
          population: 120000,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          zone: ZoneBasicInfo(id: 'z1', name: 'East Shewa'),
        ),
      ];

      final stats = boundaryRepository.calculateStatistics(regions, zones, woredas);

      expect(stats.totalRegions, equals(2));
      expect(stats.totalZones, equals(2));
      expect(stats.totalWoredas, equals(2));
      expect(stats.totalPopulation, equals(270000));
      expect(stats.woredasByZone?['East Shewa'], equals(2));
      expect(stats.zonesByRegion?['Oromia'], equals(1));
      expect(stats.zonesByRegion?['Amhara'], equals(1));
    });
  });

  group('BoundaryLocalCache - Persistent Offline Storage Tests', () {
    test('saves and retrieves regions from persistent disk cache', () async {
      final regions = [
        const RegionModel(id: 'r1', name: 'Oromia', code: 'OR', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
        const RegionModel(id: 'r2', name: 'Sidama', code: 'SI', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
      ];

      await BoundaryLocalCache.saveRegions(regions);
      final retrieved = await BoundaryLocalCache.getRegions();

      expect(retrieved.length, equals(2));
      expect(retrieved.first.name, equals('Oromia'));
      expect(retrieved.last.name, equals('Sidama'));
    });

    test('saves and retrieves zones by region from persistent disk cache', () async {
      final zones = [
        const ZoneModel(id: 'z1', name: 'East Shewa', regionId: 'r1', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
        const ZoneModel(id: 'z2', name: 'Arsi', regionId: 'r1', createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
      ];

      await BoundaryLocalCache.saveZonesByRegion('r1', zones);
      final retrieved = await BoundaryLocalCache.getZonesByRegion('r1');

      expect(retrieved.length, equals(2));
      expect(retrieved.first.name, equals('East Shewa'));
      expect(retrieved.last.name, equals('Arsi'));
    });

    test('saves and retrieves woredas by zone from persistent disk cache', () async {
      final woredas = [
        const WoredaModel(id: 'w1', name: 'Adama Zuria', zoneId: 'z1', centerLat: 8.54, centerLng: 39.27, createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
        const WoredaModel(id: 'w2', name: 'Lome', zoneId: 'z1', centerLat: 8.60, centerLng: 39.12, createdAt: '2026-08-17T00:00:00Z', updatedAt: '2026-08-17T00:00:00Z'),
      ];

      await BoundaryLocalCache.saveWoredasByZone('z1', woredas);
      final retrieved = await BoundaryLocalCache.getWoredasByZone('z1');

      expect(retrieved.length, equals(2));
      expect(retrieved.first.name, equals('Adama Zuria'));
      expect(retrieved.last.name, equals('Lome'));
    });
  });
}
