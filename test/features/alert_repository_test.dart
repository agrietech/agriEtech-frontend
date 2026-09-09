import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/network/dio_client.dart';
import 'package:EthioFarm/core/storage/secure_storage_service.dart';
import 'package:EthioFarm/features/alerts/models/alert_models.dart';
import 'package:EthioFarm/features/alerts/repositories/alert_repository.dart';
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

  group('AlertModel - Multilingual & Deserialization', () {
    test('getTitle and getMessage correctly select language with fallbacks', () {
      const alert = AlertModel(
        id: 'alt-101',
        hazardType: 'LOCUST_PEST',
        severity: 'CRITICAL',
        title: 'Desert Locust Swarm',
        message: 'High density swarm detected heading south.',
        titleEn: 'Desert Locust Warning (English)',
        titleAm: 'የበረሃ አንበጣ ማስጠንቀቂያ',
        titleOm: 'Akeekkachiisa Hawwaan Gammoojjii',
        messageEn: 'High density swarm detected heading south (English).',
        messageAm: 'ከፍተኛ የአንበጣ መንጋ ወደ ደቡብ እየተንቀሳቀሰ ይገኛል።',
        messageOm: 'Tuuti hawwaan baay\'ee gara kibbaatti imalaa jira.',
        createdAt: '2026-08-20T00:00:00Z',
        updatedAt: '2026-08-20T00:00:00Z',
      );

      // English
      expect(alert.getTitle('en'), equals('Desert Locust Warning (English)'));
      expect(alert.getMessage('en'), equals('High density swarm detected heading south (English).'));

      // Amharic
      expect(alert.getTitle('am'), equals('የበረሃ አንበጣ ማስጠንቀቂያ'));
      expect(alert.getMessage('am'), equals('ከፍተኛ የአንበጣ መንጋ ወደ ደቡብ እየተንቀሳቀሰ ይገኛል።'));

      // Afaan Oromoo
      expect(alert.getTitle('om'), equals('Akeekkachiisa Hawwaan Gammoojjii'));
      expect(alert.getMessage('om'), equals('Tuuti hawwaan baay\'ee gara kibbaatti imalaa jira.'));

      // Default fallback
      expect(alert.getTitle(null), equals('Desert Locust Swarm'));
      expect(alert.getMessage(null), equals('High density swarm detected heading south.'));
    });

    test('fromJson correctly parses live backend payload with advisories and woreda metadata', () {
      final backendPayload = {
        'id': 'alt-live-999',
        'woredaId': 'w-addis-1',
        'hazardType': 'DROUGHT',
        'severity': 'HIGH',
        'titleEn': 'Severe Soil Desiccation',
        'titleAm': 'ከባድ የአፈር እርጥበት እጥረት',
        'messageEn': 'Low soil moisture requires mulch cover.',
        'messageAm': 'የአፈር እርጥበት እጥረትን ለመከላከል ጭድ ይሸፍኑ።',
        'status': 'SENT',
        'affectedAreaKm2': 185.5,
        'targetPhones': ['+251911223344', '+251922334455'],
        'actionItems': ['Deploy organic mulch', 'Restrict non-essential irrigation'],
        'advisories': [
          {
            'id': 'adv-1',
            'title': 'Mulch Protocol',
            'recommendation': 'Apply 8cm straw layer',
            'cropType': 'Teff',
          }
        ],
        'woreda': {
          'id': 'w-addis-1',
          'name': 'Adama Rural',
          'zone': 'East Shewa',
          'region': 'Oromia',
        },
        'createdAt': '2026-09-01T12:00:00Z',
        'updatedAt': '2026-09-01T12:30:00Z',
      };

      final alert = AlertModel.fromJson(backendPayload);

      expect(alert.id, equals('alt-live-999'));
      expect(alert.hazardType, equals('DROUGHT'));
      expect(alert.severity, equals('HIGH'));
      expect(alert.status, equals('SENT'));
      expect(alert.affectedAreaKm2, equals(185.5));
      expect(alert.targetPhones.length, equals(2));
      expect(alert.actionItems.length, equals(2));
      expect(alert.advisories.length, equals(1));
      expect(alert.advisories.first.cropType, equals('Teff'));
      expect(alert.woreda?.name, equals('Adama Rural'));
      expect(alert.woreda?.zone, equals('East Shewa'));
      expect(alert.woreda?.region, equals('Oromia'));
    });

    test('AlertFeedbackRequest and AlertFeedbackResponse serialize and deserialize correctly', () {
      const req = AlertFeedbackRequest(
        accurate: true,
        notes: 'Locust swarm confirmed over Eastern plot.',
      );
      final reqJson = req.toJson();
      expect(reqJson['accurate'], isTrue);
      expect(reqJson['notes'], equals('Locust swarm confirmed over Eastern plot.'));

      final respJson = {
        'alertId': 'alt-101',
        'userId': 'user-agent-7',
        'accurate': true,
        'notes': 'Verified on ground.',
        'submittedAt': '2026-09-09T10:00:00Z',
      };
      final resp = AlertFeedbackResponse.fromJson(respJson);
      expect(resp.alertId, equals('alt-101'));
      expect(resp.accurate, isTrue);
      expect(resp.notes, equals('Verified on ground.'));
      expect(resp.submittedAt, equals('2026-09-09T10:00:00Z'));
    });
  });
}
