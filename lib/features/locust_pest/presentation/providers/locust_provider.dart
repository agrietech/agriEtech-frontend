/// Locust pest state management
library locust_provider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/locust_alert_model.dart';
import '../../data/repositories/locust_repository.dart';

class LocustState {
  final LocustAlertModel? alert;
  final bool isLoading;
  final String? error;

  const LocustState({this.alert, this.isLoading = false, this.error});
  LocustState copyWith({LocustAlertModel? alert, bool? isLoading, String? error}) =>
      LocustState(alert: alert ?? this.alert, isLoading: isLoading ?? this.isLoading, error: error);
}

class LocustNotifier extends StateNotifier<LocustState> {
  final LocustRepository _repo;
  LocustNotifier(this._repo) : super(const LocustState());

  Future<void> load(String woredaId) async {
    state = state.copyWith(isLoading: true);
    try { state = state.copyWith(alert: await _repo.getLocustRisk(woredaId), isLoading: false); }
    catch (e) { state = state.copyWith(isLoading: false, error: e.toString()); }
  }
}

final locustProvider = StateNotifierProvider<LocustNotifier, LocustState>((ref) {
  return LocustNotifier(ref.watch(locustRepositoryProvider));
});
