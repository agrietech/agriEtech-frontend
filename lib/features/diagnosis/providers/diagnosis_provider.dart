import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/diagnosis_models.dart';
import '../repositories/diagnosis_repository.dart';

/// Diagnosis repository provider
final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiagnosisRepository(dioClient);
});

/// Diagnosis list state notifier
class DiagnosisNotifier extends StateNotifier<AsyncValue<List<DiagnosisModel>>> {
  final DiagnosisRepository _repository;
  DiagnosisFilters _filters = const DiagnosisFilters();

  DiagnosisNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchDiagnoses();
  }

  /// Fetch all diagnoses
  Future<void> fetchDiagnoses() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (_filters.farmId != null) {
        return await _repository.getFarmDiagnoses(_filters.farmId!);
      }
      return await _repository.getAllDiagnoses();
    });
  }

  /// Refresh diagnoses
  Future<void> refresh() async {
    await fetchDiagnoses();
  }

  /// Apply filters
  Future<void> applyFilters(DiagnosisFilters filters) async {
    _filters = filters;
    await fetchDiagnoses();
  }

  /// Filter by farm
  Future<void> filterByFarm(String? farmId) async {
    _filters = _filters.copyWith(farmId: farmId);
    await fetchDiagnoses();
  }

  /// Clear filters
  Future<void> clearFilters() async {
    _filters = const DiagnosisFilters();
    await fetchDiagnoses();
  }

  /// Get current filters
  DiagnosisFilters get currentFilters => _filters;
}

/// Diagnosis list provider
final diagnosisListProvider =
    StateNotifierProvider<DiagnosisNotifier, AsyncValue<List<DiagnosisModel>>>(
        (ref) {
  final repository = ref.watch(diagnosisRepositoryProvider);
  return DiagnosisNotifier(repository);
});

/// Diagnosis statistics provider
final diagnosisStatisticsProvider = Provider<DiagnosisStatistics>((ref) {
  final diagnosesAsync = ref.watch(diagnosisListProvider);
  final repository = ref.watch(diagnosisRepositoryProvider);

  return diagnosesAsync.when(
    data: (diagnoses) => repository.calculateStatistics(diagnoses),
    loading: () => const DiagnosisStatistics(),
    error: (_, __) => const DiagnosisStatistics(),
  );
});

/// Successful diagnoses provider
final successfulDiagnosesProvider = Provider<List<DiagnosisModel>>((ref) {
  final diagnosesAsync = ref.watch(diagnosisListProvider);
  return diagnosesAsync.when(
    data: (diagnoses) =>
        diagnoses.where((d) => d.diagnosisStatus == 'SUCCESS').toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Create diagnosis provider
final createDiagnosisProvider =
    FutureProvider.family<DiagnosisModel, CreateDiagnosisRequest>(
  (ref, request) async {
    final repository = ref.watch(diagnosisRepositoryProvider);
    final diagnosis = await repository.createDiagnosis(request);

    // Refresh the diagnosis list after creating
    ref.invalidate(diagnosisListProvider);

    return diagnosis;
  },
);
