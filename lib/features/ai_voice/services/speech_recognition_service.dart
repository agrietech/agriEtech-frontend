import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/utils/logger.dart';

/// Real-time speech recognition service for EthioFarm AI
/// Translates voice input into text in real-time with Amharic and English recognition.
class SpeechRecognitionService {
  static final SpeechRecognitionService instance = SpeechRecognitionService._();
  SpeechRecognitionService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _hasPermission = false;
  String? _currentLocaleId;

  bool get isInitialized => _isInitialized;
  bool get isListening => _speech.isListening;
  bool get hasPermission => _hasPermission;
  String? get currentLocaleId => _currentLocaleId;

  /// Initialize speech engine and verify permissions
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(dynamic error)? onError,
  }) async {
    if (_isInitialized) return true;

    try {
      // 1. Request microphone permission
      final micStatus = await Permission.microphone.request();
      _hasPermission = micStatus.isGranted;

      if (!_hasPermission) {
        AppLogger.warning('Microphone permission denied for EthioFarm AI');
        return false;
      }

      // 2. Initialize speech_to_text
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          AppLogger.info('STT status: $status');
          onStatus?.call(status);
        },
        onError: (errorNotification) {
          AppLogger.warning('STT error: ${errorNotification.errorMsg}');
          onError?.call(errorNotification);
        },
        debugLogging: kDebugMode,
      );

      if (_isInitialized) {
        final locales = await _speech.locales();
        AppLogger.info('STT initialized with ${locales.length} available locales');
      }

      return _isInitialized;
    } catch (e) {
      AppLogger.warning('STT initialization notice (platform fallback active): $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Start real-time speech recognition
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    Function(double soundLevel)? onSoundLevelChange,
    String languageCode = 'am', // 'am' or 'en'
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    try {
      if (_speech.isListening) {
        await _speech.stop();
      }

      // Select matching locale if supported
      final locales = await _speech.locales();
      stt.LocaleName? targetLocale;

      if (languageCode == 'am') {
        targetLocale = locales.cast<stt.LocaleName?>().firstWhere(
              (l) => l?.localeId.toLowerCase().startsWith('am') ?? false,
              orElse: () => null,
            );
      } else {
        targetLocale = locales.cast<stt.LocaleName?>().firstWhere(
              (l) => l?.localeId.toLowerCase().startsWith('en') ?? false,
              orElse: () => null,
            );
      }

      _currentLocaleId = targetLocale?.localeId ?? (languageCode == 'am' ? 'am_ET' : 'en_US');

      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
        },
        onSoundLevelChange: onSoundLevelChange,
        listenOptions: stt.SpeechListenOptions(
          localeId: _currentLocaleId,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: false,
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );

      return true;
    } catch (e) {
      AppLogger.warning('Speech listen start error: $e');
      return false;
    }
  }

  /// Stop listening and finalize transcription
  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (e) {
      AppLogger.warning('Speech stop error: $e');
    }
  }

  /// Cancel current listening session
  Future<void> cancelListening() async {
    try {
      if (_speech.isListening) {
        await _speech.cancel();
      }
    } catch (e) {
      AppLogger.warning('Speech cancel error: $e');
    }
  }
}
