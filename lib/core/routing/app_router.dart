import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/change_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_navigation_shell.dart';
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
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/auth/screens/role_application_screen.dart';

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
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // Admin & Personnel Management route
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),

      // Role Application route
      GoRoute(
        path: '/apply-role',
        builder: (context, state) => const RoleApplicationScreen(),
      ),
    ],
  );
});
