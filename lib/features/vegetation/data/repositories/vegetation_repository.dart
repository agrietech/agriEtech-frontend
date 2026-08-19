/// Vegetation health repository — NDVI from satellite observations
library vegetation_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/ndvi_model.dart';

class VegetationRepository {
  final DioClient _dio;
  VegetationRepository(this._dio);

  Future<List<NdviModel>> getNdviSeries(String woredaId, {String timeframe = 'MONTHLY'}) async {
    final r = await _dio.get(ApiEndpoints.satelliteObservations, queryParameters: {
      'woredaId': woredaId, 'source': 'MODIS', 'timeframe': timeframe,
    });
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => NdviModel.fromJson(j as Map<String, dynamic>)).toList();
  }
}

final vegetationRepositoryProvider = Provider<VegetationRepository>((ref) {
  return VegetationRepository(ref.watch(dioClientProvider));
});
