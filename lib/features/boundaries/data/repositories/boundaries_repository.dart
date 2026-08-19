/// Boundaries repository — fetches Ethiopian admin boundaries from backend
library boundaries_repository;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/region_model.dart';
import '../models/zone_model.dart';
import '../models/woreda_model.dart';

class BoundariesRepository {
  final DioClient _dio;
  BoundariesRepository(this._dio);

  Future<List<RegionModel>> getRegions() async {
    final r = await _dio.get(ApiEndpoints.regions);
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => RegionModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<ZoneModel>> getZones({String? regionId}) async {
    final params = regionId != null ? {'regionId': regionId} : null;
    final r = await _dio.get(ApiEndpoints.zones, queryParameters: params);
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => ZoneModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<WoredaModel>> getWoredas({String? zoneId}) async {
    final params = zoneId != null ? {'zoneId': zoneId} : null;
    final r = await _dio.get(ApiEndpoints.woredas, queryParameters: params);
    final raw = r.data is Map && r.data['data'] != null ? r.data['data'] : r.data;
    return (raw as List).map((j) => WoredaModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<WoredaModel> getWoredaById(String id) async {
    final r = await _dio.get(ApiEndpoints.woredaById(id));
    final raw = r.data is Map && r.data['data'] != null
        ? r.data['data'] as Map<String, dynamic> : r.data as Map<String, dynamic>;
    return WoredaModel.fromJson(raw);
  }
}

final boundariesRepositoryProvider = Provider<BoundariesRepository>((ref) {
  return BoundariesRepository(ref.watch(dioClientProvider));
});
