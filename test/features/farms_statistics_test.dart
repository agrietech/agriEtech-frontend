import 'package:flutter_test/flutter_test.dart';
import 'package:agrietech/core/models/farm_model.dart';
import 'package:agrietech/features/farms/providers/farms_provider.dart';

void main() {
  group('FarmStatistics Calculation', () {
    test('aggregates total area and crop distribution correctly', () {
      final mockFarms = [
        const FarmModel(
          id: '1',
          userId: 'u1',
          farmName: 'Adaa Wheat Farm',
          primaryCrop: 'Wheat',
          areaHectares: 12.5,
          latitude: 8.75,
          longitude: 39.01,
          woredaId: 'w1',
        ),
        const FarmModel(
          id: '2',
          userId: 'u1',
          farmName: 'Bishoftu Teff Farm',
          primaryCrop: 'Teff',
          areaHectares: 8.0,
          latitude: 8.76,
          longitude: 39.02,
          woredaId: 'w1',
        ),
        const FarmModel(
          id: '3',
          userId: 'u1',
          farmName: 'Modjo Wheat Plot',
          primaryCrop: 'Wheat',
          areaHectares: 4.5,
          latitude: 8.60,
          longitude: 39.12,
          woredaId: 'w2',
        ),
      ];

      final totalArea = mockFarms.fold<double>(
        0.0,
        (sum, farm) => sum + farm.areaHectares,
      );

      final cropDistribution = <String, int>{};
      for (final farm in mockFarms) {
        cropDistribution[farm.primaryCrop] =
            (cropDistribution[farm.primaryCrop] ?? 0) + 1;
      }

      final stats = FarmStatistics(
        totalFarms: mockFarms.length,
        totalArea: totalArea,
        farmsAtRisk: 0,
        cropDistribution: cropDistribution,
      );

      expect(stats.totalFarms, equals(3));
      expect(stats.totalArea, equals(25.0));
      expect(stats.cropDistribution['Wheat'], equals(2));
      expect(stats.cropDistribution['Teff'], equals(1));
    });
  });
}
