import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/features/ai_voice/repositories/ai_voice_repository.dart';
import 'package:EthioFarm/features/ai_voice/providers/ai_voice_provider.dart';
import 'package:EthioFarm/features/ai_voice/services/voice_synthesis_service.dart';

void main() {
  group('EthioFarm AI - Models & Services Unit Tests', () {
    test('AiVoiceResponse deserializes bilingual responses and audio synthesis cleanly', () {
      final json = {
        'data': {
          'userQuestion': 'ስለ ስንዴ ግንድ ዋግ ንገረኝ',
          'transcription': 'ስለ ስንዴ ግንድ ዋግ ንገረኝ',
          'detectedLanguage': 'Amharic',
          'responseAm': 'የስንዴ ግንድ ዋግ በፈንገስ የሚከሰት አደገኛ በሽታ ነው። ቲልት 250 ኢሲ (Tilt 250 EC) ይርጩ።',
          'responseEn': 'Wheat stem rust is a destructive fungal disease. Apply Tilt 250 EC or Rex Duo fungicide.',
          'recommendedAction': 'Inspect leaf undersides and spray fungicide before rains.',
          'aiModel': 'OpenRouter Gemini 2.5 Flash Vision & Voice',
          'isAiOffline': false,
          'audioSynthesis': {
            'audioUrl': 'https://agrietech.onrender.com/api/v1/ai/tts-stream?text=test&lang=am',
            'voiceAmharic': 'am-ET-Standard-A',
          },
          'audioUrlAm': 'https://agrietech.onrender.com/api/v1/ai/tts-stream?text=test&lang=am',
          'audioUrlEn': 'https://agrietech.onrender.com/api/v1/ai/tts-stream?text=test&lang=en',
          'timestamp': '2026-09-09T12:00:00.000Z',
        }
      };

      final res = AiVoiceResponse.fromJson(json);

      expect(res.transcript, equals('ስለ ስንዴ ግንድ ዋግ ንገረኝ'));
      expect(res.responseAm, contains('የስንዴ ግንድ ዋግ'));
      expect(res.responseEn, contains('Wheat stem rust'));
      expect(res.recommendedAction, contains('spray fungicide'));
      expect(res.aiModel, equals('OpenRouter Gemini 2.5 Flash Vision & Voice'));
      expect(res.audioUrlAm, contains('tts-stream'));
      expect(res.audioUrlEn, contains('tts-stream'));
      expect(res.localizedResponse('am'), equals(res.responseAm));
      expect(res.localizedResponse('en'), equals(res.responseEn));
    });

    test('VoiceSynthesisService.cleanTextForSpeech cleans markdown and prepares fluent speech', () {
      const rawMarkdown = '''
### 🌾 Wheat Protection Guidelines
* **Step 1**: Scout fields at dawn.
* **Step 2**: Apply [Tilt 250 EC](https://agrietech.et) immediately.
> Ensure 200L water per hectare.
''';

      final clean = VoiceSynthesisService.cleanTextForSpeech(rawMarkdown);

      expect(clean, isNot(contains('###')));
      expect(clean, isNot(contains('**')));
      expect(clean, isNot(contains('* ')));
      expect(clean, isNot(contains('[')));
      expect(clean, isNot(contains('https://')));
      expect(clean, contains('Wheat Protection Guidelines'));
      expect(clean, contains('Scout fields at dawn'));
      expect(clean, contains('Apply Tilt 250 EC immediately'));
    });

    test('ChatMessage generates unique ids and tracks error states', () {
      final userMsg = ChatMessage(
        text: 'How to cure fall armyworm?',
        isUser: true,
      );
      expect(userMsg.isUser, isTrue);
      expect(userMsg.id, startsWith('msg_'));
      expect(userMsg.isError, isFalse);

      final errorMsg = ChatMessage(
        text: 'Network timeout',
        isUser: false,
        isError: true,
        failedQuestion: 'How to cure fall armyworm?',
      );
      expect(errorMsg.isError, isTrue);
      expect(errorMsg.failedQuestion, equals('How to cure fall armyworm?'));
    });

    test('AiVoiceState copyWith and mode toggling work as expected', () {
      const state = AiVoiceState(
        language: 'am',
        autoSpeak: true,
        isVoiceMode: false,
      );

      final voiceModeState = state.copyWith(isVoiceMode: true, isRecording: true);
      expect(voiceModeState.isVoiceMode, isTrue);
      expect(voiceModeState.isRecording, isTrue);
      expect(voiceModeState.autoSpeak, isTrue);

      final enState = voiceModeState.copyWith(language: 'en', isRecording: false);
      expect(enState.language, equals('en'));
      expect(enState.isRecording, isFalse);
    });

    test('ChatMessage copyWith and toggleMessageLanguage flip between Amharic and English', () {
      final aiRes = AiVoiceResponse(
        responseAm: 'የስንዴ ግንድ ዋግ መከላከያ መመሪያ',
        responseEn: 'Wheat stem rust management protocol',
      );
      final msg = ChatMessage(
        id: 'msg_test_1',
        text: aiRes.responseAm,
        isUser: false,
        aiResponse: aiRes,
        displayedLanguage: 'am',
      );

      expect(msg.displayedLanguage, equals('am'));
      expect(msg.text, equals('የስንዴ ግንድ ዋግ መከላከያ መመሪያ'));

      // Test copyWith
      final toggled = msg.copyWith(
        displayedLanguage: 'en',
        text: aiRes.responseEn,
      );
      expect(toggled.displayedLanguage, equals('en'));
      expect(toggled.text, equals('Wheat stem rust management protocol'));
    });
  });
}
