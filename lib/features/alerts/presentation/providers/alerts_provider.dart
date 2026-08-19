/// Alerts state management
library alerts_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/alert_model.dart';
import '../../data/repositories/alerts_repository.dart';

class AlertsState {
  final List<AlertModel> alerts;
  final bool isLoading;
  final String? error;
  final String? selectedSeverity;

  const AlertsState({this.alerts = const [], this.isLoading = false, this.error, this.selectedSeverity});

  AlertsState copyWith({List<AlertModel>? alerts, bool? isLoading, String? error, String? selectedSeverity}) =>
      AlertsState(
        alerts: alerts ?? this.alerts, isLoading: isLoading ?? this.isLoading,
        error: error, selectedSeverity: selectedSeverity ?? this.selectedSeverity,
      );
}

class AlertsNotifier extends StateNotifier<AlertsState> {
  final AlertsRepository _repo;
  AlertsNotifier(this._repo) : super(const AlertsState());

  Future<void> loadAlerts({String? severity}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final alerts = await _repo.getAlerts(severity: severity);
      state = state.copyWith(alerts: alerts, isLoading: false, selectedSeverity: severity);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createAlert(Map<String, dynamic> payload) async {
    try {
      final alert = await _repo.createAlert(payload);
      state = state.copyWith(alerts: [alert, ...state.alerts]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertsState>((ref) {
  return AlertsNotifier(ref.watch(alertsRepositoryProvider));
});
