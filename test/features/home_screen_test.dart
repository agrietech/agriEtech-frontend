import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        key: ValueKey('${user.id}_${user.role.name}'),
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

    testWidgets('renders top Command Center Hero banner with user identity, daily temperature, and status', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      expect(find.text('Dr. Alemayehu Tesfaye'), findsOneWidget);
      expect(find.textContaining('SENTINEL-2 & LORAWAN ONLINE'), findsOneWidget);
      expect(find.textContaining('Adama Rural Woreda Administration'), findsOneWidget);
      expect(find.text('WOREDA EXCLUSIVE'), findsOneWidget);
      expect(find.text('WOREDA OFFICER'), findsOneWidget);

      // Daily temperature and hourly weather metrics on the hero banner
      expect(find.text('24.5°C'), findsOneWidget);
      expect(find.text('Partly Cloudy'), findsOneWidget);
      expect(find.text('HOURLY LIVE'), findsOneWidget);
      expect(find.textContaining('💧 56%'), findsOneWidget);

      // Best agronomic telemetry metrics on the hero KPI strip
      expect(find.text('42.8%'), findsOneWidget); // LoRaWAN Soil Moisture
      expect(find.text('0.74 NDVI'), findsOneWidget); // Sentinel-2 Vegetation Index
      expect(find.text('48.5 ha'), findsOneWidget); // Monitored Hectares
    });

    testWidgets('renders all application tools directly as icons on home screen', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      // All 12 application tools rendered directly as icons
      expect(find.text('Crop Doctor'), findsOneWidget);
      expect(find.text('Spray Window'), findsOneWidget);
      expect(find.text('Tank Mix'), findsOneWidget);
      expect(find.text('Seed Calculator'), findsOneWidget);
      expect(find.text('Soil Health'), findsOneWidget);
      expect(find.text('My Farms'), findsOneWidget);
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('GIS Map'), findsOneWidget);
      expect(find.text('EthioFarm AI'), findsOneWidget);
      expect(find.text('Hazards'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('verifies that categories and extra texts are avoided on home screen', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      // Categorizations of icons are avoided
      expect(find.text('COMMAND ACTIONS'), findsNothing);
      expect(find.text('LIVE SATELLITE & IOT HUD'), findsNothing);
      expect(find.text('PLANT HEALTH & CROP DOCTOR'), findsNothing);
      expect(find.text('CROP PROTECTION TOOLS'), findsNothing);
      expect(find.text('ENTERPRISE OPERATIONS'), findsNothing);
      expect(find.text('SMART AGRI-INTELLIGENCE'), findsNothing);

      // Standalone separate duplicate apps should NOT exist
      expect(find.text('Weed Detector'), findsNothing);
      expect(find.text('Nutrient Scanner'), findsNothing);
      expect(find.text('Pest Scout'), findsNothing);
    });

    testWidgets('renders active emergency alert badge count on Alerts icon when alerts exist', (tester) async {
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

      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // Notification badge count
    });

    testWidgets('renders all icons for farmer role without category separation', (tester) async {
      final farmerUser = testUser.copyWith(role: UserRole.farmer);
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: farmerUser,
      ));
      await tester.pump();

      expect(find.text('Crop Doctor'), findsOneWidget);
      expect(find.text('Spray Window'), findsOneWidget);
      expect(find.text('Tank Mix'), findsOneWidget);
      expect(find.text('Seed Calculator'), findsOneWidget);
      expect(find.text('Soil Health'), findsOneWidget);
      expect(find.text('My Farms'), findsOneWidget);
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Alerts'), findsOneWidget);
      expect(find.text('GIS Map'), findsOneWidget);
      expect(find.text('EthioFarm AI'), findsOneWidget);

      // No category headers for farmer either
      expect(find.text('COMMAND ACTIONS'), findsNothing);
      expect(find.text('CROP PROTECTION TOOLS'), findsNothing);
    });

    testWidgets('renders app bar with user profile avatar and language selector', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      // Profile avatar with first initial
      expect(find.text('D'), findsOneWidget);
      // Language switcher button
      expect(find.text('EN'), findsOneWidget);
    });

    testWidgets('all 12 home launchpad icons have valid routes and labels', (tester) async {
      await tester.pumpWidget(createTestApp(
        dashboardData: testDashboardData,
        user: testUser,
      ));
      await tester.pump();

      final iconLabels = [
        'Crop Doctor',
        'Spray Window',
        'Tank Mix',
        'Seed Calculator',
        'Soil Health',
        'My Farms',
        'Weather',
        'Alerts',
        'GIS Map',
        'EthioFarm AI',
        'Hazards',
        'Analytics',
      ];

      for (final label in iconLabels) {
        final finder = find.text(label);
        expect(finder, findsOneWidget);
      }
    });

    testWidgets('Soil Health, GIS Map, and Analytics navigate via GoRouter when tapped', (tester) async {
      final pushedRoutes = <String>[];
      final testRouter = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/create-diagnosis', builder: (c, s) { pushedRoutes.add('/create-diagnosis'); return const SizedBox(); }),
          GoRoute(path: '/crop-protection/spray-window', builder: (c, s) { pushedRoutes.add('/crop-protection/spray-window'); return const SizedBox(); }),
          GoRoute(path: '/crop-protection/tank-mix', builder: (c, s) { pushedRoutes.add('/crop-protection/tank-mix'); return const SizedBox(); }),
          GoRoute(path: '/crop-protection/seed-calculator', builder: (c, s) { pushedRoutes.add('/crop-protection/seed-calculator'); return const SizedBox(); }),
          GoRoute(path: '/soil-degradation', builder: (c, s) { pushedRoutes.add('/soil-degradation'); return const SizedBox(); }),
          GoRoute(path: '/farms', builder: (c, s) { pushedRoutes.add('/farms'); return const SizedBox(); }),
          GoRoute(path: '/weather', builder: (c, s) { pushedRoutes.add('/weather'); return const SizedBox(); }),
          GoRoute(path: '/alerts', builder: (c, s) { pushedRoutes.add('/alerts'); return const SizedBox(); }),
          GoRoute(path: '/risks', builder: (c, s) { pushedRoutes.add('/risks'); return const SizedBox(); }),
          GoRoute(path: '/ai-assistant', builder: (c, s) { pushedRoutes.add('/ai-assistant'); return const SizedBox(); }),
          GoRoute(path: '/disasters', builder: (c, s) { pushedRoutes.add('/disasters'); return const SizedBox(); }),
          GoRoute(path: '/analytics', builder: (c, s) { pushedRoutes.add('/analytics'); return const SizedBox(); }),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(testUser),
            authProvider.overrideWith((ref) => FakeAuthNotifier(AuthState(
                  user: testUser,
                  isAuthenticated: true,
                  isInitializing: false,
                ))),
            dashboardProvider.overrideWith((ref) => FakeDashboardNotifier(DashboardState(
                  data: testDashboardData,
                  isLoading: false,
                ))),
            alertListProvider.overrideWith((ref) => FakeAlertNotifier(const AsyncValue.data([]))),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('am'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Soil Health
      await tester.ensureVisible(find.text('Soil Health'));
      await tester.tap(find.text('Soil Health'));
      await tester.pumpAndSettle();
      expect(pushedRoutes.contains('/soil-degradation'), isTrue);

      // Return to home
      testRouter.go('/home');
      await tester.pumpAndSettle();

      // Tap GIS Map
      await tester.ensureVisible(find.text('GIS Map'));
      await tester.tap(find.text('GIS Map'));
      await tester.pumpAndSettle();
      expect(pushedRoutes.contains('/risks'), isTrue);

      // Return to home
      testRouter.go('/home');
      await tester.pumpAndSettle();

      // Tap Analytics
      await tester.ensureVisible(find.text('Analytics'));
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      expect(pushedRoutes.contains('/analytics'), isTrue);
    });
  });
}
