import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:EthioFarm/features/home/screens/home_screen.dart';
import 'package:EthioFarm/features/dashboard/providers/dashboard_provider.dart';
import 'package:EthioFarm/features/dashboard/models/dashboard_models.dart';
import 'package:EthioFarm/features/alerts/providers/alert_provider.dart';
import 'package:EthioFarm/features/alerts/models/alert_models.dart';
import 'package:EthioFarm/features/auth/providers/auth_provider.dart';
import 'package:EthioFarm/core/models/user_model.dart';
import 'package:EthioFarm/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDashboardNotifier extends StateNotifier<DashboardState> implements DashboardNotifier {
  FakeDashboardNotifier(super.state);

  @override
  Future<void> loadDashboard({String? woredaId, String? zoneId, String? regionId}) async {}

  @override
  Future<void> refreshDashboard({String? woredaId, String? zoneId, String? regionId}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAlertNotifier extends StateNotifier<AsyncValue<List<AlertModel>>> implements AlertNotifier {
  FakeAlertNotifier(super.state);

  @override
  Future<void> fetchAlerts() async {}

  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Enterprise HomeScreen Widget & Telemetry Suite', () {
    late DashboardData testDashboardData;
    late UserModel testUser;

    setUp(() {
      testUser = const UserModel(
        id: 'usr_agronomy_01',
        phone: '+251911223344',
        fullName: 'Dr. Alemayehu Tesfaye',
        role: UserRole.woredaOfficer,
        region: RegionInfo(id: 'reg_oromia', name: 'Oromia'),
        zone: ZoneInfo(id: 'zone_east_shewa', name: 'East Shewa'),
        woreda: WoredaInfo(id: 'wor_adama', name: 'Adama Rural'),
        kebeleName: 'Kebele 04',
      );

      testDashboardData = DashboardData(
        riskSummary: const RiskSummary(
          totalWoredas: 1148,
          lowRisk: 1120,
          moderateRisk: 18,
          highRisk: 8,
          criticalRisk: 2,
          affectedPopulation: 35000,
        ),
        recentAlerts: [
          RecentAlert(
            id: 'alt_live_1',
            title: 'Critical Soil Moisture Deficit',
            message: 'Lowland moisture deficit in East Shewa zone.',
            severity: 'CRITICAL',
            hazardType: 'DROUGHT',
            woredaName: 'Adama Rural',
            createdAt: DateTime.now(),
          ),
        ],
        weatherSummary: WeatherSummary(
          current: const CurrentWeather(
            temperature: 24.5,
            humidity: 56.0,
            rainfall: 2.4,
            windSpeed: 14.0,
            condition: 'Partly Cloudy',
          ),
          forecast: [
            DailyForecast(
              date: DateTime.now(),
              tempMax: 26.0,
              tempMin: 15.0,
              rainfall: 1.0,
              humidity: 50.0,
              condition: 'Showers',
            ),
          ],
        ),
        farmSummary: const FarmSummary(
          totalFarms: 24,
          totalArea: 48.5,
          farmsAtRisk: 2,
          activeSensors: 16,
        ),
        systemHealth: const SystemHealth(
          status: 'OPERATIONAL',
          activeUsers: 84,
          dataPointsToday: 620,
          apiHealthy: true,
        ),
        telemetry: const DashboardTelemetry(
          averageNdvi: 0.74,
          soilMoisture: 42.8,
          droughtRisk: 'LOW',
          status: 'HEALTHY',
        ),
        jurisdictionMetrics: const JurisdictionMetrics(
          totalFarmers: 24,
          farmsAtRisk: 2,
          fieldVisitsThisWeek: 6,
          monitoredHectares: 48.5,
          activeSensors: 16,
          satelliteObservationsCount: 1840,
        ),
      );
    });

    Widget createTestApp({
      required DashboardData dashboardData,
      required UserModel user,
      List<AlertModel> activeAlerts = const [],
    }) {
      return ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(user),
          authProvider.overrideWith((ref) => FakeAuthNotifier(AuthState(
                user: user,
                isAuthenticated: true,
                isInitializing: false,
              ))),
          dashboardProvider.overrideWith((ref) => FakeDashboardNotifier(DashboardState(
                data: dashboardData,
                isLoading: false,
              ))),
          alertListProvider.overrideWith((ref) => FakeAlertNotifier(AsyncValue.data(activeAlerts))),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('am'),
          ],
          home: HomeScreen(),
        ),
      );
    }

    testWidgets('renders Command Center Hero with user name, role, and jurisdiction breadcrumb', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      // Verify User Name & Greeting
      expect(find.text('Dr. Alemayehu Tesfaye'), findsOneWidget);
      expect(find.textContaining('SENTINEL-2 & LORAWAN ONLINE'), findsOneWidget);

      // Verify Jurisdiction Breadcrumb
      expect(find.textContaining('Oromia • East Shewa • Adama Rural • Kebele 04'), findsOneWidget);

      // Verify Role Badge
      expect(find.text('WOREDA OFFICER'), findsOneWidget);

      // Verify Hero KPI Strip
      expect(find.text('48.5 ha'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(find.text('OPERATIONAL'), findsOneWidget);
    });

    testWidgets('renders Live Satellite & IoT HUD with real telemetry values', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      // Verify Section Title
      expect(find.text('LIVE SATELLITE & IOT HUD'), findsOneWidget);

      // Verify NDVI Vegetation Card
      expect(find.text('0.74'), findsOneWidget);
      expect(find.text('OPTIMAL'), findsOneWidget);
      expect(find.text('NDVI Vegetation'), findsOneWidget);

      // Verify Soil Moisture Card
      expect(find.text('42.8%'), findsOneWidget);
      expect(find.text('16 ONLINE'), findsOneWidget);
      expect(find.text('Soil Moisture'), findsOneWidget);

      // Verify Microclimate Weather Card (shown in HUD and Microclimate card)
      expect(find.text('24.5°C'), findsNWidgets(2));
      expect(find.text('2.4 mm rain'), findsOneWidget);

      // Verify Hazard Radar Card
      expect(find.text('10 Warnings'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('1148 Woredas Monitored'), findsOneWidget);
    });

    testWidgets('renders tactile Command Actions Matrix', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      expect(find.text('COMMAND ACTIONS'), findsOneWidget);
      expect(find.text('Scan Crop'), findsOneWidget);
      expect(find.text('AI Crop Diagnostics'), findsOneWidget);
      expect(find.text('EthioFarm AI'), findsOneWidget);
      expect(find.text('Bilingual AI Agronomist'), findsOneWidget);
      expect(find.text('USSD *212#'), findsNWidgets(2)); // in matrix and services
      expect(find.text('Register Plot'), findsOneWidget);
    });

    testWidgets('renders Climatology & Agronomic Advisory Card', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      expect(find.text('Today\'s Microclimate'), findsOneWidget);
      expect(find.text('PARTLY CLOUDY'), findsOneWidget);
      expect(find.text('56%'), findsOneWidget);
      expect(find.text('14 km/h'), findsOneWidget);
      expect(find.textContaining('Seasonal Advisory:'), findsOneWidget);
    });

    testWidgets('renders active emergency alert ribbon when alerts exist', (tester) async {
      final activeAlert = AlertModel(
        id: 'alt_emer_99',
        woredaId: 'wor_adama',
        userId: 'usr_officer_1',
        hazardType: 'DROUGHT',
        severity: 'CRITICAL',
        title: 'Severe Belg Drought Warning',
        message: 'High moisture deficit detected by Sentinel satellite.',
        isActive: true,
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
        activeAlerts: [activeAlert],
      ));
      await tester.pump();

      expect(find.textContaining('ACTIVE EMERGENCY ALERT (1)'), findsOneWidget);
      expect(find.text('Severe Belg Drought Warning'), findsOneWidget);
    });

    testWidgets('renders agro-climatic stability ribbon when no alerts exist', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
        activeAlerts: const [],
      ));
      await tester.pump();

      expect(find.textContaining('Agro-Climatic Stability: All monitored woredas in normal range'), findsOneWidget);
      expect(find.text('3D GIS Map >'), findsOneWidget);
    });
  });
}
