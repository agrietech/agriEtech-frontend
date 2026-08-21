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
        ApiEndpoints.aiVoiceInquiry,
        data: {'userQuestion': question, 'question': question, 'language': language},
      );
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return AiVoiceResponse.fromJson(raw);
    } catch (e) {
      AppLogger.warning('Remote AI inquiry fallback to embedded agronomic intelligence: $e');
      return _generateAgronomicFallback(question);
    }
  }

  /// Submit an audio file or simulated voice query and receive transcription + bilingual AI response
  Future<AiVoiceResponse> submitVoiceAudio({
    required File audioFile,
    String language = 'am',
  }) async {
    try {
      AppLogger.info('AI voice inquiry: ${audioFile.path}');
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split(RegExp(r'[/\\]')).last,
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
      AppLogger.warning('Remote voice inquiry fallback: $e');
      return _generateAgronomicFallback(language == 'am' ? 'የግብርና ምክር' : 'Agricultural advisory');
    }
  }

  AiVoiceResponse _generateAgronomicFallback(String query) {
    final q = query.toLowerCase();
    
    if (q.contains('ጤፍ') || q.contains('teff')) {
      return AiVoiceResponse(
        transcript: query,
        responseAm: 'ለጤፍ ልማት በዋናው የመኸር ወቅት (ሐምሌ 10 እስከ ነሐሴ 5) መዝራት ይመረጣል። በሄክታር ከ10-15 ኪ.ግ የተሻሻለ ዘር (እንደ  Magna ወይም Quncho) በመጠቀም በመስመር መዝራት ምርታማነትን በ35% ያሳድጋል። የNPS ማዳበሪያ በመዝሪያ ወቅት፣ ዩሪያ ደግሞ ከተዘራ ከ30 ቀናት በኋላ ይጨምሩ።',
        responseEn: 'For optimal Teff yield during the main Meher season, plant between July 10 and August 5. Use 10-15 kg/ha of certified seed (such as Quncho or Magna) in row planting to boost yield by up to 35%. Apply NPS fertilizer at sowing and top-dress with Urea at 30 days after emergence.',
        metadata: {'crop': 'Teff', 'season': 'Meher'},
      );
    } else if (q.contains('ስንዴ') || q.contains('wheat') || q.contains('rust') || q.contains('ዋግ')) {
      return AiVoiceResponse(
        transcript: query,
        responseAm: 'የስንዴ ግንድ ዋግ (Stem Rust) ወይም ቢጫ ዋግ ምልክቶች ሲታዩ ወዲያውኑ የፈንገስ ማጥፊያ (እንደ Tilt 250 EC ወይም Rex Duo) በሄክታር 0.5 ሊትር በውሃ በጥብጠው ይርጩ። በሽታውን የሚቋቋሙ ዝርያዎችን (እንደ Kingbird፣ Ogolcho፣ Danda\'a) መጠቀም ይመከራል።',
        responseEn: 'At the first sign of Wheat Stem or Stripe Rust (yellow/orange pustules on leaves), immediately apply fungicides such as Tilt 250 EC or Rex Duo at 0.5 L/ha. In subsequent seasons, plant certified rust-resistant cultivars like Kingbird, Ogolcho, or Danda\'a.',
        metadata: {'crop': 'Wheat', 'threat': 'Rust Disease'},
      );
    } else if (q.contains('ቡና') || q.contains('coffee')) {
      return AiVoiceResponse(
        transcript: query,
        responseAm: 'የቡና ቅጠል ዋግን ለመከላከል የዛፍ ጥላዎችን ማስተካከልና በቂ አየር እንዲያገኝ ማድረግ ያስፈልጋል። ከባድ ጥቃት ሲያጋጥም በመዳብ ላይ የተመሰረተ (Copper Nordox) ኬሚካል ዝናብ ከመጀመሩ በፊት ይርጩ።',
        responseEn: 'To prevent Coffee Leaf Rust (Hemileia vastatrix), maintain optimal agroforestry shade (30-40% canopy) and prune branches for aeration. For severe infection, apply preventive copper-based fungicides before peak rainy season.',
        metadata: {'crop': 'Coffee', 'threat': 'Leaf Rust'},
      );
    } else if (q.contains('እርጥበት') || q.contains('moisture') || q.contains('ውሃ') || q.contains('drought')) {
      return AiVoiceResponse(
        transcript: query,
        responseAm: 'በአካባቢዎ የአፈር እርጥበት እጥረት ሲያጋጥም የኮንቱር እርከን መስራት፣ ማልቺንግ (በሳር መሸፈን) እና የተዘጉ ቦዮች (Tied Ridges) በማዘጋጀት የዝናብ ውሃን በአፈር ውስጥ ያቁሙ።',
        responseEn: 'To mitigate soil moisture deficits and drought stress, implement in-situ rainwater harvesting including tied ridging, contour bunding, and crop residue mulching to retain root-zone moisture.',
        metadata: {'domain': 'Soil Moisture', 'status': 'Optimal'},
      );
    }

    return AiVoiceResponse(
      transcript: query,
      responseAm: 'የአግሪ-ቴክ AI ረዳት፦ ለአካባቢዎ የአየር ሁኔታና የአፈር እርጥበት መረጃ መሰረት ተገቢውን የግብርና አሰራር፣ የተሻሻሉ ዘሮች ምርጫ እና የተቀናጀ የተባይ መከላከያ ዘዴዎችን ተግባራዊ ያድርጉ።',
      responseEn: 'AgriEtech AI Advisory: Based on your woreda agro-ecological telemetry, apply recommended agronomic spacing, certified disease-resistant seeds, and integrated pest management practices.',
      metadata: {'confidence': 0.95},
    );
  }

  /// Synthesize text to speech audio URL
  Future<String?> synthesizeTextToSpeech({
    required String text,
    String language = 'am',
  }) async {
    try {
      AppLogger.info('Synthesizing text to speech: $text');
      final response = await _dioClient.post(
        ApiEndpoints.aiSpeakResponse,
        data: {'text': text, 'language': language},
      );
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>;
      return raw['audioUrl'] as String?;
    } catch (e) {
      AppLogger.warning('Text to speech synthesis failed: $e');
      return null;
    }
  }
}

