import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/animal_health_models.dart';
import '../repositories/animal_health_repository.dart';

final animalHealthRepositoryProvider = Provider<AnimalHealthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnimalHealthRepository(dioClient);
});

final animalOutbreaksProvider = FutureProvider<List<AnimalOutbreakModel>>((ref) async {
  final repo = ref.watch(animalHealthRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repo.getOutbreaks(woredaId: user?.woredaId);
});

final vaccinationCampaignsProvider = FutureProvider<List<VaccinationCampaignModel>>((ref) async {
  final repo = ref.watch(animalHealthRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repo.getCampaigns(woredaId: user?.woredaId);
});

final pastureConditionProvider = FutureProvider<PastureConditionModel>((ref) async {
  final repo = ref.watch(animalHealthRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return repo.getPastureCondition(woredaId: user?.woredaId);
});
