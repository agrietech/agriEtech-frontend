import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ai_voice_repository.dart';

class AiVoiceState {
  final bool isLoading;
  final AiVoiceResponse? lastResponse;
  final String? error;
  final String language;

  const AiVoiceState({
    this.isLoading = false,
    this.lastResponse,
    this.error,
    this.language = 'am',
  });

  AiVoiceState copyWith({
    bool? isLoading,
    AiVoiceResponse? lastResponse,
    String? error,
    String? language,
  }) =>
      AiVoiceState(
        isLoading: isLoading ?? this.isLoading,
        lastResponse: lastResponse ?? this.lastResponse,
        error: error,
        language: language ?? this.language,
      );
}

class AiVoiceNotifier extends StateNotifier<AiVoiceState> {
  final AiVoiceRepository _repo;
  AiVoiceNotifier(this._repo) : super(const AiVoiceState());

  void setLanguage(String lang) => state = state.copyWith(language: lang);

  Future<void> askText(String question) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.askTextQuestion(
        question: question, language: state.language,
      );
      state = state.copyWith(isLoading: false, lastResponse: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAudio(File audioFile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.submitVoiceAudio(
        audioFile: audioFile, language: state.language,
      );
      state = state.copyWith(isLoading: false, lastResponse: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() => state = const AiVoiceState();
}

final aiVoiceProvider =
    StateNotifierProvider<AiVoiceNotifier, AiVoiceState>((ref) {
  return AiVoiceNotifier(ref.watch(aiVoiceRepositoryProvider));
});
