import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/core/network/dio_client.dart';
import 'package:EthioFarm/core/storage/secure_storage_service.dart';
import 'package:EthioFarm/features/diagnosis/models/diagnosis_models.dart';
import 'package:EthioFarm/features/diagnosis/repositories/diagnosis_repository.dart';
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

    test('DiagnosisModel deserializes nested Gemini and multilingual fields correctly', () {
      final json = {
        'id': 'diag-complex-01',
        'farmId': 'farm-eth-01',
        'imageUrl': 'https://example.com/leaf.jpg',
        'cropIdentified': 'Coffee',
        'cropIdentifiedAm': 'ቡና',
        'diseaseName': 'Coffee Berry Disease',
        'diseaseNameAm': 'የቡና ፍሬ በሽታ',
        'pathogen': 'Colletotrichum kahawae',
        'severity': 'HIGH',
        'confidenceScore': 96.5,
        'treatment': 'Apply copper-based fungicide before rainy season.',
        'treatmentEn': 'Apply copper-based fungicide before rainy season.',
        'treatmentAm': 'የመዳብ ፈንገስ ማጥፊያ ዝናብ ከመግባቱ በፊት ይረጩ።',
        'treatmentOm': 'Qoricha koopparii roobni dura biifuu.',
        'preventionTips': 'Prune infested branches and ensure adequate canopy aeration.',
        'preventionEn': 'Prune infested branches and ensure adequate canopy aeration.',
        'preventionAm': 'የተጠቁ ቅርንጫፎችን መቁረጥ እና የአየር ዝውውርን ማረጋገጥ።',
        'symptomsEn': 'Dark sunken lesions on expanding green berries.',
        'symptomsAm': 'በአረንጓዴ ፍሬዎች ላይ ጥቁር የሰመጡ ቁስሎች።',
        'aiModel': 'OpenRouter Gemini 2.5 Flash Vision + Plant.id Botanical Engine',
        'dataSources': 'OpenRouter AI, Plant.id v3, Pl@ntNet API',
        'enginesUsed': ['OpenRouter Gemini 2.5 Flash', 'Plant.id v3', 'Pl@ntNet API'],
        'fetchedAt': '2026-09-09T10:30:00.000Z',
        'diagnosisStatus': 'SUCCESS',
        'createdAt': '2026-09-09T10:30:00.000Z',
        'farm': {
          'id': 'farm-eth-01',
          'farmName': 'Jimma Highlands Specialty Plot',
          'primaryCrop': 'Coffee Arabica',
        },
      };

      final model = DiagnosisModel.fromJson(json);

      expect(model.id, equals('diag-complex-01'));
      expect(model.farmId, equals('farm-eth-01'));
      expect(model.cropIdentified, equals('Coffee'));
      expect(model.cropIdentifiedAm, equals('ቡና'));
      expect(model.diseaseName, equals('Coffee Berry Disease'));
      expect(model.diseaseNameAm, equals('የቡና ፍሬ በሽታ'));
      expect(model.pathogen, equals('Colletotrichum kahawae'));
      expect(model.severity, equals('HIGH'));
      expect(model.confidenceScore, equals(96.5));
      expect(model.treatmentAm, contains('የመዳብ'));
      expect(model.treatmentOm, contains('Qoricha'));
      expect(model.symptomsEn, contains('Dark sunken'));
      expect(model.symptomsAm, contains('ጥቁር'));
      expect(model.enginesUsed.length, equals(3));
      expect(model.farm, isNotNull);
      expect(model.farm!.farmName, equals('Jimma Highlands Specialty Plot'));
      expect(model.farm!.primaryCrop, equals('Coffee Arabica'));

      final serialized = model.toJson();
      expect(serialized['cropIdentifiedAm'], equals('ቡና'));
      expect(serialized['treatmentOm'], equals('Qoricha koopparii roobni dura biifuu.'));
      expect(serialized['farm']['farmName'], equals('Jimma Highlands Specialty Plot'));
    });

    test('DiagnosisFilters copyWith and serialization work correctly', () {
      const filters = DiagnosisFilters(
        farmId: 'farm-1',
        status: 'SUCCESS',
        cropType: 'Wheat',
        limit: 20,
      );

      final updated = filters.copyWith(status: 'PENDING', cropType: 'Teff');
      expect(updated.farmId, equals('farm-1'));
      expect(updated.status, equals('PENDING'));
      expect(updated.cropType, equals('Teff'));
      expect(updated.limit, equals(20));

      final json = updated.toJson();
      expect(json['farmId'], equals('farm-1'));
      expect(json['status'], equals('PENDING'));
      expect(json['cropType'], equals('Teff'));
      expect(json['limit'], equals(20));
    });
  });
}
