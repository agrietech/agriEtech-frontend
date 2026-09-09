import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/in_app_audio.dart';
import '../../../core/utils/logger.dart';

/// Robust Text-To-Speech Synthesis Service for EthioFarm AI
/// Provides multi-tier audio replay:
/// - Cloud audio proxy streaming (HD natural voice via Google/Backend TTS)
/// - Direct online TTS stream fallback
/// - Native on-device TTS fallback (works 100% offline via FlutterTts)
class VoiceSynthesisService {
  static final VoiceSynthesisService instance = VoiceSynthesisService._();
  VoiceSynthesisService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isNativeTtsInitialized = false;
  bool _isPlaying = false;
  double _speechRate = 0.9;
  String? _currentlyPlayingId;

  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingId => _currentlyPlayingId;

  Future<void> _initNativeTts() async {
    if (_isNativeTtsInitialized) return;
    try {
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentlyPlayingId = null;
      });

      _flutterTts.setErrorHandler((msg) {
        AppLogger.warning('Native TTS error: $msg');
        _isPlaying = false;
        _currentlyPlayingId = null;
      });

      _isNativeTtsInitialized = true;
    } catch (e) {
      AppLogger.warning('Native TTS init warning: $e');
    }
  }

  /// Clean text markers (markdown, links, symbols) so it speaks fluently
  static String cleanTextForSpeech(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll(RegExp(r'[*#_`~>]'), '')
        .replaceAllMapped(RegExp(r'\[([^\]]+)\]\([^)]+\)'), (m) => m.group(1) ?? '')
        .replaceAll(RegExp(r'\n\s*[-•]\s*'), '. ')
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  /// Play response audio with multi-tier fallback
  Future<void> speak({
    required String text,
    String? audioUrl,
    String languageCode = 'am', // 'am' or 'en'
    String? messageId,
    Function()? onStart,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    await stop();

    final cleanText = cleanTextForSpeech(text);
    if (cleanText.isEmpty) {
      onError?.call('Empty text provided for speech replay');
      return;
    }

    _isPlaying = true;
    _currentlyPlayingId = messageId;
    onStart?.call();

    final isAmharic = languageCode == 'am';
    final targetLang = isAmharic ? 'am' : 'en';

    // ── Tier 1: Try Primary Audio Stream (Backend or Provided URL) ──
    final hasAudioUrl = audioUrl != null &&
        audioUrl.trim().isNotEmpty &&
        audioUrl.startsWith('http');

    if (hasAudioUrl) {
      try {
        AppLogger.info('Playing EthioFarm AI cloud voice: $audioUrl');
        await InAppAudioPlayer.instance.playAudioUrl(
          audioUrl,
          onComplete: () {
            _isPlaying = false;
            _currentlyPlayingId = null;
            onComplete?.call();
          },
          onError: (audioErr) async {
            AppLogger.warning('Primary audio stream failed ($audioErr). Trying secondary cloud stream...');
            await _playFallbackStream(
              cleanText,
              targetLang: targetLang,
              onComplete: onComplete,
              onError: onError,
            );
          },
        );
        return;
      } catch (e) {
        AppLogger.warning('InAppAudioPlayer primary error: $e');
      }
    }

    // For Amharic, prioritize cloud streams since Android devices rarely have offline Amharic TTS
    if (isAmharic) {
      await _playFallbackStream(
        cleanText,
        targetLang: 'am',
        onComplete: onComplete,
        onError: onError,
      );
      return;
    }

    // ── Tier 2: Native Device Text-To-Speech (Offline / Direct for English) ──
    await _speakWithNativeTts(
      cleanText,
      languageCode: languageCode,
      onComplete: onComplete,
      onError: onError,
    );
  }

  Future<void> _playFallbackStream(
    String cleanText, {
    required String targetLang,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    final sample = cleanText.length > 250 ? cleanText.substring(0, 250) : cleanText;
    final encoded = Uri.encodeComponent(sample);

    // Direct Google TTS stream (reliable upstream)
    final directGoogleUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&q=$encoded&tl=$targetLang&client=tw-ob';

    try {
      AppLogger.info('Playing fallback direct TTS stream ($targetLang)');
      await InAppAudioPlayer.instance.playAudioUrl(
        directGoogleUrl,
        onComplete: () {
          _isPlaying = false;
          _currentlyPlayingId = null;
          onComplete?.call();
        },
        onError: (err) async {
          AppLogger.warning('Fallback direct TTS stream failed ($err). Trying backend TTS stream...');
          final backendStreamUrl = '${ApiConstants.baseApiUrl}/ai/tts-stream?text=$encoded&lang=$targetLang';
          try {
            await InAppAudioPlayer.instance.playAudioUrl(
              backendStreamUrl,
              onComplete: () {
                _isPlaying = false;
                _currentlyPlayingId = null;
                onComplete?.call();
              },
              onError: (backendErr) async {
                AppLogger.warning('Backend TTS stream failed ($backendErr). Falling back to native device TTS...');
                await _speakWithNativeTts(
                  cleanText,
                  languageCode: targetLang,
                  onComplete: onComplete,
                  onError: onError,
                );
              },
            );
          } catch (_) {
            await _speakWithNativeTts(
              cleanText,
              languageCode: targetLang,
              onComplete: onComplete,
              onError: onError,
            );
          }
        },
      );
    } catch (e) {
      AppLogger.warning('Fallback stream exception: $e. Falling back to native device TTS...');
      await _speakWithNativeTts(
        cleanText,
        languageCode: targetLang,
        onComplete: onComplete,
        onError: onError,
      );
    }
  }

  Future<void> _speakWithNativeTts(
    String cleanText, {
    required String languageCode,
    Function()? onComplete,
    Function(String error)? onError,
  }) async {
    try {
      await _initNativeTts();

      final targetLang = languageCode == 'am' ? 'am-ET' : 'en-US';
      await _flutterTts.setLanguage(targetLang);

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentlyPlayingId = null;
        onComplete?.call();
      });

      final result = await _flutterTts.speak(cleanText);
      if (result == 1) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
        _currentlyPlayingId = null;
        onError?.call('Device TTS playback could not be initiated.');
      }
    } catch (e) {
      _isPlaying = false;
      _currentlyPlayingId = null;
      AppLogger.warning('Native TTS speak error: $e');
      onError?.call(e.toString());
    }
  }

  /// Pause current audio
  Future<void> pause() async {
    try {
      await InAppAudioPlayer.instance.stop();
      if (_isNativeTtsInitialized) {
        await _flutterTts.pause();
      }
      _isPlaying = false;
    } catch (e) {
      AppLogger.warning('Voice pause error: $e');
    }
  }

  /// Stop current audio playback
  Future<void> stop() async {
    try {
      _isPlaying = false;
      _currentlyPlayingId = null;
      await InAppAudioPlayer.instance.stop();
      if (_isNativeTtsInitialized) {
        await _flutterTts.stop();
      }
    } catch (e) {
      AppLogger.warning('Voice stop error: $e');
    }
  }

  /// Adjust speech rate (0.5 to 1.5)
  Future<void> setRate(double rate) async {
    _speechRate = rate.clamp(0.5, 1.5);
    if (_isNativeTtsInitialized) {
      await _flutterTts.setSpeechRate(_speechRate);
    }
  }
}
