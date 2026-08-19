import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/disease_result_model.dart';
import '../../data/repositories/disease_repository.dart';
import '../../../../core/network/dio_client.dart';

final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiseaseRepository(dioClient);
});

final diseaseProviderProvider = StateNotifierProvider<DiseaseNotifier, DiseaseState>((ref) {
  final repository = ref.watch(diseaseRepositoryProvider);
  return DiseaseNotifier(repository);
});

class DiseaseState {
  final List<DiseaseResultModel> history;
  final DiseaseResultModel? currentDiagnosis;
  final bool isLoading;
  final String? error;

  DiseaseState({
    this.history = const [],
    this.currentDiagnosis,
    this.isLoading = false,
    this.error,
  });

  DiseaseState copyWith({
    List<DiseaseResultModel>? history,
    DiseaseResultModel? currentDiagnosis,
    bool? isLoading,
    String? error,
  }) {
    return DiseaseState(
      history: history ?? this.history,
      currentDiagnosis: currentDiagnosis ?? this.currentDiagnosis,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DiseaseNotifier extends StateNotifier<DiseaseState> {
  final DiseaseRepository _repository;

  DiseaseNotifier(this._repository) : super(DiseaseState());

  Future<DiseaseResultModel> diagnosePlant({
    required String base64Image,
    required String cropType,
    String? farmId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.diagnoseCrop(
        base64Image: base64Image,
        cropType: cropType,
        farmId: farmId,
        notes: notes,
      );

      state = state.copyWith(
        currentDiagnosis: result,
        isLoading: false,
        history: [result, ...state.history],
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> loadHistory({String? farmId, int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await _repository.getDiagnosisHistory(
        farmId: farmId,
        page: page,
      );

      state = state.copyWith(
        history: page == 1 ? history : [...state.history, ...history],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDiagnosisById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final diagnosis = await _repository.getDiagnosisById(id);
      state = state.copyWith(
        currentDiagnosis: diagnosis,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
