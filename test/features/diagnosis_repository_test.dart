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
  });
}
