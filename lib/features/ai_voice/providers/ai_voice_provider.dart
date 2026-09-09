import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ai_voice_repository.dart';
import '../services/speech_recognition_service.dart';
import '../services/voice_synthesis_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final AiVoiceResponse? aiResponse;
  final DateTime timestamp;
  final bool isError;
  final String? failedQuestion;
  final String? displayedLanguage; // 'am' or 'en'

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    this.aiResponse,
    DateTime? timestamp,
    this.isError = false,
    this.failedQuestion,
    this.displayedLanguage,
  })  : id = id ?? 'msg_${DateTime.now().microsecondsSinceEpoch}',
        timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    AiVoiceResponse? aiResponse,
    DateTime? timestamp,
    bool? isError,
    String? failedQuestion,
    String? displayedLanguage,
  }) =>
      ChatMessage(
        id: id ?? this.id,
        text: text ?? this.text,
        isUser: isUser ?? this.isUser,
        aiResponse: aiResponse ?? this.aiResponse,
        timestamp: timestamp ?? this.timestamp,
        isError: isError ?? this.isError,
        failedQuestion: failedQuestion ?? this.failedQuestion,
        displayedLanguage: displayedLanguage ?? this.displayedLanguage,
      );
}

class AiVoiceState {
  final bool isLoading;
  final bool isRecording;
  final String liveTranscript;
  final double soundLevel;
  final bool isSpeaking;
  final String? currentlyPlayingMessageId;
  final List<ChatMessage> messages;
  final AiVoiceResponse? lastResponse;
  final String? error;
  final String language; // 'am' or 'en'
  final bool autoSpeak;
  final bool isVoiceMode; // true = large voice orb/waves, false = chat feed

  const AiVoiceState({
    this.isLoading = false,
    this.isRecording = false,
    this.liveTranscript = '',
    this.soundLevel = 0.0,
    this.isSpeaking = false,
    this.currentlyPlayingMessageId,
    this.messages = const [],
    this.lastResponse,
    this.error,
    this.language = 'am',
    this.autoSpeak = true,
    this.isVoiceMode = false,
  });

  AiVoiceState copyWith({
    bool? isLoading,
    bool? isRecording,
    String? liveTranscript,
    double? soundLevel,
    bool? isSpeaking,
    String? currentlyPlayingMessageId,
    bool clearPlayingId = false,
    List<ChatMessage>? messages,
    AiVoiceResponse? lastResponse,
    String? error,
    bool clearError = false,
    String? language,
    bool? autoSpeak,
    bool? isVoiceMode,
  }) =>
      AiVoiceState(
        isLoading: isLoading ?? this.isLoading,
        isRecording: isRecording ?? this.isRecording,
        liveTranscript: liveTranscript ?? this.liveTranscript,
        soundLevel: soundLevel ?? this.soundLevel,
        isSpeaking: isSpeaking ?? this.isSpeaking,
        currentlyPlayingMessageId: clearPlayingId
            ? null
            : (currentlyPlayingMessageId ?? this.currentlyPlayingMessageId),
        messages: messages ?? this.messages,
        lastResponse: lastResponse ?? this.lastResponse,
        error: clearError ? null : (error ?? this.error),
        language: language ?? this.language,
        autoSpeak: autoSpeak ?? this.autoSpeak,
        isVoiceMode: isVoiceMode ?? this.isVoiceMode,
      );
}

class AiVoiceNotifier extends StateNotifier<AiVoiceState> {
  final AiVoiceRepository _repo;
  final SpeechRecognitionService _speech = SpeechRecognitionService.instance;
  final VoiceSynthesisService _tts = VoiceSynthesisService.instance;

  AiVoiceNotifier(this._repo) : super(const AiVoiceState());

  void setLanguage(String lang) => state = state.copyWith(language: lang);

  void toggleVoiceMode() =>
      state = state.copyWith(isVoiceMode: !state.isVoiceMode);

  void setAutoSpeak(bool autoSpeak) =>
      state = state.copyWith(autoSpeak: autoSpeak);

