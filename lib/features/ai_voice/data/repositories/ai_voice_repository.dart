import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/logger.dart';

/// Repository for bilingual AI voice inquiries (Amharic & English)
/// Connects to backend: /api/v1/ai/voice-inquiry and /api/v1/ai/text-inquiry
class AiVoiceRepository {
  final DioClient _dioClient;
  AiVoiceRepository(this._dioClient);

  /// Submit a text question and receive bilingual AI agronomic response
  Future<AiVoiceResponse> askTextQuestion({
    required String question,
    String language = 'am',
  }) async {
    try {
      AppLogger.info('AI text inquiry: $question');
      final response = await _dioClient.post(
        ApiEndpoints.aiTextInquiry,
        data: {'question': question, 'language': language},
      );
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return AiVoiceResponse.fromJson(raw);
    } catch (e) {
      throw Exception('Text inquiry failed: $e');
    }
  }

  /// Submit an audio file and receive transcription + bilingual AI response
  Future<AiVoiceResponse> submitVoiceAudio({
    required File audioFile,
    String language = 'am',
  }) async {
    try {
      AppLogger.info('AI voice inquiry: ${audioFile.path}');
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split(Platform.pathSeparator).last,
        ),
        'language': language,
      });
      final response = await _dioClient.post(
        ApiEndpoints.aiVoiceInquiry,
        data: formData,
      );
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return AiVoiceResponse.fromJson(raw);
    } catch (e) {
      throw Exception('Voice inquiry failed: $e');
    }
  }
}

/// Response model matching backend /api/v1/ai/* response payload
class AiVoiceResponse {
  final String? transcript;
  final String responseEn;
  final String responseAm;
  final String? audioUrlEn;
  final String? audioUrlAm;
  final Map<String, dynamic>? metadata;

  AiVoiceResponse({
    this.transcript,
    required this.responseEn,
    required this.responseAm,
    this.audioUrlEn,
    this.audioUrlAm,
    this.metadata,
  });

  factory AiVoiceResponse.fromJson(Map<String, dynamic> json) {
    final responseObj = json['response'];
    final enFromMap = responseObj is Map ? responseObj['en'] : null;
    final amFromMap = responseObj is Map ? responseObj['am'] : null;

    final enVal = json['responseEn'] ?? enFromMap ?? (responseObj is String ? responseObj : '');
    final amVal = json['responseAm'] ?? json['responseAmharic'] ?? amFromMap ?? (responseObj is String ? responseObj : '');

    return AiVoiceResponse(
      transcript: json['transcript'] as String?,
      responseEn: enVal is String ? enVal : (enVal?.toString() ?? ''),
      responseAm: amVal is String ? amVal : (amVal?.toString() ?? ''),
      audioUrlEn: json['audioUrlEn'] as String?,
      audioUrlAm: json['audioUrlAm'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Returns the preferred language response
  String localizedResponse(String lang) =>
      lang == 'am' ? responseAm : responseEn;
}

/// Riverpod provider
final aiVoiceRepositoryProvider = Provider<AiVoiceRepository>((ref) {
  return AiVoiceRepository(ref.watch(dioClientProvider));
});
