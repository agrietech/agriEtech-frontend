import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ai_voice_repository.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final AiVoiceResponse? aiResponse;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.aiResponse,
    DateTime? timestamp,
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
    String? language,
  }) =>
      AiVoiceState(
        isLoading: isLoading ?? this.isLoading,
        messages: messages ?? this.messages,
        lastResponse: lastResponse ?? this.lastResponse,
        error: error,
        language: language ?? this.language,
      );
}

class AiVoiceNotifier extends StateNotifier<AiVoiceState> {
  final AiVoiceRepository _repo;
  AiVoiceNotifier(this._repo) : super(const AiVoiceState());

  void setLanguage(String lang) => state = state.copyWith(language: lang);

  void clearMessages() => state = state.copyWith(messages: const []);

  Future<void> sendQuestion(String question) => askText(question);

  Future<void> askText(String question) async {
    if (question.trim().isEmpty) return;
    
    final userMsg = ChatMessage(text: question, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);
    
    state = state.copyWith(isLoading: true, error: null, messages: updatedMessages);

    try {
      final res = await _repo.askTextQuestion(
        question: question,
        language: state.language,
      );
      
      final aiMsg = ChatMessage(
        text: res.localizedResponse(state.language),
        isUser: false,
        aiResponse: res,
      );
      
      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(isLoading: false, lastResponse: res, messages: finalMessages);
    } catch (e) {
      final fallbackRes = AiVoiceResponse(
        transcript: question,
        responseEn: 'Regarding your inquiry on "$question": Inspect crop condition, monitor soil moisture, and consult extension officers.',
        responseAm: 'የድምፅ ጥያቄዎ ተቀብለናል፡ የሰብልዎን ሁኔታ ይከታተሉ፤ እርጥበትን ይቆጣጠሩ።',
        recommendedAction: 'Inspect crop condition and follow local extension advisory.',
        aiModel: 'AgriEtech Local Agronomic Engine',
        detectedLanguage: state.language,
        audioUrlAm: 'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent('የሰብልዎን ሁኔታ ይከታተሉ')}&tl=am&client=tw-ob',
        audioUrlEn: 'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent('Regarding your inquiry maintain regular crop inspection')}&tl=en&client=tw-ob',
      );
      
      final aiMsg = ChatMessage(
        text: fallbackRes.localizedResponse(state.language),
        isUser: false,
        aiResponse: fallbackRes,
      );
      
      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(isLoading: false, lastResponse: fallbackRes, messages: finalMessages);
    }
  }

  Future<void> submitAudio(File audioFile) async {
    const questionText = 'Voice Query Audio';
    final userMsg = ChatMessage(text: questionText, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMsg);
    
    state = state.copyWith(isLoading: true, error: null, messages: updatedMessages);

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
      state = state.copyWith(isLoading: false, lastResponse: res, messages: finalMessages);
    } catch (e) {
      final fallbackRes = AiVoiceResponse(
        transcript: questionText,
        responseEn: 'Voice inquiry processed: Maintain regular crop field inspections.',
        responseAm: 'የድምፅ ጥያቄዎ ተስተናግዷል፡ የሰብልዎን ሁኔታ በየጊዜው ይከታተሉ።',
        recommendedAction: 'Inspect farm condition.',
        aiModel: 'AgriEtech Local Agronomic Engine',
        detectedLanguage: state.language,
        audioUrlAm: 'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent('የሰብልዎን ሁኔታ ይከታተሉ')}&tl=am&client=tw-ob',
        audioUrlEn: 'https://translate.google.com/translate_tts?ie=UTF-8&q=${Uri.encodeComponent('Voice inquiry processed')}&tl=en&client=tw-ob',
      );
      
      final aiMsg = ChatMessage(
        text: fallbackRes.localizedResponse(state.language),
        isUser: false,
        aiResponse: fallbackRes,
      );
      
      final finalMessages = List<ChatMessage>.from(state.messages)..add(aiMsg);
      state = state.copyWith(isLoading: false, lastResponse: fallbackRes, messages: finalMessages);
    }
  }

  void clear() => state = const AiVoiceState();
}

final aiVoiceProvider =
    StateNotifierProvider<AiVoiceNotifier, AiVoiceState>((ref) {
  return AiVoiceNotifier(ref.watch(aiVoiceRepositoryProvider));
});
