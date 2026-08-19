import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/network/dio_client.dart';
import 'package:agrietech/core/storage/secure_storage_service.dart';
import 'package:agrietech/features/sensors/models/sensor_models.dart';
import 'package:agrietech/features/sensors/repositories/sensor_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  late SensorRepository sensorRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final secureStorage = SecureStorageService(storage);
    final dioClient = DioClient(secureStorage);
    sensorRepository = SensorRepository(dioClient);
  });

  group('SensorRepository - calculateStatistics', () {
    test('calculates correct statistics for sensor fleet', () {
      final mockSensors = [
        const SensorModel(
          id: 's1',
          farmId: 'f1',
          hardwareId: 'HW-001',
          sensorType: 'SOIL_MOISTURE',
          isActive: true,
          batteryLevel: 85,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          farm: SensorFarmInfo(id: 'f1', farmName: 'Farm Alpha'),
        ),
        const SensorModel(
          id: 's2',
          farmId: 'f1',
          hardwareId: 'HW-002',
          sensorType: 'SOIL_MOISTURE',
          isActive: true,
          batteryLevel: 15, // Low battery
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          farm: SensorFarmInfo(id: 'f1', farmName: 'Farm Alpha'),
        ),
        const SensorModel(
          id: 's3',
          farmId: 'f2',
          hardwareId: 'HW-003',
          sensorType: 'WEATHER_STATION',
          isActive: false,
          batteryLevel: 10, // Inactive + Low battery
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          farm: SensorFarmInfo(id: 'f2', farmName: 'Farm Beta'),
        ),
      ];

      final stats = sensorRepository.calculateStatistics(mockSensors);

      expect(stats.total, equals(3));
      expect(stats.active, equals(2));
      expect(stats.inactive, equals(1));
      expect(stats.lowBattery, equals(2));
      expect(stats.byType?['SOIL_MOISTURE'], equals(2));
      expect(stats.byType?['WEATHER_STATION'], equals(1));
      expect(stats.byFarm?['Farm Alpha'], equals(2));
      expect(stats.byFarm?['Farm Beta'], equals(1));
    });
  });
}
