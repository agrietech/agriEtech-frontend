import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/risk_summary_card.dart';
import '../widgets/weather_summary_card.dart';
import '../widgets/recent_alerts_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../../ai_voice/widgets/ai_assistant_sheet.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadDashboard());
  }

  Future<void> _refreshDashboard() async {
    await ref.read(dashboardProvider.notifier).refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      drawer: const AgriEtechAppDrawer(),
      appBar: AppBar(
        title: Text(_getDashboardTitle(authState)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: dashboardState.isLoading ? null : _refreshDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _buildBody(context, dashboardState, authState),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard_ai',
        onPressed: () => AiAssistantSheet.show(context),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        tooltip: 'Agri-AI Assistant',
        child: const Icon(Icons.psychology, color: Color(0xFFF59E0B)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state, AuthState authState) {
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasData) {
      return const DashboardSkeleton();
    }

    if (state.hasError && !state.hasData) {
      return AppErrorView(
        title: 'Failed to load dashboard',
        message: state.error?.message ?? 'Unknown error occurred while fetching dashboard data.',
        onRetry: () => ref.read(dashboardProvider.notifier).loadDashboard(),
      );
    }

    if (!state.hasData) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final data = state.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header with high-tech badge
          _buildWelcomeHeader(context, authState),
          const SizedBox(height: AppSpacing.md),

          // Agro-Intelligence Real-Time Telemetry Bar
          _buildAgroTelemetryStrip(context, data),
          const SizedBox(height: AppSpacing.md),

          // Last updated info
          if (state.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors_outlined,
                    size: 14,
                    color: AppTheme.telemetrySensor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Telemetry Sync: ${DateFormatter.formatRelativeTime(state.lastUpdated!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (state.isRefreshing) ...[
                    const SizedBox(width: 8),
                    const AppLoadingIndicator.small(),
                  ],
                ],
              ),
            ),

          // Risk Summary Card
          RiskSummaryCard(
            riskSummary: data.riskSummary,
            onTap: () => context.push('/risk-map'),
          ),
          const SizedBox(height: 16),

          // Weather Summary Card
          if (data.weatherSummary.current != null || 
              (data.weatherSummary.forecast?.isNotEmpty ?? false))
            Column(
              children: [
                WeatherSummaryCard(
                  weatherSummary: data.weatherSummary,
                  onTap: () => context.push('/risk-map'),
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Farm Summary — Farmers and DAs
          if (authState.isFarmer || authState.isDevelopmentAgent)
            Column(
              children: [
                _buildFarmSummaryCard(context, data.farmSummary),
                const SizedBox(height: 16),
              ],
            ),

          // DA-specific: Supervised Kebele Overview
          if (authState.isDevelopmentAgent)
            Column(
              children: [
                _buildDaKebeleOverviewCard(context),
                const SizedBox(height: 16),
              ],
            ),

          // Officer-specific: Jurisdiction Aggregate Panel
          if (authState.isOfficer)
            Column(
              children: [
                _buildJurisdictionAggregateCard(context, authState),
                const SizedBox(height: 16),
              ],
            ),

          // Researcher-specific: Data Insights Panel
          if (authState.isResearcher)
            Column(
              children: [
                _buildResearcherInsightsCard(context),
                const SizedBox(height: 16),
              ],
            ),

          // Recent Alerts
          RecentAlertsCard(
            alerts: data.recentAlerts,
            onViewAll: () => context.push('/alerts'),
            onAlertTap: (alert) {
              context.push('/alerts');
            },
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(context, authState),
          const SizedBox(height: 16),

          // System Health (for all officer tiers and admin)
          if (authState.canViewSystemHealth)
            _buildSystemHealthCard(context, data.systemHealth),
        ],
      ),
    );
  }

  Widget _buildAgroTelemetryStrip(BuildContext context, DashboardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E2E1E),
            Color(0xFF0D2818),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.telemetryNdvi.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.satellite_outlined, color: AppTheme.telemetryNdvi, size: 14),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SATELLITE & IOT TELEMETRY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.telemetryNdvi.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.telemetryNdvi.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: AppTheme.telemetryNdvi, size: 6),
                    SizedBox(width: 4),
                    Text(
                      'HEALTHY',
                      style: TextStyle(
                        color: AppTheme.telemetryNdvi,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTelemetryMetric(
                label: 'NDVI Health',
                value: '0.74',
                unit: 'Index',
                icon: Icons.eco,
                color: AppTheme.telemetryNdvi,
              ),
              Container(height: 32, width: 1, color: Colors.white12),
              _buildTelemetryMetric(
                label: 'Soil Moisture',
                value: '38.5',
                unit: '% Vol',
                icon: Icons.water_drop,
                color: const Color(0xFF38BDF8),
              ),
              Container(height: 32, width: 1, color: Colors.white12),
              _buildTelemetryMetric(
                label: 'Drought Risk',
                value: 'Low',
                unit: 'Status',
                icon: Icons.wb_sunny_outlined,
                color: AppTheme.lowRiskColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryMetric({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$label ($unit)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final user = authState.user;
    final greeting = _getGreeting();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${user?.fullName ?? 'User'}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E2E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getRoleDescription(authState),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            RoleUtils.getRoleDisplayName(user?.role),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getRoleDescription(AuthState authState) {
    if (authState.isFarmer) {
      return 'Monitor your farms and receive early warnings';
    } else if (authState.isDevelopmentAgent) {
      return 'Support farmers in your kebele and manage field operations';
    } else if (authState.isWoredaOfficer) {
      return 'Manage alerts and monitor risks across your woreda';
    } else if (authState.isZonalOfficer) {
      return 'Oversee woredas and coordinate zonal disaster response';
    } else if (authState.isRegionalOfficer) {
      return 'Regional oversight across zones with strategic intelligence';
    } else if (authState.isResearcher) {
      return 'Analyze agricultural data, climate trends, and crop models';
    } else if (authState.isAdmin) {
      return 'National platform administration and system oversight';
    }
    return 'Welcome to AgriEtech';
  }

  Widget _buildFarmSummaryCard(BuildContext context, FarmSummary farmSummary) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/farms'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Farms',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.landscape,
                    label: 'Total Farms',
                    value: farmSummary.totalFarms.toString(),
                  ),
                  _StatItem(
                    icon: Icons.square_foot,
                    label: 'Total Area',
                    value: '${farmSummary.totalArea.toStringAsFixed(1)} ha',
                  ),
                  _StatItem(
                    icon: Icons.warning,
                    label: 'At Risk',
                    value: farmSummary.farmsAtRisk.toString(),
                    valueColor: farmSummary.farmsAtRisk > 0 ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);

    final actions = <Map<String, dynamic>>[];

    // Common actions
    actions.add({
      'icon': Icons.map,
      'label': 'Risk Map',
      'onTap': () => context.push('/risk-map'),
    });

    if (authState.isFarmer) {
      actions.add({
        'icon': Icons.add_location,
        'label': 'Add Farm',
        'onTap': () => context.push('/farms/add'),
      });
      actions.add({
        'icon': Icons.bug_report,
        'label': 'Disease Check',
        'onTap': () => context.push('/diagnosis'),
      });
      actions.add({
        'icon': Icons.wb_cloudy,
        'label': 'Weather',
        'onTap': () => context.push('/weather'),
      });
    }

    if (authState.isDevelopmentAgent) {
      actions.add({
        'icon': Icons.agriculture,
        'label': 'Farm Registry',
        'onTap': () => context.push('/farms'),
      });
      actions.add({
        'icon': Icons.bug_report,
        'label': 'Disease Scout',
        'onTap': () => context.push('/diagnosis'),
      });
      actions.add({
        'icon': Icons.sensors,
        'label': 'IoT Sensors',
        'onTap': () => context.push('/sensors'),
      });
    }

    if (authState.canCreateAlerts) {
      actions.add({
        'icon': Icons.add_alert,
        'label': 'Create Alert',
        'onTap': () => context.push('/alerts/create'),
      });
    }

    if (authState.isOfficer) {
      actions.add({
        'icon': Icons.thunderstorm,
        'label': 'Disaster Intel',
        'onTap': () => context.push('/disasters'),
      });
    }

    if (authState.canExportData) {
      actions.add({
        'icon': Icons.analytics,
        'label': 'Analytics',
        'onTap': () => context.push('/analytics'),
      });
    }

    if (authState.canManageUsers) {
      actions.add({
        'icon': Icons.admin_panel_settings,
        'label': 'User Admin',
        'onTap': () => context.push('/boundaries'),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionButton(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemHealthCard(BuildContext context, SystemHealth health) {
    final theme = Theme.of(context);
    final isHealthy = health.status == 'OPERATIONAL' && health.apiHealthy;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.error,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Health',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.people,
                  label: 'Active Users',
                  value: health.activeUsers.toString(),
                ),
                _StatItem(
                  icon: Icons.data_usage,
                  label: 'Data Points',
                  value: health.dataPointsToday.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// DA-specific: Supervised Kebele Overview Card
  Widget _buildDaKebeleOverviewCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.groups_outlined, color: Color(0xFF0D9488), size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Kebele Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Extension',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.person_outline,
                  label: 'Supervised\nFarmers',
                  value: '—',
                ),
                _StatItem(
                  icon: Icons.warning_amber,
                  label: 'Farms\nAt Risk',
                  value: '—',
                  valueColor: AppTheme.warningColor,
                ),
                _StatItem(
                  icon: Icons.assignment_outlined,
                  label: 'Field Visits\nThis Week',
                  value: '—',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Officer-specific: Jurisdiction Aggregate Card
  Widget _buildJurisdictionAggregateCard(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final scopeLabel = authState.jurisdictionLevel;

    String scopeTitle;
    IconData scopeIcon;
    Color scopeColor;

    switch (scopeLabel) {
      case 'WOREDA':
        scopeTitle = 'Woreda Aggregate';
        scopeIcon = Icons.location_city_outlined;
        scopeColor = const Color(0xFF1E40AF);
        break;
      case 'ZONE':
        scopeTitle = 'Zonal Aggregate';
        scopeIcon = Icons.account_balance_outlined;
        scopeColor = const Color(0xFF7C3AED);
        break;
      case 'REGION':
        scopeTitle = 'Regional Aggregate';
        scopeIcon = Icons.flag_outlined;
        scopeColor = const Color(0xFFBE185D);
        break;
      default:
        scopeTitle = 'National Overview';
        scopeIcon = Icons.public;
        scopeColor = const Color(0xFFD97706);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scopeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(scopeIcon, color: scopeColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  scopeTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scopeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scopeLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scopeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.people_outline,
                  label: 'Total\nFarmers',
                  value: '—',
                ),
                _StatItem(
                  icon: Icons.notifications_active,
                  label: 'Active\nAlerts',
                  value: '—',
                  valueColor: AppTheme.warningColor,
                ),
                _StatItem(
                  icon: Icons.sensors,
                  label: 'IoT\nDevices',
                  value: '—',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Aggregated data will populate when the backend returns jurisdiction-scoped metrics.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Researcher-specific: Data Insights Card
  Widget _buildResearcherInsightsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4338CA).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.science_outlined, color: Color(0xFF4338CA), size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Research Data Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4338CA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Science',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.satellite_alt,
                  label: 'GEE\nDatasets',
                  value: '6',
                ),
                _StatItem(
                  icon: Icons.timeline,
                  label: 'Time Series\nAvailable',
                  value: '5yr',
                ),
                _StatItem(
                  icon: Icons.download,
                  label: 'Export\nFormats',
                  value: '3',
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/analytics'),
              icon: const Icon(Icons.insights, size: 16),
              label: const Text('Open Analytics & Export'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4338CA),
                side: const BorderSide(color: Color(0xFF4338CA)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a role-adaptive dashboard title for the AppBar
  String _getDashboardTitle(AuthState authState) {
    if (authState.isFarmer) return 'My Farm Dashboard';
    if (authState.isDevelopmentAgent) return 'Kebele Extension Dashboard';
    if (authState.isWoredaOfficer) return 'Woreda Command Center';
    if (authState.isZonalOfficer) return 'Zone Operations Dashboard';
    if (authState.isRegionalOfficer) return 'Regional Operations Hub';
    if (authState.isResearcher) return 'Research Analytics Hub';
    if (authState.isAdmin) return 'National Operations Dashboard';
    return 'Dashboard';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 24, color: theme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