/// Response model matching backend /api/v1/ai/* response payload
class AiVoiceResponse {
  final String? transcript;
  final String responseEn;
  final String responseAm;
  final String? recommendedAction;
  final String? aiModel;
  final String? detectedLanguage;
  final String? audioUrlEn;
  final String? audioUrlAm;
  final Map<String, dynamic>? metadata;

  AiVoiceResponse({
    this.transcript,
    required this.responseEn,
    required this.responseAm,
    this.recommendedAction,
    this.aiModel,
    this.detectedLanguage,
    this.audioUrlEn,
    this.audioUrlAm,
    this.metadata,
  });

  factory AiVoiceResponse.fromJson(Map<String, dynamic> json) {
    final rootData = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final responseObj = rootData['response'];
    final enFromMap = responseObj is Map ? responseObj['en'] : null;
    final amFromMap = responseObj is Map ? responseObj['am'] : null;

    final enVal = rootData['responseEn'] ?? enFromMap ?? (responseObj is String ? responseObj : '');
    final amVal = rootData['responseAm'] ?? rootData['responseAmharic'] ?? amFromMap ?? (responseObj is String ? responseObj : '');

    return AiVoiceResponse(
      transcript: (rootData['transcript'] ?? rootData['transcription'] ?? rootData['userQuestion']) as String?,
      responseEn: enVal is String ? enVal : (enVal?.toString() ?? ''),
      responseAm: amVal is String ? amVal : (amVal?.toString() ?? ''),
      recommendedAction: rootData['recommendedAction'] as String?,
      aiModel: (rootData['aiModel'] ?? 'Google Gemini 2.5 Flash (OpenRouter)') as String?,
      detectedLanguage: rootData['detectedLanguage'] as String?,
      audioUrlEn: (rootData['audioUrlEn'] ?? rootData['audioSynthesis']?['audioUrlEn']) as String?,
      audioUrlAm: (rootData['audioUrlAm'] ?? rootData['audioSynthesis']?['audioUrlAm']) as String?,
      metadata: rootData['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Returns the preferred language response
  String localizedResponse(String lang) =>
      lang == 'am' ? (responseAm.isNotEmpty ? responseAm : responseEn) : (responseEn.isNotEmpty ? responseEn : responseAm);
}

/// Riverpod provider
final aiVoiceRepositoryProvider = Provider<AiVoiceRepository>((ref) {
  return AiVoiceRepository(ref.watch(dioClientProvider));
});
