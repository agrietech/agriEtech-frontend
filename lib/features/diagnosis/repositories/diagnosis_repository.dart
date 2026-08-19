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

      final response = await _dioClient.post(
        ApiEndpoints.diagnose,
        data: request.toJson(),
      );

      final diagnosis = DiagnosisModel.fromJson(response.data['data']);
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

      final diagnosesList = (response.data['data'] as List)
          .map((json) => DiagnosisModel.fromJson(json))
          .toList();

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

      final diagnosesList = (response.data['data'] as List)
          .map((json) => DiagnosisModel.fromJson(json))
          .toList();

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
