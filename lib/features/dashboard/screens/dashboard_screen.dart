import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../ai_voice/widgets/ai_assistant_sheet.dart';
import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/risk_summary_card.dart';
import '../widgets/weather_summary_card.dart';
import '../widgets/recent_alerts_card.dart';
import '../widgets/dashboard_trend_chart.dart';
import '../widgets/crop_distribution_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Load dashboard data on init
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadDashboard());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    await ref.read(dashboardProvider.notifier).refreshDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);

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
            tooltip: 'Refresh Telemetry',
            onPressed: dashboardState.isLoading ? null : _refreshDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: _buildBody(context, dashboardState, authState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_dashboard_ai',
        onPressed: () => AiAssistantSheet.show(context),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.psychology, color: Colors.white),
        label: const Text(
          'EthioFarm AI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
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
          // 1. Executive Welcome Header
          _buildWelcomeHeader(context, authState),
          const SizedBox(height: AppSpacing.md),

          // 2. Real-Time Agro-Intelligence Telemetry Bar
          _buildAgroTelemetryStrip(context, data),
          const SizedBox(height: 12),

          // 3. Telemetry Sync Status Row
          if (state.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
              child: Row(
                children: [
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Satellite & IoT Sync: ${DateFormatter.formatRelativeTime(state.lastUpdated!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.isRefreshing) ...[
                    const SizedBox(width: 8),
                    const AppLoadingIndicator.small(),
                  ],
                ],
              ),
            ),

          // 4. Multi-Hazard Early Warning Overview Card
          RiskSummaryCard(
            riskSummary: data.riskSummary,
            onTap: () => context.push('/risk-map'),
          ),
          const SizedBox(height: 16),

          // 5. Weather & Climatology Forecast Card
          if (data.weatherSummary.current != null || 
              (data.weatherSummary.forecast?.isNotEmpty ?? false)) ...[
            WeatherSummaryCard(
              weatherSummary: data.weatherSummary,
              onTap: () => context.push('/weather'),
            ),
            const SizedBox(height: 16),
          ],

          // 6. Interactive 7-Day Trend Chart
          DashboardTrendChart(dashboardData: data),
          const SizedBox(height: 16),

          // 7. Role-Adaptive Operational KPI Cards (Zero Broken Dashes)
          if (authState.isFarmer) ...[
            _buildFarmSummaryCard(context, data.farmSummary),
            const SizedBox(height: 16),
          ],

          if (authState.isDevelopmentAgent) ...[
            _buildDaKebeleOverviewCard(context, data),
            const SizedBox(height: 16),
          ],

          if (authState.isOfficer) ...[
            _buildJurisdictionAggregateCard(context, authState, data),
            const SizedBox(height: 16),
          ],

          if (authState.isResearcher) ...[
            _buildResearcherInsightsCard(context, data),
            const SizedBox(height: 16),
          ],

          // 8. Active Crop Distribution Card
          CropDistributionCard(farmSummary: data.farmSummary),
          const SizedBox(height: 16),

          // 9. Recent Smart Alerts Feed
          RecentAlertsCard(
            alerts: data.recentAlerts,
            onViewAll: () => context.push('/alerts'),
            onAlertTap: (alert) => context.push('/alerts/${alert.id}'),
          ),
          const SizedBox(height: 16),

          // 10. Role-Tailored Quick Actions Grid
          _buildQuickActions(context, authState),
          const SizedBox(height: 16),

          // 11. System Health & Platform Integrity (for Officers and Admin)
          if (authState.canViewSystemHealth || authState.isOfficer || authState.isAdmin) ...[
            _buildSystemHealthCard(context, data.systemHealth),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final user = authState.user;
    final greeting = _getGreeting();
    final roleColor = _getRoleColor(user?.role);
    final isDark = theme.brightness == Brightness.dark;

    // Build administrative location breadcrumb
    final List<String> locationParts = [];
    final reg = user?.region?.name ?? user?.regionId;
    final zon = user?.zone?.name ?? user?.zoneId;
    final wor = user?.woreda?.name ?? user?.woredaId;
    final keb = user?.kebeleName ?? user?.kebele?.name ?? user?.kebeleId;
    if (reg != null && reg.isNotEmpty) locationParts.add(reg);
    if (zon != null && zon.isNotEmpty) locationParts.add(zon);
    if (wor != null && wor.isNotEmpty) locationParts.add(wor);
    if (keb != null && keb.isNotEmpty) locationParts.add(keb);

    final locationText = locationParts.isNotEmpty
        ? locationParts.join(' • ')
        : 'National Agronomic Network • Ethiopia';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2E1B) : const Color(0xFFF1F8F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2EFE2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${user?.fullName ?? 'User'}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E2E1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _getRoleDescription(authState),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  RoleUtils.getRoleDisplayName(user?.role),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: isDark ? const Color(0xFF4ADE80) : AppTheme.primaryDark,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  locationText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF4ADE80) : AppTheme.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgroTelemetryStrip(BuildContext context, DashboardData data) {
    final telemetry = data.telemetry;
    final isStressed = telemetry.status == 'ELEVATED RISK';
    final statusColor = isStressed ? const Color(0xFFEF4444) : AppTheme.telemetryNdvi;

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
              Expanded(
                child: Row(
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
                    const Flexible(
                      child: Text(
                        'SATELLITE & IOT TELEMETRY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 6),
                    const SizedBox(width: 4),
                    Text(
                      telemetry.status,
                      style: TextStyle(
                        color: statusColor,
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
                value: telemetry.averageNdvi.toStringAsFixed(2),
                unit: 'Index',
                icon: Icons.eco,
                color: AppTheme.telemetryNdvi,
              ),
              Container(height: 32, width: 1, color: Colors.white12),
              _buildTelemetryMetric(
                label: 'Soil Moisture',
                value: telemetry.soilMoisture.toStringAsFixed(1),
                unit: '% Vol',
                icon: Icons.water_drop,
                color: const Color(0xFF38BDF8),
              ),
              Container(height: 32, width: 1, color: Colors.white12),
              _buildTelemetryMetric(
                label: 'Drought Risk',
                value: telemetry.droughtRisk,
                unit: 'Status',
                icon: Icons.wb_sunny_outlined,
                color: _getRiskColor(telemetry.droughtRisk),
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

  /// Farm summary card for Farmers
  Widget _buildFarmSummaryCard(BuildContext context, FarmSummary farmSummary) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/farms'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.agriculture, color: Color(0xFF16A34A), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'My Farm Plots',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
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
                    icon: Icons.sensors,
                    label: 'IoT Sensors',
                    value: farmSummary.activeSensors.toString(),
                  ),
                  _StatItem(
                    icon: Icons.warning_amber,
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

  /// DA-specific: Supervised Kebele Overview Card
  Widget _buildDaKebeleOverviewCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final metrics = data.jurisdictionMetrics;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: const Icon(Icons.groups_outlined, color: Color(0xFF0D9488), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kebele Extension Overview',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.person_outline,
                  label: 'Supervised\nFarmers',
                  value: metrics.totalFarmers.toString(),
                ),
                _StatItem(
                  icon: Icons.warning_amber,
                  label: 'Farms\nAt Risk',
                  value: metrics.farmsAtRisk.toString(),
                  valueColor: metrics.farmsAtRisk > 0 ? AppTheme.warningColor : Colors.green,
                ),
                _StatItem(
                  icon: Icons.assignment_outlined,
                  label: 'Field Visits\nThis Week',
                  value: metrics.fieldVisitsThisWeek.toString(),
                ),
                _StatItem(
                  icon: Icons.sensors,
                  label: 'Supervised\nSensors',
                  value: metrics.activeSensors.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Officer-specific: Jurisdiction Aggregate Card
  Widget _buildJurisdictionAggregateCard(BuildContext context, AuthState authState, DashboardData data) {
    final theme = Theme.of(context);
    final scopeLabel = authState.jurisdictionLevel;
    final metrics = data.jurisdictionMetrics;

    String scopeTitle;
    IconData scopeIcon;
    Color scopeColor;

    switch (scopeLabel) {
      case 'WOREDA':
        scopeTitle = 'Woreda Command Overview';
        scopeIcon = Icons.location_city_outlined;
        scopeColor = const Color(0xFF1E40AF);
        break;
      case 'ZONE':
        scopeTitle = 'Zonal Operational Aggregate';
        scopeIcon = Icons.account_balance_outlined;
        scopeColor = const Color(0xFF7C3AED);
        break;
      case 'REGION':
        scopeTitle = 'Regional Operations Hub';
        scopeIcon = Icons.flag_outlined;
        scopeColor = const Color(0xFFBE185D);
        break;
      default:
        scopeTitle = 'National Operations Hub';
        scopeIcon = Icons.public;
        scopeColor = const Color(0xFFD97706);
    }

    final activeAlertsCount = data.riskSummary.highRisk + data.riskSummary.criticalRisk;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: Icon(scopeIcon, color: scopeColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scopeTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.people_outline,
                  label: 'Registered\nFarmers',
                  value: metrics.totalFarmers.toString(),
                ),
                _StatItem(
                  icon: Icons.notifications_active,
                  label: 'Active\nEarly Warnings',
                  value: activeAlertsCount.toString(),
                  valueColor: activeAlertsCount > 0 ? AppTheme.warningColor : Colors.green,
                ),
                _StatItem(
                  icon: Icons.sensors,
                  label: 'Active\nSensors',
                  value: metrics.activeSensors.toString(),
                ),
                _StatItem(
                  icon: Icons.square_foot,
                  label: 'Monitored\nLand',
                  value: '${metrics.monitoredHectares.toStringAsFixed(0)} ha',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Researcher-specific: Data Insights Card
  Widget _buildResearcherInsightsCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final metrics = data.jurisdictionMetrics;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  child: const Icon(Icons.science_outlined, color: Color(0xFF4338CA), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Earth Engine & Research Insights',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const _StatItem(
                  icon: Icons.satellite_alt,
                  label: 'GEE\nDatasets',
                  value: '6',
                ),
                _StatItem(
                  icon: Icons.cloud_sync,
                  label: 'Ingested\nObservations',
                  value: '${metrics.satelliteObservationsCount}+',
                ),
                const _StatItem(
                  icon: Icons.timeline,
                  label: 'Time Series\nHorizon',
                  value: '5yr',
                ),
                const _StatItem(
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
              label: const Text('Open Scientific Analytics & Data Export'),
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

  Widget _buildQuickActions(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final actions = <Map<String, dynamic>>[];

    actions.add({
      'icon': Icons.map,
      'label': 'Risk Map',
      'onTap': () => context.push('/risk-map'),
    });

    if (authState.isFarmer) {
      actions.add({
        'icon': Icons.add_location_alt,
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
        'label': 'Weather Forecast',
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
        'label': 'Broadcast Alert',
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
        'label': 'Analytics Hub',
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.responsive(compact: 3, medium: 4, expanded: 6),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Platform System Integrity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isHealthy ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isHealthy ? 'HEALTHY' : 'DEGRADED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isHealthy ? Colors.green : Colors.red,
                    ),
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
                  label: 'Data Points Today',
                  value: health.dataPointsToday.toString(),
                ),
                const _StatItem(
                  icon: Icons.dns,
                  label: 'API Gateway',
                  value: '99.9%',
                  valueColor: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
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
      return 'Monitor your farm plots and receive smart alerts';
    } else if (authState.isDevelopmentAgent) {
      return 'Support farmers in your kebele and manage field operations';
    } else if (authState.isWoredaOfficer) {
      return 'Manage alerts and monitor hazards across your woreda';
    } else if (authState.isZonalOfficer) {
      return 'Oversee woredas and coordinate zonal response';
    } else if (authState.isRegionalOfficer) {
      return 'Regional strategic early warning and hazard intelligence';
    } else if (authState.isResearcher) {
      return 'Analyze satellite observations, models, and crop trends';
    } else if (authState.isAdmin) {
      return 'National early warning system oversight and platform operations';
    }
    return 'Welcome to EthioFarm Early Warning Platform';
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

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFD97706);
      case UserRole.regionalOfficer:
        return const Color(0xFFBE185D);
      case UserRole.zonalOfficer:
        return const Color(0xFF7C3AED);
      case UserRole.woredaOfficer:
        return const Color(0xFF1E40AF);
      case UserRole.developmentAgent:
        return const Color(0xFF0D9488);
      case UserRole.researcher:
        return const Color(0xFF4338CA);
      case UserRole.farmer:
      default:
        return AppTheme.primaryDark;
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
      case 'RED':
        return Colors.red;
      case 'HIGH':
      case 'ORANGE':
        return Colors.deepOrange;
      case 'MODERATE':
      case 'YELLOW':
        return Colors.amber.shade700;
      case 'LOW':
      case 'GREEN':
      default:
        return AppTheme.lowRiskColor;
    }
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

    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.primaryColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                size: 28,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
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
