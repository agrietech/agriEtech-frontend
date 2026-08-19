import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/network/dio_client.dart';
import 'package:agrietech/core/storage/secure_storage_service.dart';
import 'package:agrietech/features/alerts/models/alert_models.dart';
import 'package:agrietech/features/alerts/repositories/alert_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  late AlertRepository alertRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final secureStorage = SecureStorageService(storage);
    final dioClient = DioClient(secureStorage);
    alertRepository = AlertRepository(dioClient);
  });

  group('AlertRepository - calculateStatistics', () {
    test('calculates correct summary statistics from alert list', () {
      final mockAlerts = [
        const AlertModel(
          id: '1',
          woredaId: 'w1',
          hazardType: 'DROUGHT',
          severity: 'CRITICAL',
          title: 'Severe Drought Warning',
          message: 'Critical water shortage in Woreda A',
          isActive: true,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          woreda: WoredaBasicInfo(id: 'w1', name: 'Woreda A'),
        ),
        const AlertModel(
          id: '2',
          woredaId: 'w1',
          hazardType: 'FLOOD',
          severity: 'HIGH',
          title: 'Flood Alert',
          message: 'River overflow risk',
          isActive: true,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          woreda: WoredaBasicInfo(id: 'w1', name: 'Woreda A'),
        ),
        const AlertModel(
          id: '3',
          woredaId: 'w2',
          hazardType: 'DROUGHT',
          severity: 'MODERATE',
          title: 'Moderate Drought Warning',
          message: 'Below average rainfall',
          isActive: false,
          createdAt: '2026-08-17T00:00:00Z',
          updatedAt: '2026-08-17T00:00:00Z',
          woreda: WoredaBasicInfo(id: 'w2', name: 'Woreda B'),
        ),
      ];

      final stats = alertRepository.calculateStatistics(mockAlerts);

      expect(stats.total, equals(3));
      expect(stats.critical, equals(1));
      expect(stats.high, equals(1));
      expect(stats.moderate, equals(1));
      expect(stats.low, equals(0));
      expect(stats.active, equals(2));
      expect(stats.expired, equals(1));
      expect(stats.byHazardType?['DROUGHT'], equals(2));
      expect(stats.byHazardType?['FLOOD'], equals(1));
      expect(stats.byWoreda?['Woreda A'], equals(2));
      expect(stats.byWoreda?['Woreda B'], equals(1));
    });

    test('handles empty list gracefully', () {
      final stats = alertRepository.calculateStatistics([]);
      expect(stats.total, equals(0));
      expect(stats.critical, equals(0));
      expect(stats.active, equals(0));
    });
  });
}
