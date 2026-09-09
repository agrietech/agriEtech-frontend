import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:EthioFarm/features/analytics/models/analytics_model.dart';
import 'package:EthioFarm/features/analytics/repositories/analytics_repository.dart';
import 'package:EthioFarm/features/analytics/providers/analytics_provider.dart';
import 'package:EthioFarm/features/analytics/screens/analytics_screen.dart';
import 'package:EthioFarm/features/auth/providers/auth_provider.dart';
import 'package:EthioFarm/core/models/user_model.dart';
import 'package:EthioFarm/core/network/dio_client.dart';

// Fake DioClient for unit testing repository calls
class FakeDioClient implements DioClient {
  String? lastGetPath;
  Map<String, dynamic>? lastGetQueryParams;
  Options? lastGetOptions;
  dynamic mockGetResponse;

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = false,
    Duration? cacheDuration,
  }) async {
    lastGetPath = path;
    lastGetQueryParams = queryParameters;
    lastGetOptions = options;

    return Response(
      requestOptions: RequestOptions(path: path),
      data: mockGetResponse,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AgronomicAdvisoryDetail Model Tests', () {
    test('Correctly serializes and deserializes multilingual agronomic advisories', () {
      final json = {
        'id': 'adv_test_01',
        'cropType': 'WHEAT',
        'season': 'MEHER',
        'titleEn': 'Moisture Conservation for Wheat',
        'titleAm': '\u1208\u1235\u1295\u12f4 \u12a5\u122d\u1325\u1260\u1275 \u1325\u1260\u1243',
        'titleOm': 'Kunsa Qulqullina Biyyee',
        'actionEn': 'Apply straw mulch on ridges before flowering.',
        'actionAm': '\u1230\u1265\u1209 \u12a8\u121b\u1260\u1261 \u1260\u134a\u1275 \u12e8\u12f0\u1228\u1240 \u1233\u122d \u12ed\u130e\u12dd\u1309\u12da\u1363',
        'actionOm': 'Marga gogaa biyyee irra kaa\'aa.',
        'urgency': 'HIGH',
        'category': 'IRRIGATION',
      };

      final model = AgronomicAdvisoryDetail.fromJson(json);

      expect(model.id, 'adv_test_01');
      expect(model.cropType, 'WHEAT');
      expect(model.urgency, 'HIGH');
      expect(model.category, 'IRRIGATION');

      // Localized Title resolution
      expect(model.localizedTitle('am'), '\u1208\u1235\u1295\u12f4 \u12a5\u122d\u1325\u1260\u1275 \u1325\u1260\u1243');
      expect(model.localizedTitle('om'), 'Kunsa Qulqullina Biyyee');
      expect(model.localizedTitle('en'), 'Moisture Conservation for Wheat');

      // Localized Action resolution
      expect(model.localizedAction('am'), '\u1230\u1265\u1209 \u12a8\u121b\u1260\u1261 \u1260\u134a\u1275 \u12e8\u12f0\u1228\u1240 \u1233\u122d \u12ed\u130e\u12dd\u1309\u12da\u1363');
      expect(model.localizedAction('om'), 'Marga gogaa biyyee irra kaa\'aa.');
      expect(model.localizedAction('en'), 'Apply straw mulch on ridges before flowering.');

      // JSON roundtrip
      final serialized = model.toJson();
      expect(serialized['id'], 'adv_test_01');
      expect(serialized['category'], 'IRRIGATION');
    });
  });

  group('AnalyticsRepository Unit Tests', () {
    late FakeDioClient fakeDio;
    late AnalyticsRepository repository;

    setUp(() {
      fakeDio = FakeDioClient();
      repository = AnalyticsRepository(fakeDio);
    });

    test('getTemporalTrends sends parameterized query and deserializes response', () async {
      fakeDio.mockGetResponse = {
        'success': true,
        'data': {
          'period': 'SEASONAL',
          'riskTrend': [
            {'date': '2026-08-01', 'value': 2.4, 'label': 'Belg-Meher Transition'}
          ],
          'rainfallTrend': [
            {'date': '2026-08-01', 'value': 35.0, 'label': 'Precipitation'}
          ],
          'temperatureTrend': [
            {'date': '2026-08-01', 'value': 24.2, 'label': 'LST'}
          ],
          'ndviTrend': [
            {'date': '2026-08-01', 'value': 0.72, 'label': 'Vegetative Vigor'}
          ],
          'aiInsights': 'High moisture index in central rift valley.',
          'decadalShifts': '+1.1C decadal increase',
        }
      };

      final result = await repository.getTemporalTrends(
        'SEASONAL',
        woredaId: 'wor_adama',
        includeAi: true,
        language: 'am',
      );

      expect(fakeDio.lastGetPath, '/analytics/temporal-trends');
      expect(fakeDio.lastGetQueryParams?['timeframe'], 'SEASONAL');
      expect(fakeDio.lastGetQueryParams?['woredaId'], 'wor_adama');
      expect(fakeDio.lastGetQueryParams?['includeAi'], 'true');
      expect(fakeDio.lastGetQueryParams?['language'], 'am');

      expect(result.period, 'SEASONAL');
      expect(result.riskTrend.length, 1);
      expect(result.rainfallTrend.first.value, 35.0);
      expect(result.aiInsights, 'High moisture index in central rift valley.');
    });

    test('getAgronomicAdvisoriesDetailed parses multilingual advisories from backend', () async {
      fakeDio.mockGetResponse = {
        'success': true,
        'data': {
          'cropType': 'WHEAT',
          'season': 'MEHER',
          'advisories': [
            {
              'id': 'adv_01',
              'cropType': 'WHEAT',
              'season': 'MEHER',
              'titleEn': 'Optimal Moisture Management',
              'titleAm': 'የእርጥበት አያያዝ እና ጥበቃ',
              'titleOm': 'Kunsa Jiidha',
              'actionEn': 'Apply supplemental irrigation before flowering.',
              'actionAm': '\u1270\u1328\u121b\u122a \u1218\u1235\u1296 \u12eb\u1320\u1321\u1363',
              'actionOm': 'Bishaan itti naqaa.',
              'urgency': 'HIGH',
              'category': 'IRRIGATION',
            },
            {
              'id': 'adv_02',
              'cropType': 'WHEAT',
              'season': 'MEHER',
              'titleEn': 'Rust Disease Scout',
              'titleAm': '\u12e8\u12cb\u130d \u1260\u123d\u1273 \u12ad\u1275\u1275\u120d',
              'titleOm': 'Hordoffii Wagii',
              'actionEn': 'Inspect leaves twice weekly for yellow rust.',
              'actionAm': '\u1260\u12e8\u1233\u121d\u1295\u1271 \u1201\u1208\u1275 \u130a\u12dc \u12ed\u1348\u1275\u1231\u1363',
              'actionOm': 'Torbanitti yeroo lama sakatta\'aa.',
              'urgency': 'MEDIUM',
              'category': 'DISEASE_CONTROL',
            }
          ]
        }
      };

      final advisories = await repository.getAgronomicAdvisoriesDetailed(
        cropType: 'WHEAT',
        season: 'MEHER',
        woredaId: 'wor_adama',
      );

      expect(fakeDio.lastGetPath, '/analytics/agronomic-advisories');
      expect(fakeDio.lastGetQueryParams?['cropType'], 'WHEAT');
      expect(fakeDio.lastGetQueryParams?['season'], 'MEHER');
      expect(fakeDio.lastGetQueryParams?['woredaId'], 'wor_adama');

      expect(advisories.length, 2);
      expect(advisories[0].urgency, 'HIGH');
      expect(advisories[0].category, 'IRRIGATION');
      expect(advisories[1].category, 'DISEASE_CONTROL');
    });

    test('exportAnalyticsData triggers backend export endpoint with correct parameters', () async {
      fakeDio.mockGetResponse = 'Export Timestamp,Role,Jurisdiction\n2026-09-09T00:00:00Z,RESEARCHER,NATIONAL';

      final csvData = await repository.exportAnalyticsData(format: 'csv', scope: 'summary');

      expect(fakeDio.lastGetPath, '/analytics/export');
      expect(fakeDio.lastGetQueryParams?['format'], 'csv');
      expect(fakeDio.lastGetQueryParams?['scope'], 'summary');
      expect(csvData, contains('Export Timestamp'));
    });
  });

  group('AnalyticsScreen Enterprise Widget Tests', () {
    late UserModel testUser;
    late Map<String, dynamic> mockAnalyticsData;

    setUp(() {
      testUser = const UserModel(
        id: 'usr_researcher_01',
        phone: '+251911998877',
        fullName: 'Dr. Mesfin Worku',
        role: UserRole.researcher,
        isActive: true,
      );

      mockAnalyticsData = {
        'period': 'WEEKLY',
        'totalFarms': 1240,
        'totalWoredas': 84,
        'activeAlerts': 4,
        'criticalWoredas': 2,
        'averageRiskScore': 2.1,
        'totalHectares': 14280.0,
        'riskDistribution': {'LOW': 12, 'MODERATE': 8, 'HIGH': 4, 'CRITICAL': 2},
        'riskTrends': [
          {'date': '2026-09-01', 'critical': 2, 'high': 4, 'moderate': 8, 'low': 12},
          {'date': '2026-09-08', 'critical': 1, 'high': 3, 'moderate': 7, 'low': 14},
        ],
        'alertFrequency': {'DROUGHT': 6, 'VEGETATION_STRESS': 4, 'LOCUST': 2},
        'cropDistribution': {'Wheat': 45, 'Teff': 32, 'Maize': 18},
        'regionalBreakdown': {'Oromia': 45, 'Amhara': 38, 'Tigray': 22},
        'rainfallTrend': [
          const TrendDataPoint(date: '2026-09-01', value: 25.0, label: 'Precipitation'),
          const TrendDataPoint(date: '2026-09-08', value: 32.5, label: 'Precipitation'),
        ],
        'temperatureTrend': [
          const TrendDataPoint(date: '2026-09-01', value: 23.0, label: 'LST'),
          const TrendDataPoint(date: '2026-09-08', value: 24.5, label: 'LST'),
        ],
        'ndviTrend': [
          const TrendDataPoint(date: '2026-09-01', value: 0.68, label: 'NDVI'),
          const TrendDataPoint(date: '2026-09-08', value: 0.74, label: 'NDVI'),
        ],
        'cropCalendar': CropCalendarModel(
          currentSeason: 'Meher',
          cropStage: 'Vegetative Vigor',
          recommendedActivities: const [
            'Targeted Weeding',
            'Split Urea Top-dressing',
            'Foliar Rust Monitoring',
          ],
          seasonStart: DateTime(2026, 6, 1),
          seasonEnd: DateTime(2026, 11, 30),
          daysRemaining: 75,
        ),
        'weatherSummary': const WeatherSummaryModel(
          avgTemperature: 22.5,
          minTemperature: 15.0,
          maxTemperature: 28.0,
          totalRainfall: 18.2,
          avgHumidity: 62.0,
          avgWindSpeed: 9.5,
          weatherCondition: 'Scattered Clouds',
        ),
        'aiInsights': 'Regional agro-satellite observations show excellent vegetative vigor across central highlands.',
        'decadalShifts': '+1.2C historical warming deviation',
        'advisories': [
          const AgronomicAdvisoryDetail(
            id: 'adv_01',
            cropType: 'WHEAT',
            season: 'MEHER',
            titleEn: 'Soil Moisture Optimization',
            titleAm: '\u12e8\u12a0\u1348\u122d \u12a5\u122d\u1325\u1260\u1275 \u121b\u1233\u12f0\u130d',
            titleOm: 'Kunsa Jiidha Biyyee',
            actionEn: 'Apply supplemental irrigation before heading stage.',
            actionAm: '\u12a8\u121b\u12ed\u1260\u1261 \u1260\u134a\u1275 \u1270\u1328\u121b\u122a \u1218\u1235\u1296 \u12eb\u1320\u1321\u1363',
            actionOm: 'Bishaan dabalataa itti naqaa.',
            urgency: 'HIGH',
            category: 'IRRIGATION',
          ),
          const AgronomicAdvisoryDetail(
            id: 'adv_02',
            cropType: 'TEFF',
            season: 'MEHER',
            titleEn: 'Foliar Blight Scouting',
            titleAm: '\u12e8\u1245\u1320\u120d \u121b\u1260\u1235\u1260\u1235 \u1260\u123d\u1273 \u1245\u12f5\u1218-\u12ad\u1275\u1275\u120d',
            titleOm: 'Hordoffii Dhibee Baalaa',
            actionEn: 'Scout field edges twice weekly for early blight signs.',
            actionAm: '\u12a5\u122d\u123b\u12cd\u1295 \u1260\u12e8\u1233\u121d\u1295\u1271 \u1201\u1208\u1275 \u130a\u12dc \u12ed\u1348\u1275\u1231\u1363',
            actionOm: 'Torbanitti yeroo lama sakatta\'aa.',
            urgency: 'MEDIUM',
            category: 'DISEASE_CONTROL',
          ),
        ],
      };
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          analyticsDataProvider('WEEKLY').overrideWith((ref) => mockAnalyticsData),
          analyticsDataProvider('DAILY').overrideWith((ref) => mockAnalyticsData),
          analyticsDataProvider('MONTHLY').overrideWith((ref) => mockAnalyticsData),
          analyticsDataProvider('SEASONAL').overrideWith((ref) => mockAnalyticsData),
          analyticsDataProvider('YEARLY').overrideWith((ref) => mockAnalyticsData),
          analyticsDataProvider('OVER_YEARS').overrideWith((ref) => mockAnalyticsData),
        ],
        child: const MaterialApp(
          home: AnalyticsScreen(),
        ),
      );
    }

    testWidgets('Renders Executive Header, 6-KPI command matrix, and Gemini AI Card', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // App Bar Title
      expect(find.text('Agronomic Intelligence Command'), findsOneWidget);

      // Executive Status Banner
      expect(find.text('NATIONAL AGRO-INTELLIGENCE OBSERVATORY'), findsOneWidget);
      expect(find.text('ONLINE'), findsOneWidget);

      // 6-KPI Command Matrix
      expect(find.text('Monitored Farms'), findsOneWidget);
      expect(find.text('1240'), findsOneWidget);
      expect(find.text('Active Woredas'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
      expect(find.text('Coverage Area'), findsOneWidget);
      expect(find.text('14280 Ha'), findsOneWidget);
      expect(find.text('Active Alerts'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Critical Woredas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Avg Hazard Index'), findsOneWidget);
      expect(find.text('2.1 / 5.0'), findsOneWidget);

      // EthioFarm AI Card
      expect(find.text('EthioFarm AI Agronomic Synthesis'), findsOneWidget);
      expect(find.text('Agro-Intelligence Synthesis'), findsOneWidget);
      expect(find.textContaining('Regional agro-satellite observations show excellent'), findsOneWidget);
      expect(find.textContaining('Decadal Climate Anomaly: +1.2C'), findsOneWidget);
    });

    testWidgets('Displays Actionable Agronomic Advisories and supports multilingual toggle', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Heading
      expect(find.text('Actionable Agronomic Advisories'), findsOneWidget);

      // Default language is Amharic ('am')
      expect(find.text('\u12e8\u12a0\u1348\u122d \u12a5\u122d\u1325\u1260\u1275 \u121b\u1233\u12f0\u130d'), findsOneWidget);

      // Toggle language to English ('EN')
      final enButton = find.text('EN');
      expect(enButton, findsOneWidget);
      await tester.tap(enButton);
      await tester.pumpAndSettle();

      // Verify English title appears
      expect(find.text('Soil Moisture Optimization'), findsOneWidget);
      expect(find.text('Apply supplemental irrigation before heading stage.'), findsOneWidget);

      // Toggle language to Afaan Oromoo ('OR')
      final omButton = find.text('OR');
      expect(omButton, findsOneWidget);
      await tester.tap(omButton);
      await tester.pumpAndSettle();

      // Verify Oromo title appears
      expect(find.text('Kunsa Jiidha Biyyee'), findsOneWidget);
      expect(find.text('Bishaan dabalataa itti naqaa.'), findsOneWidget);
    });

    testWidgets('Filters advisories by category chip', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially both advisories are visible
      expect(find.text('IRRIGATION'), findsOneWidget);
      expect(find.text('DISEASE CONTROL'), findsOneWidget);

      // Tap 'Irrigation & Water' category chip
      final irrigationChip = find.text('Irrigation & Water');
      expect(irrigationChip, findsOneWidget);
      await tester.tap(irrigationChip);
      await tester.pumpAndSettle();

      // Only IRRIGATION should remain visible
      expect(find.text('IRRIGATION'), findsOneWidget);
      expect(find.text('DISEASE CONTROL'), findsNothing);
    });

    testWidgets('Export button displays modal bottom sheet with CSV and JSON options', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find export icon button in app bar
      final exportBtn = find.byIcon(Icons.file_download_outlined);
      expect(exportBtn, findsOneWidget);

      await tester.tap(exportBtn);
      await tester.pumpAndSettle();

      // Verify modal sheet appears with format options
      expect(find.text('Export Agronomic Intelligence Dataset'), findsOneWidget);
      expect(find.text('CSV Telemetry Spreadsheet'), findsOneWidget);
      expect(find.text('JSON National Overview'), findsOneWidget);
    });
  });
}
