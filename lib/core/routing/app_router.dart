import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/farms/screens/farms_list_screen.dart';
import '../../features/farms/screens/farm_detail_screen.dart';
import '../../features/farms/screens/add_farm_screen.dart';
import '../../features/alerts/screens/alerts_list_screen.dart';
import '../../features/risk/screens/risk_map_screen.dart';
import '../../features/diagnosis/screens/diagnosis_list_screen.dart';
import '../../features/sensors/screens/sensors_list_screen.dart';
import '../../features/boundaries/screens/boundaries_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isInitializing ? '/splash' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isInitializing = authState.isInitializing;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      // Wait for auth initialization
      if (isInitializing && state.matchedLocation != '/splash') {
        return '/splash';
      }

      // Redirect to login if not authenticated and not on auth route
      if (!isAuthenticated && !isAuthRoute && state.matchedLocation != '/splash') {
        return '/login';
      }

      // Redirect to home if authenticated and on auth route
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash/Loading route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Profile routes
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
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

      // Alerts route
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsListScreen(),
      ),

      // Risk map route
      GoRoute(
        path: '/risk-map',
        builder: (context, state) => const RiskMapScreen(),
      ),

      // Diagnosis routes
      GoRoute(
        path: '/diagnosis',
        builder: (context, state) => const DiagnosisListScreen(),
      ),

      // Sensor routes
      GoRoute(
        path: '/sensors',
        builder: (context, state) => const SensorsListScreen(),
      ),

      // Boundaries route
      GoRoute(
        path: '/boundaries',
        builder: (context, state) => const BoundariesScreen(),
      ),

      // Analytics route (Researchers, Officers, Admin only)
      GoRoute(
        path: '/analytics',
        builder: (context, state) {
          // Role check will be done in the screen
          return const AnalyticsScreen();
        },
      ),
    ],
  );
});
