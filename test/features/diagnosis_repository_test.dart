import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/network/dio_client.dart';
import 'package:agrietech/core/storage/secure_storage_service.dart';
import 'package:agrietech/features/diagnosis/models/diagnosis_models.dart';
import 'package:agrietech/features/diagnosis/repositories/diagnosis_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  late DiagnosisRepository diagnosisRepository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final secureStorage = SecureStorageService(storage);
    final dioClient = DioClient(secureStorage);
    diagnosisRepository = DiagnosisRepository(dioClient);
  });

  group('DiagnosisRepository - calculateStatistics', () {
    test('calculates correct disease and crop statistics', () {
      final mockDiagnoses = [
        const DiagnosisModel(
          id: 'd1',
          farmId: 'f1',
          imageUrl: 'https://example.com/img1.jpg',
          cropIdentified: 'Wheat',
          diseaseName: 'Wheat Rust',
          confidenceScore: 0.94,
          diagnosisStatus: 'SUCCESS',
          createdAt: '2026-08-17T00:00:00Z',
        ),
        const DiagnosisModel(
          id: 'd2',
          farmId: 'f1',
          imageUrl: 'https://example.com/img2.jpg',
          cropIdentified: 'Wheat',
          diseaseName: 'Powdery Mildew',
          confidenceScore: 0.88,
          diagnosisStatus: 'SUCCESS',
          createdAt: '2026-08-17T00:00:00Z',
        ),
        const DiagnosisModel(
          id: 'd3',
          farmId: 'f2',
          imageUrl: 'https://example.com/img3.jpg',
          cropIdentified: 'Teff',
          diseaseName: 'Head Smut',
          confidenceScore: 0.75,
          diagnosisStatus: 'PENDING',
          createdAt: '2026-08-17T00:00:00Z',
        ),
      ];

      final stats = diagnosisRepository.calculateStatistics(mockDiagnoses);

      expect(stats.total, equals(3));
      expect(stats.success, equals(2));
      expect(stats.pending, equals(1));
      expect(stats.failed, equals(0));
      expect(stats.byCrop?['Wheat'], equals(2));
      expect(stats.byCrop?['Teff'], equals(1));
      expect(stats.byDisease?['Wheat Rust'], equals(1));
      expect(stats.byDisease?['Powdery Mildew'], equals(1));
    });

    test('DiagnosisModel deserializes live data sources and fetchedAt correctly', () {
      final json = {
        'id': 'diag-live-01',
        'farmId': null,
        'imageUrl': 'https://api.plant.id/images/test.jpg',
        'cropIdentified': 'Teff',
        'diseaseName': 'Teff Rust (Uromyces eragrostidis)',
        'confidenceScore': 0.95,
        'aiModel': 'Plant.id Botanical Engine + OpenRouter AI Specialist',
        'dataSources': 'Plant.id Botanical Engine, Pl@ntNet API, Perenual Database, OpenRouter AI Specialist',
        'enginesUsed': ['Plant.id', 'Pl@ntNet', 'Perenual', 'OpenRouter AI'],
        'fetchedAt': '2026-09-08T09:20:00.000Z',
        'diagnosisStatus': 'SUCCESS',
        'createdAt': '2026-09-08T09:20:00.000Z',
      };

      final model = DiagnosisModel.fromJson(json);

      expect(model.id, equals('diag-live-01'));
      expect(model.farmId, isNull);
      expect(model.cropIdentified, equals('Teff'));
      expect(model.diseaseName, equals('Teff Rust (Uromyces eragrostidis)'));
      expect(model.confidenceScore, equals(0.95));
      expect(model.dataSources, contains('Plant.id Botanical'));
      expect(model.dataSources, contains('OpenRouter AI Specialist'));
      expect(model.enginesUsed, contains('Plant.id'));
      expect(model.enginesUsed, contains('OpenRouter AI'));
      expect(model.fetchedAt, equals('2026-09-08T09:20:00.000Z'));
    });

    test('CreateDiagnosisRequest supports optional farmId', () {
      const reqWithFarm = CreateDiagnosisRequest(
        farmId: 'farm-123',
        imageBase64: 'abc',
        cropType: 'Wheat',
      );
      expect(reqWithFarm.toJson()['farmId'], equals('farm-123'));

      const reqWithoutFarm = CreateDiagnosisRequest(
        imageBase64: 'def',
        cropType: 'Coffee',
      );
      expect(reqWithoutFarm.toJson().containsKey('farmId'), isFalse);
    });
  });
}
