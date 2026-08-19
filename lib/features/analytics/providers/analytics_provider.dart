import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';

/// Analytics data provider
final analyticsDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, period) async {
  final dioClient = ref.watch(dioClientProvider);

  try {
    AppLogger.info('Fetching analytics data', {'period': period});

    // Fetch analytics data from backend
    final response = await dioClient.get(
      '/analytics/dashboard',
      queryParameters: {'period': period},
    );

    // Mock data structure (replace with actual API response)
    final data = {
      'riskTrends': response.data['data']?['riskTrends'] ?? _getMockRiskTrends(),
      'alertFrequency': response.data['data']?['alertFrequency'] ?? _getMockAlertFrequency(),
      'cropDistribution': response.data['data']?['cropDistribution'] ?? _getMockCropDistribution(),
      'regionalBreakdown': response.data['data']?['regionalBreakdown'] ?? _getMockRegionalBreakdown(),
    };

    AppLogger.success('Analytics data fetched');
    return data;
  } catch (e) {
    AppLogger.error('Failed to fetch analytics', e);
    // Return mock data on error for development
    return {
      'riskTrends': _getMockRiskTrends(),
      'alertFrequency': _getMockAlertFrequency(),
      'cropDistribution': _getMockCropDistribution(),
      'regionalBreakdown': _getMockRegionalBreakdown(),
    };
  }
});

// Mock data generators
List<Map<String, dynamic>> _getMockRiskTrends() {
  return List.generate(7, (index) {
    return {
      'date': DateTime.now().subtract(Duration(days: 6 - index)).toIso8601String(),
      'critical': 2 + (index % 3),
      'high': 5 + (index % 4),
      'moderate': 10 + (index % 5),
      'low': 15 + (index % 3),
    };
  });
}

Map<String, int> _getMockAlertFrequency() {
  return {
    'DROUGHT': 15,
    'FLOOD': 8,
    'LOCUST_PEST': 5,
    'VEGETATION_STRESS': 12,
    'FROST': 3,
    'HEAT_STRESS': 7,
  };
}

Map<String, int> _getMockCropDistribution() {
  return {
    'Teff': 120,
    'Wheat': 95,
    'Maize': 85,
    'Barley': 60,
    'Sorghum': 45,
  };
}

Map<String, dynamic> _getMockRegionalBreakdown() {
  return {
    'Oromia': 450,
    'Amhara': 380,
    'SNNPR': 290,
    'Tigray': 210,
  };
}

