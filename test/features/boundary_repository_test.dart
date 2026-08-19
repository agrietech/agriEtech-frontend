import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/network/dio_client.dart';
import 'package:agrietech/core/storage/secure_storage_service.dart';
import 'package:agrietech/features/boundaries/models/boundary_models.dart';
import 'package:agrietech/features/boundaries/repositories/boundary_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  late BoundaryRepository boundaryRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final secureStorage = SecureStorageService(storage);
    final dioClient = DioClient(secureStorage);
    boundaryRepository = BoundaryRepository(dioClient);
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
}
