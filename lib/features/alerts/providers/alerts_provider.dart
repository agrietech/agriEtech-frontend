import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_models.dart';
import '../repositories/alert_repository.dart';

/// Alerts provider
final alertsProvider = FutureProvider<List<AlertModel>>((ref) async {
  final alertRepository = ref.watch(alertRepositoryProvider);
  return await alertRepository.getAlerts(limit: 50);
});

/// Single alert provider
final alertProvider = FutureProvider.family<AlertModel, String>((ref, id) async {
  final alertRepository = ref.watch(alertRepositoryProvider);
  return await alertRepository.getAlertById(id);
});
