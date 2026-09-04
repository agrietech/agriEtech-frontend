import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../utils/role_utils.dart';
import '../widgets/error_view.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/auth/screens/role_application_screen.dart';
import '../../features/home/screens/main_navigation_shell.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/farms/screens/farms_list_screen.dart';
import '../../features/farms/screens/farm_detail_screen.dart';
import '../../features/farms/screens/add_farm_screen.dart';
import '../../features/alerts/screens/alerts_list_screen.dart';
import '../../features/alerts/screens/create_alert_screen.dart';
import '../../features/risk/screens/risk_map_screen.dart';
import '../../features/risk/screens/disaster_intelligence_screen.dart';
import '../../features/risk/screens/seismology_detail_screen.dart';
import '../../features/risk/screens/soil_degradation_screen.dart';
import '../../features/risk/screens/landslide_risk_screen.dart';
import '../../features/risk/screens/drought_intelligence_screen.dart';
import '../../features/risk/screens/flood_intelligence_screen.dart';
import '../../features/risk/screens/volcanic_hazard_screen.dart';
import '../../features/analytics/screens/ussd_alert_console_screen.dart';

import '../../features/diagnosis/screens/diagnosis_list_screen.dart';
import '../../features/diagnosis/screens/create_diagnosis_screen.dart';
import '../../features/sensors/screens/sensors_list_screen.dart';
import '../../features/sensors/screens/register_sensor_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/boundaries/screens/boundaries_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/ai_voice/screens/ai_assistant_screen.dart';

/// Listenable that notifies GoRouter whenever AuthState changes
class AuthChangeNotifier extends ChangeNotifier {
  final Ref _ref;

  AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final authChangeNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  return AuthChangeNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isInitializing = authState.isInitializing;
      final currentLoc = state.matchedLocation;
      final isAuthRoute = currentLoc.startsWith('/login') ||
          currentLoc.startsWith('/register');

      // 1. If initializing, stay on splash screen
      if (isInitializing) {
        return currentLoc == '/splash' ? null : '/splash';
      }

      // 2. If initialization finished and user is on splash, direct them appropriately
      if (currentLoc == '/splash') {
        return isAuthenticated ? '/home' : '/login';
      }

      // 3. If unauthenticated user tries to access protected route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 4. If authenticated user tries to access login or register, redirect to home
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // 5. Role-based route authorization guards
      if (isAuthenticated) {
        final role = authState.user?.role;

        // Alert creation — only officers, DAs, and admin
        if (currentLoc == '/alerts/create' &&
            !RoleUtils.canCreateAlerts(role)) {
          return '/home';
        }

        // Sensor registration — only DAs, officers, and admin
        if (currentLoc == '/sensors/register' &&
            !RoleUtils.canRegisterSensors(role)) {
          return '/home';
        }

        // USSD console — only officers and admin
        if (currentLoc == '/ussd-console' &&
            !authState.canAccessUssdConsole) {
          return '/home';
        }

        // Analytics — only officers, researchers, and admin
        if (currentLoc == '/analytics' &&
            !RoleUtils.canViewAnalytics(role)) {
          return '/home';
        }

        // Farm registration — only farmers and DAs
        if (currentLoc == '/farms/add' &&
            !RoleUtils.canManageFarms(role)) {
          return '/home';
        }

        // Disease diagnosis creation — only farmers, DAs, and officers
        if ((currentLoc == '/diagnosis/create' || currentLoc == '/create-diagnosis') &&
            !RoleUtils.canCreateDiagnosis(role)) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      // Splash/Loading route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationShell(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Profile routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // Role Application route
      GoRoute(
        path: '/apply-role',
        builder: (context, state) => const RoleApplicationScreen(),
      ),
      GoRoute(
        path: '/role-application',
        builder: (context, state) => const RoleApplicationScreen(),
      ),

      // Farms routes
      GoRoute(
        path: '/farms',
        builder: (context, state) => const FarmsListScreen(),
      ),
      GoRoute(
        path: '/farms/add',
        builder: (context, state) => const AddFarmScreen(),
      ),
      GoRoute(
        path: '/farms/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FarmDetailScreen(farmId: id);
        },
      ),

      // Alerts routes
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsListScreen(),
      ),
      GoRoute(
        path: '/alerts/create',
        builder: (context, state) => const CreateAlertScreen(),
      ),

      // Risk map & Multi-Hazard Disaster Intelligence routes
      GoRoute(
        path: '/risks',
        builder: (context, state) => const RiskMapScreen(),
      ),
      GoRoute(
        path: '/risk-map',
        builder: (context, state) => const RiskMapScreen(),
      ),
      GoRoute(
        path: '/disasters',
        builder: (context, state) => const DisasterIntelligenceScreen(),
      ),
      GoRoute(
        path: '/seismology',
        builder: (context, state) => const SeismologyDetailScreen(),
      ),
      GoRoute(
        path: '/soil-degradation',
        builder: (context, state) => const SoilDegradationScreen(),
      ),
      GoRoute(
        path: '/landslides',
        builder: (context, state) => const LandslideRiskScreen(),
      ),
      GoRoute(
        path: '/drought-intelligence',
        builder: (context, state) => const DroughtIntelligenceScreen(),
      ),
      GoRoute(
        path: '/flood-intelligence',
        builder: (context, state) => const FloodIntelligenceScreen(),
      ),
      GoRoute(
        path: '/volcanic-hazards',
        builder: (context, state) => const VolcanicHazardScreen(),
      ),
      GoRoute(
        path: '/volcanic-hazard',
        builder: (context, state) => const VolcanicHazardScreen(),
      ),
      GoRoute(
        path: '/ussd-console',
        builder: (context, state) => const UssdAlertConsoleScreen(),
      ),


      // Diagnosis routes
      GoRoute(
        path: '/diagnosis',
        builder: (context, state) => const DiagnosisListScreen(),
      ),
      GoRoute(
        path: '/diagnosis/create',
        builder: (context, state) => const CreateDiagnosisScreen(),
      ),
      GoRoute(
        path: '/create-diagnosis',
        builder: (context, state) => const CreateDiagnosisScreen(),
      ),


      // Sensor routes
      GoRoute(
        path: '/sensors',
        builder: (context, state) => const SensorsListScreen(),
      ),
      GoRoute(
        path: '/sensors/register',
        builder: (context, state) => const RegisterSensorScreen(),
      ),

      // Weather route
      GoRoute(
        path: '/weather',
        builder: (context, state) => const WeatherScreen(),
      ),

      // Boundaries route
      GoRoute(
        path: '/boundaries',
        builder: (context, state) => const BoundariesScreen(),
      ),

      // AI & Analytics routes
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        elevation: 0,
      ),
      body: Center(
        child: AppErrorView(
          icon: Icons.explore_off_rounded,
          title: 'Page Not Found',
          message: 'The requested page (${state.uri.toString()}) does not exist or has been moved.',
          actionLabel: 'Go to Home',
          onRetry: () => context.go('/home'),
        ),
      ),
    ),
  );
});