  void clearMessages() {
    _tts.stop();
    state = state.copyWith(
      messages: const [],
      clearError: true,
      clearPlayingId: true,
      isSpeaking: false,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  /// Dynamically toggle an individual message's displayed language between Amharic and English
  void toggleMessageLanguage(String messageId) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == messageId && m.aiResponse != null) {
          final current = m.displayedLanguage ?? state.language;
          final next = current == 'am' ? 'en' : 'am';
          final newText = next == 'am'
              ? (m.aiResponse!.responseAm.isNotEmpty
                  ? m.aiResponse!.responseAm
                  : m.aiResponse!.responseEn)
              : (m.aiResponse!.responseEn.isNotEmpty
                  ? m.aiResponse!.responseEn
                  : m.aiResponse!.responseAm);
          return m.copyWith(displayedLanguage: next, text: newText);
        }
        return m;
      }).toList(),
    );
  }

  /// Start microphone listening with real-time speech-to-text
  Future<bool> startVoiceRecording() async {
    _tts.stop();
    state = state.copyWith(
      isRecording: true,
      liveTranscript: '',
      soundLevel: 0.0,
      clearError: true,
      isSpeaking: false,
      clearPlayingId: true,
    );

    final started = await _speech.startListening(
      languageCode: state.language,
      onResult: (recognizedWords, isFinal) {
        state = state.copyWith(liveTranscript: recognizedWords);
        if (isFinal && recognizedWords.trim().isNotEmpty) {
          stopVoiceRecordingAndSubmit();
        }
      },
      onSoundLevelChange: (level) {
        state = state.copyWith(soundLevel: level);
      },
    );

    if (!started) {
      state = state.copyWith(
        isRecording: false,
        error: state.language == 'am'
            ? 'የማይክሮፎን ፍቃድ አልተገኘም ወይም መሳሪያዎ የድምፅ መቅረጫ አይደግፍም።'
            : 'Microphone permission not granted or speech recognizer unavailable.',
      );
    }
    return started;
  }

  /// Stop listening and immediately submit transcribed speech as AI inquiry
  Future<void> stopVoiceRecordingAndSubmit() async {
    if (!state.isRecording) return;

    await _speech.stopListening();
    final transcript = state.liveTranscript.trim();

    state = state.copyWith(
      isRecording: false,
      soundLevel: 0.0,
    );

    if (transcript.isNotEmpty) {
      await askText(transcript);
    }
  }

  /// Cancel listening without submitting
  Future<void> cancelVoiceRecording() async {
    await _speech.cancelListening();
    state = state.copyWith(
      isRecording: false,
      liveTranscript: '',
      soundLevel: 0.0,
    );
  }

  /// Submit question in text or transcribed format
  Future<void> sendQuestion(String question) => askText(question);

  Future<void> retryQuestion(String question) async {
    if (state.messages.isNotEmpty && state.messages.last.isError) {
      final trimmed = List<ChatMessage>.from(state.messages)..removeLast();
      if (trimmed.isNotEmpty &&
          trimmed.last.isUser &&
          trimmed.last.text == question) {
        trimmed.removeLast();
      }
      state = state.copyWith(messages: trimmed, clearError: true);
    }
    await askText(question);
  }

  Future<void> askText(String question) async {
    final cleanQ = question.trim();
    if (cleanQ.isEmpty) return;

    final userMsg = ChatMessage(text: cleanQ, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      messages: updatedMessages,
      liveTranscript: '',
    );

    try {
      final res = await _repo.askTextQuestion(
        question: cleanQ,
        language: state.language,
      );

      final responseText = res.localizedResponse(state.language);
      final aiMsg = ChatMessage(
        text: responseText,
        isUser: false,
        aiResponse: res,
        displayedLanguage: state.language,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(
        isLoading: false,
        lastResponse: res,
        messages: finalMessages,
        clearError: true,
      );

      // Auto-speak response if enabled
      if (state.autoSpeak) {
        speakResponse(aiMsg, targetLang: state.language);
      }
    } catch (e) {
      final isAm = state.language == 'am';
      final errorMsg = isAm
          ? 'የቀጥታ AI የግብርና አገልግሎትን ማግኘት አልተቻለም። እባክዎ የበይነመረብ ግንኙነትዎን ያረጋግጡና እንደገና ይሞክሩ።'
          : 'Live AI agronomic advisory unreachable. Please verify internet connection and retry.';

      final errChatMsg = ChatMessage(
        text: errorMsg,
        isUser: false,
        isError: true,
        failedQuestion: cleanQ,
        displayedLanguage: state.language,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(errChatMsg);
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
        messages: finalMessages,
      );
    }
  }

  /// Submit an audio file to backend
  Future<void> submitAudio(File audioFile) async {
    const questionText = 'Voice Query Audio';
    final userMsg = ChatMessage(text: questionText, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      messages: updatedMessages,
    );

    try {
      final res = await _repo.submitVoiceAudio(
        audioFile: audioFile,
        language: state.language,
      );

      final aiMsg = ChatMessage(
        text: res.localizedResponse(state.language),
        isUser: false,
        aiResponse: res,
        displayedLanguage: state.language,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(
        isLoading: false,
        lastResponse: res,
        messages: finalMessages,
        clearError: true,
      );

      if (state.autoSpeak) {
        speakResponse(aiMsg, targetLang: state.language);
      }
    } catch (e) {
      final isAm = state.language == 'am';
      final errorMsg = isAm
          ? 'የቀጥታ የድምፅ ጥያቄን ማስተናገድ አልተቻለም። እባክዎ የበይነመረብ ግንኙነትዎን ፈትሸው እንደገና ይሞክሩ።'
          : 'Live voice advisory processing failed. Please verify connection and retry.';

      final errChatMsg = ChatMessage(
        text: errorMsg,
        isUser: false,
        isError: true,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(errChatMsg);
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
        messages: finalMessages,
      );
    }
  }

  /// Speak or pause a specific chat message
  Future<void> speakResponse(ChatMessage message, {String? targetLang}) async {
    if (state.isSpeaking && state.currentlyPlayingMessageId == message.id) {
      await stopSpeaking();
      return;
    }

    final lang = targetLang ?? state.language;
    final textToSpeak = message.aiResponse != null
        ? (lang == 'am'
            ? (message.aiResponse!.responseAm.isNotEmpty
                ? message.aiResponse!.responseAm
                : message.aiResponse!.responseEn)
            : (message.aiResponse!.responseEn.isNotEmpty
                ? message.aiResponse!.responseEn
                : message.aiResponse!.responseAm))
        : message.text;

    final audioUrl = lang == 'am'
        ? message.aiResponse?.audioUrlAm
        : message.aiResponse?.audioUrlEn;

    state = state.copyWith(
      isSpeaking: true,
      currentlyPlayingMessageId: message.id,
    );

    await _tts.speak(
      text: textToSpeak,
      audioUrl: audioUrl,
      languageCode: lang,
      messageId: message.id,
      onStart: () {
        state = state.copyWith(
          isSpeaking: true,
          currentlyPlayingMessageId: message.id,
        );
      },
      onComplete: () {
        state = state.copyWith(
          isSpeaking: false,
          clearPlayingId: true,
        );
      },
      onError: (err) {
        state = state.copyWith(
          isSpeaking: false,
          clearPlayingId: true,
        );
      },
    );
  }

  /// Stop currently active audio replay
  Future<void> stopSpeaking() async {
    await _tts.stop();
    state = state.copyWith(
      isSpeaking: false,
      clearPlayingId: true,
    );
  }

  void clear() {
    _tts.stop();
    _speech.cancelListening();
    state = const AiVoiceState();
  }
}

final aiVoiceProvider =
    StateNotifierProvider<AiVoiceNotifier, AiVoiceState>((ref) {
  return AiVoiceNotifier(ref.watch(aiVoiceRepositoryProvider));
});
