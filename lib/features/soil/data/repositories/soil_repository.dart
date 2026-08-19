/// Soil profile repository — IoT sensor telemetry
library soil_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/soil_profile_model.dart';

class SoilRepository {
  final DioClient _dio;
  SoilRepository(this._dio);

  Future<List<SoilProfileModel>> getFarmSoilProfile(String farmId) async {
    final r = await _dio.get(ApiEndpoints.farmSensors(farmId));
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => SoilProfileModel.fromJson(j as Map<String, dynamic>)).toList();
  }
}

final soilRepositoryProvider = Provider<SoilRepository>((ref) {
  return SoilRepository(ref.watch(dioClientProvider));
});
