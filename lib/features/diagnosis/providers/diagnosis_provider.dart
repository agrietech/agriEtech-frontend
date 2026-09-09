import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/diagnosis_models.dart';
import '../repositories/diagnosis_repository.dart';

/// Diagnosis repository provider
final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DiagnosisRepository(dioClient);
});

/// Tracks the timestamp when the diagnoses list was last fetched from live API
final diagnosisLastFetchedProvider = StateProvider<DateTime?>((ref) => null);

/// Live telemetry metadata provider for diagnosis feed
final diagnosisTelemetryMetaProvider = Provider<Map<String, dynamic>>((ref) {
  final lastFetched = ref.watch(diagnosisLastFetchedProvider);
  return {
    'sources': 'Verified Agronomic Diagnostic Engine',
    'engines': [
      'Field Agronomy Engine',
      'Pathology Diagnostic System',
      'Phytosanitary Protocol System',
      'Agronomic Advisory Model',
    ],
    'lastFetched': lastFetched,
    'isLive': true,
  };
});

/// Diagnosis list state notifier
class DiagnosisNotifier extends StateNotifier<AsyncValue<List<DiagnosisModel>>> {
  final DiagnosisRepository _repository;
  final Ref _ref;
  DiagnosisFilters _filters = const DiagnosisFilters();

  DiagnosisNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    fetchDiagnoses();
  }

  /// Fetch all diagnoses
  Future<void> fetchDiagnoses() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<DiagnosisModel> results;
      if (_filters.farmId != null) {
        results = await _repository.getFarmDiagnoses(_filters.farmId!);
      } else {
        results = await _repository.getAllDiagnoses();
      }
      _ref.read(diagnosisLastFetchedProvider.notifier).state = DateTime.now();
      return results;
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
  return DiagnosisNotifier(repository, ref);
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

/// Provider for fetching a single diagnosis record by ID
final singleDiagnosisProvider =
    FutureProvider.family<DiagnosisModel, String>((ref, id) async {
  final repository = ref.watch(diagnosisRepositoryProvider);
  return await repository.getDiagnosisById(id);
});
