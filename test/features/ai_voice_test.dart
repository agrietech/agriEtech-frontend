import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/features/ai_voice/data/repositories/ai_voice_repository.dart';
import 'package:agrietech/features/ai_voice/presentation/providers/ai_voice_provider.dart';

void main() {
  group('AiVoiceResponse & Language Support Tests', () {
    test('parses bilingual Amharic and English response correctly', () {
      final json = {
        'transcript': 'ጤፍ መቼ ይዘራል?',
        'responseEn': 'Teff should be planted during the main Meher rains in July.',
        'responseAm': 'ጤፍ በዋናው የመኸር ዝናብ በሐምሌ ወር ውስጥ መዘራት አለበት።',
        'audioUrlEn': 'https://api.agrietech.com/audio/en/123.mp3',
        'audioUrlAm': 'https://api.agrietech.com/audio/am/123.mp3',
        'metadata': {'crop': 'teff', 'confidence': 0.96},
      };

      final response = AiVoiceResponse.fromJson(json);

      expect(response.transcript, 'ጤፍ መቼ ይዘራል?');
      expect(response.responseEn, contains('Teff should be planted'));
      expect(response.responseAm, contains('ጤፍ በዋናው የመኸር'));
      expect(response.audioUrlEn, 'https://api.agrietech.com/audio/en/123.mp3');
      expect(response.audioUrlAm, 'https://api.agrietech.com/audio/am/123.mp3');
      expect(response.metadata?['crop'], 'teff');

      // Test language localization helper
      expect(response.localizedResponse('am'), contains('ጤፍ በዋናው'));
      expect(response.localizedResponse('en'), contains('Teff should be planted'));
    });

    test('handles nested or fallback language structures gracefully', () {
      final json = {
        'response': {'en': 'Water crops early in the morning.', 'am': 'ሰብሎችን በማለዳ ያጠጡ።'},
      };

      final response = AiVoiceResponse.fromJson(json);
      expect(response.responseEn, 'Water crops early in the morning.');
      expect(response.responseAm, 'ሰብሎችን በማለዳ ያጠጡ።');
      expect(response.localizedResponse('am'), 'ሰብሎችን በማለዳ ያጠጡ።');
      expect(response.localizedResponse('en'), 'Water crops early in the morning.');
    });

    test('AiVoiceState copyWith and language toggle', () {
      const state = AiVoiceState();
      expect(state.language, 'am');
      expect(state.isLoading, false);

      final englishState = state.copyWith(language: 'en', isLoading: true);
      expect(englishState.language, 'en');
      expect(englishState.isLoading, true);

      final resetState = englishState.copyWith(isLoading: false);
      expect(resetState.language, 'en');
      expect(resetState.isLoading, false);
    });
  });
}
