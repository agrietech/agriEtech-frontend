import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/ai_voice_repository.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final AiVoiceResponse? aiResponse;
  final DateTime timestamp;
  final bool isError;
  final String? failedQuestion;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.aiResponse,
    DateTime? timestamp,
    this.isError = false,
    this.failedQuestion,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiVoiceState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final AiVoiceResponse? lastResponse;
  final String? error;
  final String language;

  const AiVoiceState({
    this.isLoading = false,
    this.messages = const [],
    this.lastResponse,
    this.error,
    this.language = 'am',
  });

  AiVoiceState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    AiVoiceResponse? lastResponse,
    String? error,
    bool clearError = false,
    String? language,
  }) =>
      AiVoiceState(
        isLoading: isLoading ?? this.isLoading,
        messages: messages ?? this.messages,
        lastResponse: lastResponse ?? this.lastResponse,
        error: clearError ? null : (error ?? this.error),
        language: language ?? this.language,
      );
}

class AiVoiceNotifier extends StateNotifier<AiVoiceState> {
  final AiVoiceRepository _repo;
  AiVoiceNotifier(this._repo) : super(const AiVoiceState());

  void setLanguage(String lang) => state = state.copyWith(language: lang);

  void clearMessages() => state = state.copyWith(messages: const [], clearError: true);

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> sendQuestion(String question) => askText(question);

  Future<void> retryQuestion(String question) async {
    // Remove the trailing error message if any
    if (state.messages.isNotEmpty && state.messages.last.isError) {
      final trimmed = List<ChatMessage>.from(state.messages)..removeLast();
      if (trimmed.isNotEmpty && trimmed.last.isUser && trimmed.last.text == question) {
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

    state = state.copyWith(isLoading: true, clearError: true, messages: updatedMessages);

    try {
      final res = await _repo.askTextQuestion(
        question: cleanQ,
        language: state.language,
      );

      final aiMsg = ChatMessage(
        text: res.localizedResponse(state.language),
        isUser: false,
        aiResponse: res,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(
        isLoading: false,
        lastResponse: res,
        messages: finalMessages,
        clearError: true,
      );
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
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(errChatMsg);
      state = state.copyWith(
        isLoading: false,
        error: errorMsg,
        messages: finalMessages,
      );
    }
  }

  Future<void> submitAudio(File audioFile) async {
    const questionText = 'Voice Query Audio';
    final userMsg = ChatMessage(text: questionText, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);

    state = state.copyWith(isLoading: true, clearError: true, messages: updatedMessages);

    try {
      final res = await _repo.submitVoiceAudio(
        audioFile: audioFile,
        language: state.language,
      );

      final aiMsg = ChatMessage(
        text: res.localizedResponse(state.language),
        isUser: false,
        aiResponse: res,
      );

      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(
        isLoading: false,
        lastResponse: res,
        messages: finalMessages,
        clearError: true,
      );
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

  void clear() => state = const AiVoiceState();
}

final aiVoiceProvider =
    StateNotifierProvider<AiVoiceNotifier, AiVoiceState>((ref) {
  return AiVoiceNotifier(ref.watch(aiVoiceRepositoryProvider));
});
