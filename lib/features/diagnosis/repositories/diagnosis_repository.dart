import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/error/app_error.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';
import '../models/diagnosis_models.dart';

class DiagnosisRepository {
  final DioClient _dioClient;

  DiagnosisRepository(this._dioClient);

  /// Create a new diagnosis
  Future<DiagnosisModel> createDiagnosis(CreateDiagnosisRequest request) async {
    try {
      AppLogger.info('Creating diagnosis', {
        'farmId': request.farmId,
        'cropType': request.cropType,
      });

      Response response;
      try {
        if (request.imageBytes != null && request.imageBytes!.isNotEmpty) {
          response = await _dioClient.uploadBytes(
            ApiEndpoints.diagnose,
            request.imageBytes!,
            fileName: 'plantscan_${DateTime.now().millisecondsSinceEpoch}.jpg',
            fieldName: 'image',
            data: {
              'farmId': request.farmId,
              if (request.cropType != null) 'cropType': request.cropType,
              'language': request.language,
            },
          );
        } else if (request.imagePath != null && request.imagePath!.isNotEmpty) {
          response = await _dioClient.uploadFile(
            ApiEndpoints.diagnose,
            request.imagePath!,
            fieldName: 'image',
            data: {
              'farmId': request.farmId,
              if (request.cropType != null) 'cropType': request.cropType,
              'language': request.language,
            },
          );
        } else {
          response = await _dioClient.post(
            ApiEndpoints.diagnose,
            data: request.toJson(),
          );
        }
      } catch (uploadError) {
        AppLogger.warning('Multipart upload failed, falling back to JSON base64 upload', uploadError);
        response = await _dioClient.post(
          ApiEndpoints.diagnose,
          data: {
            'farmId': request.farmId,
            if (request.imageBase64.isNotEmpty) 'imageBase64': request.imageBase64,
            if (request.imageBase64.isNotEmpty) 'image': 'data:image/jpeg;base64,${request.imageBase64}',
            if (request.cropType != null) 'cropType': request.cropType,
            'language': request.language,
          },
        );
      }

      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      final map = Map<String, dynamic>.from(raw);
      map['imageUrl'] = map['imageUrl'] ?? map['image'] ?? '';
      map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
      map['farmId'] = map['farmId'] ?? request.farmId;
      final diagnosis = DiagnosisModel.fromJson(map);
      AppLogger.success('Diagnosis created successfully', {'diagnosisId': diagnosis.id});
      return diagnosis;
    } on DioException catch (e) {
      AppLogger.error('Failed to create diagnosis', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error creating diagnosis', e);
      throw const UnknownError(
        message: 'Failed to create diagnosis',
      );
    }
  }

  /// Get diagnoses for a specific farm
  Future<List<DiagnosisModel>> getFarmDiagnoses(String farmId) async {
    try {
      AppLogger.info('Fetching diagnoses for farm', {'farmId': farmId});

      final response = await _dioClient.get(
        ApiEndpoints.farmDiagnoses(farmId),
      );

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final diagnosesList = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['imageUrl'] = map['imageUrl'] ?? map['image'] ?? '';
        map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
        map['farmId'] = map['farmId'] ?? farmId;
        return DiagnosisModel.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${diagnosesList.length} diagnoses');
      return diagnosesList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch diagnoses', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching diagnoses', e);
      throw const UnknownError(
        message: 'Failed to fetch diagnoses',
      );
    }
  }

  /// Get all diagnoses
  Future<List<DiagnosisModel>> getAllDiagnoses() async {
    try {
      AppLogger.info('Fetching all diagnoses');

      final response = await _dioClient.get(ApiEndpoints.diseaseDiagnosis);

      final raw = response.data is Map ? (response.data['data'] ?? response.data) : response.data;
      final list = raw is List ? raw : [];

      final diagnosesList = list.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        map['imageUrl'] = map['imageUrl'] ?? map['image'] ?? '';
        map['createdAt'] = map['createdAt'] ?? DateTime.now().toIso8601String();
        map['farmId'] = map['farmId'] ?? '';
        return DiagnosisModel.fromJson(map);
      }).toList();

      AppLogger.success('Fetched ${diagnosesList.length} diagnoses');
      return diagnosesList;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch diagnoses', e);
      throw ErrorHandler.handleError(e);
    } catch (e) {
      AppLogger.error('Unexpected error fetching diagnoses', e);
      throw const UnknownError(
        message: 'Failed to fetch diagnoses',
      );
    }
  }

  /// Calculate diagnosis statistics
  DiagnosisStatistics calculateStatistics(List<DiagnosisModel> diagnoses) {
    int pending = 0;
    int success = 0;
    int failed = 0;

    final byCrop = <String, int>{};
    final byDisease = <String, int>{};

    for (final diagnosis in diagnoses) {
      // Count by status
      switch (diagnosis.diagnosisStatus) {
        case 'PENDING':
          pending++;
          break;
        case 'SUCCESS':
          success++;
          break;
        case 'FAILED':
          failed++;
          break;
      }

      // Count by crop
      if (diagnosis.cropIdentified != null) {
        byCrop[diagnosis.cropIdentified!] =
            (byCrop[diagnosis.cropIdentified!] ?? 0) + 1;
      }

      // Count by disease
      if (diagnosis.diseaseName != null) {
        byDisease[diagnosis.diseaseName!] =
            (byDisease[diagnosis.diseaseName!] ?? 0) + 1;
      }
    }

    return DiagnosisStatistics(
      total: diagnoses.length,
      pending: pending,
      success: success,
      failed: failed,
      byCrop: byCrop,
      byDisease: byDisease,
    );
  }
}
