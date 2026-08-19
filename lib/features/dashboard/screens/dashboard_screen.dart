import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/risk_summary_card.dart';
import '../widgets/weather_summary_card.dart';
import '../widgets/recent_alerts_card.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/providers/auth_provider.dart';

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
      appBar: AppBar(
        title: const Text('Dashboard'),
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
    );
  }

  Widget _buildBody(BuildContext context, DashboardState state, AuthState authState) {
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard...'),
          ],
        ),
      );
    }

    if (state.hasError && !state.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.message ?? 'Unknown error',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(dashboardProvider.notifier).loadDashboard(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasData) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final data = state.data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          _buildWelcomeHeader(context, authState),
          const SizedBox(height: 24),

          // Last updated info
          if (state.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last updated: ${DateFormatter.formatRelativeTime(state.lastUpdated!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (state.isRefreshing) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    ),
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
                  onTap: () {
                    // Navigate to weather details
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),

          // Farm Summary
          if (authState.isFarmer)
            Column(
              children: [
                _buildFarmSummaryCard(context, data.farmSummary),
                const SizedBox(height: 16),
              ],
            ),

          // Recent Alerts
          RecentAlertsCard(
            alerts: data.recentAlerts,
            onViewAll: () => context.push('/alerts'),
            onAlertTap: (alert) {
              // Navigate to alert details
            },
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(context, authState),
          const SizedBox(height: 16),

          // System Health (for officers and admins)
          if (authState.isWoredaOfficer || authState.isAdmin)
            _buildSystemHealthCard(context, data.systemHealth),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final user = authState.user;
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${user?.fullName ?? 'User'}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getRoleDescription(authState),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
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
      return 'Support farmers in your woreda';
    } else if (authState.isWoredaOfficer) {
      return 'Manage alerts and monitor risks in your woreda';
    } else if (authState.isResearcher) {
      return 'Analyze agricultural data and trends';
    } else if (authState.isAdmin) {
      return 'System administration and oversight';
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
    }

    if (authState.canCreateAlerts) {
      actions.add({
        'icon': Icons.add_alert,
        'label': 'Create Alert',
        'onTap': () => context.push('/alerts/create'),
      });
    }

    actions.add({
      'icon': Icons.analytics,
      'label': 'Analytics',
      'onTap': () => context.push('/analytics'),
    });

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
