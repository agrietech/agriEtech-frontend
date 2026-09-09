import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:EthioFarm/features/dashboard/models/dashboard_models.dart';
import 'package:EthioFarm/features/dashboard/widgets/dashboard_trend_chart.dart';
import 'package:EthioFarm/features/dashboard/widgets/crop_distribution_card.dart';

void main() {
  group('Dashboard Models Standardization Suite', () {
    test('DashboardData.fromJson correctly parses telemetry and jurisdiction metrics from backend', () {
      final backendPayload = {
        'totalFarmsRegistered': 18,
        'activeSensors': 12,
        'totalSensors': 14,
        'monitoredWoredas': 1148,
        'activeEarlyWarnings': 3,
        'nationalSeasonVigor': {
          'averageNdvi': 0.72,
          'condition': 'NORMAL_TO_FAVORABLE',
          'belgStatus': 'FAVORABLE',
        },
        'compositeRiskDistribution': {
          'greenCount': 1120,
          'yellowCount': 18,
          'orangeCount': 8,
          'redCount': 2,
        },
        'recentAlerts': [
          {
            'id': 'alt_99',
            'titleEn': 'Meher Moisture Deficit Alert',
            'messageEn': 'Immediate moisture deficit observed in lowlands.',
            'severity': 'HIGH',
            'hazardType': 'DROUGHT',
            'isRead': false,
            'woreda': {
              'id': 'wor_adama',
              'nameEn': 'Adama Rural',
              'zone': {
                'id': 'zone_east_shewa',
                'nameEn': 'East Shewa',
                'region': {
                  'id': 'reg_oromia',
                  'nameEn': 'Oromia',
                },
              },
            },
            'createdAt': '2026-09-09T10:00:00.000Z',
          }
        ],
        'weatherSummary': {
          'current': {
            'temperature': 24.2,
            'humidity': 58.0,
            'rainfall': 1.5,
            'windSpeed': 12.0,
            'condition': 'Partly Cloudy',
          },
          'forecast': [
            {'date': '2026-09-09T00:00:00.000Z', 'tempMax': 26.0, 'tempMin': 14.0, 'rainfall': 2.0, 'humidity': 55.0, 'condition': 'Showers'},
            {'date': '2026-09-10T00:00:00.000Z', 'tempMax': 27.0, 'tempMin': 15.0, 'rainfall': 0.0, 'humidity': 50.0, 'condition': 'Sunny'},
          ],
        },
        'farmSummary': {
          'totalFarms': 18,
          'totalArea': 34.5,
          'farmsAtRisk': 3,
          'activeSensors': 12,
          'cropDistribution': {
            'WHEAT': 8,
            'TEFF': 5,
            'MAIZE': 3,
            'BARLEY': 2,
          },
        },
        'telemetry': {
          'averageNdvi': 0.72,
          'soilMoisture': 41.2,
          'droughtRisk': 'LOW',
          'status': 'HEALTHY',
          'lastObservedAt': '2026-09-09T08:00:00.000Z',
        },
        'jurisdictionMetrics': {
          'totalFarmers': 35,
          'farmsAtRisk': 3,
          'fieldVisitsThisWeek': 8,
          'monitoredHectares': 34.5,
          'activeSensors': 12,
          'satelliteObservationsCount': 1560,
        },
        'systemHealth': {
          'status': 'OPERATIONAL',
          'activeUsers': 42,
          'dataPointsToday': 380,
          'apiHealthy': true,
        },
      };

      final data = DashboardData.fromJson(backendPayload);

      // Verify Telemetry
      expect(data.telemetry.averageNdvi, 0.72);
      expect(data.telemetry.soilMoisture, 41.2);
      expect(data.telemetry.droughtRisk, 'LOW');
      expect(data.telemetry.status, 'HEALTHY');

      // Verify Jurisdiction Metrics (eliminates dashes)
      expect(data.jurisdictionMetrics.totalFarmers, 35);
      expect(data.jurisdictionMetrics.farmsAtRisk, 3);
      expect(data.jurisdictionMetrics.fieldVisitsThisWeek, 8);
      expect(data.jurisdictionMetrics.monitoredHectares, 34.5);
      expect(data.jurisdictionMetrics.activeSensors, 12);
      expect(data.jurisdictionMetrics.satelliteObservationsCount, 1560);

      // Verify Nested Relation Alert Parsing
      expect(data.recentAlerts.length, 1);
      final alert = data.recentAlerts.first;
      expect(alert.id, 'alt_99');
      expect(alert.title, 'Meher Moisture Deficit Alert');
      expect(alert.woredaName, 'Adama Rural');
      expect(alert.zoneName, 'East Shewa');
      expect(alert.regionName, 'Oromia');
      expect(alert.severity, 'HIGH');

      // Verify Risk Summary
      expect(data.riskSummary.lowRisk, 1120);
      expect(data.riskSummary.highRisk, 8);
      expect(data.riskSummary.criticalRisk, 2);

      // Verify Crop Distribution
      expect(data.farmSummary.cropDistribution!['WHEAT'], 8);
      expect(data.farmSummary.cropDistribution!['TEFF'], 5);
    });

    test('DashboardTelemetry provides default values safely when empty', () {
      const telemetry = DashboardTelemetry();
      expect(telemetry.averageNdvi, 0.68);
      expect(telemetry.soilMoisture, 38.5);
      expect(telemetry.droughtRisk, 'LOW');
      expect(telemetry.status, 'HEALTHY');
    });

    test('JurisdictionMetrics provides zero defaults safely when empty', () {
      const metrics = JurisdictionMetrics();
      expect(metrics.totalFarmers, 0);
      expect(metrics.farmsAtRisk, 0);
      expect(metrics.fieldVisitsThisWeek, 0);
      expect(metrics.monitoredHectares, 0.0);
    });
  });

  group('Dashboard Widget Components Suite', () {
    testWidgets('CropDistributionCard renders crop names, counts, and legend pills', (tester) async {
      const farmSummary = FarmSummary(
        totalFarms: 10,
        totalArea: 25.0,
        farmsAtRisk: 1,
        activeSensors: 4,
        cropDistribution: {
          'WHEAT': 5,
          'TEFF': 3,
          'MAIZE': 2,
        },
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CropDistributionCard(farmSummary: farmSummary),
            ),
          ),
        ),
      );

      expect(find.text('Active Crop Distribution'), findsOneWidget);
      expect(find.textContaining('3 primary varieties across 10 registered farm plots'), findsOneWidget);
      expect(find.text('Wheat (ስንዴ)'), findsOneWidget);
      expect(find.text('Teff (ጤፍ)'), findsOneWidget);
      expect(find.text('Maize (በቆሎ)'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('DashboardTrendChart renders toggle pills and canvas without error', (tester) async {
      final dummyData = DashboardData(
        riskSummary: const RiskSummary(totalWoredas: 10, lowRisk: 8, moderateRisk: 2),
        recentAlerts: const [],
        weatherSummary: WeatherSummary(
          current: const CurrentWeather(temperature: 23.0, humidity: 60.0, rainfall: 2.0),
          forecast: [
            DailyForecast(date: DateTime.now(), tempMax: 25.0, tempMin: 14.0, rainfall: 3.5),
            DailyForecast(date: DateTime.now().add(const Duration(days: 1)), tempMax: 26.0, tempMin: 15.0, rainfall: 0.0),
            DailyForecast(date: DateTime.now().add(const Duration(days: 2)), tempMax: 24.0, tempMin: 13.0, rainfall: 1.2),
          ],
        ),
        farmSummary: const FarmSummary(totalFarms: 5, totalArea: 10.0),
        systemHealth: const SystemHealth(status: 'OPERATIONAL'),
        telemetry: const DashboardTelemetry(averageNdvi: 0.74, soilMoisture: 42.0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardTrendChart(dashboardData: dummyData),
            ),
          ),
        ),
      );

      expect(find.text('7-Day Agronomic Trends'), findsOneWidget);
      expect(find.text('Rainfall (mm)'), findsOneWidget);
      expect(find.text('NDVI Health'), findsOneWidget);
      expect(find.text('Soil Moisture (%)'), findsOneWidget);

      // Tap NDVI tab
      await tester.tap(find.text('NDVI Health'));
      await tester.pumpAndSettle();

      // Tap Soil Moisture tab
      await tester.tap(find.text('Soil Moisture (%)'));
      await tester.pumpAndSettle();
    });
  });
}
