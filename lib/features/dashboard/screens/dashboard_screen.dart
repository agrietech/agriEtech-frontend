import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../ai_voice/widgets/ai_assistant_sheet.dart';
import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/farmer_dashboard_view.dart';
import '../widgets/officer_command_center_view.dart';
import '../widgets/admin_control_panel_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    // Load dashboard data on init
    Future.microtask(
        () => ref.read(dashboardProvider.notifier).loadDashboard());

    // Auto-refresh telemetry every 60 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        ref.read(dashboardProvider.notifier).refreshDashboard();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    await ref.read(dashboardProvider.notifier).refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
    final userRole = authState.user?.role;
    final AsyncValue<DashboardData> adaptiveState = dashboardState.hasData
        ? AsyncValue.data(dashboardState.data!)
        : dashboardState.hasError
            ? AsyncValue.error(dashboardState.error!, StackTrace.empty)
            : const AsyncValue.loading();

    return Scaffold(
      drawer: const EthioFarmAppDrawer(),
      appBar: AppBar(
        title: Text(
          _getDashboardTitle(authState),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Early Warning Alerts',
            onPressed: () => context.push('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Dashboard',
            onPressed: dashboardState.isLoading ? null : _refreshDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: _buildRoleAdaptiveBody(context, adaptiveState, userRole),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_dashboard_ai',
        onPressed: () => AiAssistantSheet.show(context),
        backgroundColor: AppTheme.headerDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text(
          'EthioFarm AI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  /// Build role-adaptive dashboard body
  Widget _buildRoleAdaptiveBody(BuildContext context,
      AsyncValue<DashboardData> state, UserRole? userRole) {
    return state.when(
      data: (data) => _buildDashboardForRole(context, data, userRole),
      loading: () => const AppLoadingIndicator.large(
        message: 'Loading your command center…',
      ),
      error: (error, stack) => Center(
        child: AppErrorView(
          title: 'Failed to load dashboard',
          message: error.toString(),
          onRetry: () => ref.read(dashboardProvider.notifier).loadDashboard(),
        ),
      ),
    );
  }

  /// Render role-specific dashboard view
  Widget _buildDashboardForRole(
      BuildContext context, DashboardData data, UserRole? role) {
    // Keep the most privileged experience first. Admin is also an officer,
    // so checking officers first silently rendered the wrong control panel.
    if (RoleUtils.isAdmin(role)) {
      return AdminControlPanelView(data: data);
    }

    // Farmer Dashboard
    if (role == UserRole.farmer) {
      return FarmerDashboardView(data: data);
    }

    // Officer Command Center (Woreda, Zonal, Regional Officers)
    if (RoleUtils.isOfficer(role)) {
      return OfficerCommandCenterView(data: data);
    }

    // Development Agent (use officer view for now)
    if (RoleUtils.isDevelopmentAgent(role)) {
      return OfficerCommandCenterView(data: data);
    }

    // Researcher (use analytics-focused view - for now use admin view)
    if (RoleUtils.isResearcher(role)) {
      return AdminControlPanelView(data: data);
    }

    // Fallback to farmer view
    return FarmerDashboardView(data: data);
  }

  String _getDashboardTitle(AuthState authState) {
    if (authState.isFarmer) return 'My Farm Dashboard';
    if (authState.isDevelopmentAgent) return 'Kebele Extension Hub';
    if (authState.isWoredaOfficer) return 'Woreda Command Center';
    if (authState.isZonalOfficer) return 'Zone Operations Hub';
    if (authState.isRegionalOfficer) return 'Regional Operations Center';
    if (authState.isResearcher) return 'Research Analytics Center';
    if (authState.isAdmin) return 'National Operations Dashboard';
    return 'Dashboard';
  }
}
