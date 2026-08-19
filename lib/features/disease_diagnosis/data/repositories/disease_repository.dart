import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/models/disease_diagnosis_model.dart';
import '../models/disease_result_model.dart';

class DiseaseRepository {
  final DioClient _dioClient;

  DiseaseRepository(this._dioClient);

  /// Diagnose crop disease using dual-AI pipeline (Plant.id + Gemini 2.5 Flash)
  Future<DiseaseDiagnosisModel> diagnoseDisease(DiagnosisRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.diagnose,
        data: request.toJson(),
      );
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return DiseaseDiagnosisModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to diagnose disease: $e');
    }
  }

  /// Upload leaf image and get disease diagnosis
  Future<DiseaseResultModel> diagnoseCrop({
    required String base64Image,
    required String cropType,
    required String? farmId,
    String? notes,
  }) async {
    try {
      // Backend endpoint: POST /api/v1/disease-diagnosis/diagnose
      // Accepts: { imageBase64, cropHint, farmId, language }
      final response = await _dioClient.post(
        ApiEndpoints.diagnose,
        data: {
          'imageBase64': base64Image,
          'cropHint': cropType,
          if (farmId != null) 'farmId': farmId,
          if (notes != null) 'notes': notes,
          'language': 'am', // default Amharic; caller can override
        },
      );
      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return DiseaseResultModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to diagnose disease: $e');
    }
  }

  /// Get diagnosis history
  Future<List<DiseaseResultModel>> getDiagnosisHistory({
    String? farmId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.diseaseDiagnosis}/history',
        queryParameters: {
          if (farmId != null) 'farmId': farmId,
          'page': page,
          'limit': limit,
        },
      );

      final rawList = response.data is Map
          ? (response.data['data'] ?? response.data['diagnoses'] ?? []) as List
          : response.data as List;
      return rawList
          .map((json) => DiseaseResultModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch diagnosis history: $e');
    }
  }

  /// Get diagnosis by ID
  Future<DiseaseResultModel> getDiagnosisById(String id) async {
    try {
      final response = await _dioClient.get(
        '${ApiEndpoints.diseaseDiagnosis}/$id',
      );

      final rawData = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return DiseaseResultModel.fromJson(rawData);
    } catch (e) {
      throw Exception('Failed to fetch diagnosis: $e');
    }
  }
}

/// Provider for DiseaseRepository
final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiseaseRepository(dioClient);
});
