import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/models/dashboard_models.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../alerts/models/alert_models.dart';
import '../../weather/providers/weather_provider.dart';
import 'main_navigation_shell.dart';

/// Unified Executive Agricultural Command Center for EthioFarm Platform
/// Enterprise-grade, expert design fully bound to live telemetry, weather, and alerts backend.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _homeRefreshTimer;
  String _selectedAppCategory = 'all';

  @override
  void initState() {
    super.initState();
    // Proactively initialize dashboard telemetry if not yet cached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashState = ref.read(dashboardProvider);
      if (dashState.data == null && !dashState.isLoading) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });

    // Auto-refresh telemetry every 60 seconds
    _homeRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        ref.read(dashboardProvider.notifier).refreshDashboard();
      }
    });
  }

  @override
  void dispose() {
    _homeRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await Future.wait([
      ref.read(dashboardProvider.notifier).refreshDashboard(),
      ref.read(alertListProvider.notifier).fetchAlerts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final userName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Agronomist';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dashState = ref.watch(dashboardProvider);
    final data = dashState.data;

    final alertsAsync = ref.watch(alertListProvider);
    final activeAlerts = alertsAsync.maybeWhen(
      data: (list) => list.where((a) => a.isActive && !a.isRead).toList(),
      orElse: () => <AlertModel>[],
    );

    return Scaffold(
      drawer: const EthioFarmAppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const EthioFarmLogo.horizontal(size: 28, showTagline: false),
        actions: [
          // Language switcher button
          Semantics(
            button: true,
            label: 'Change language. Current: ${AppLanguages.byCode(currentLang).englishName}',
            child: Tooltip(
              message: AppLanguages.byCode(currentLang).pickerLabel,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  LanguageSelector.show(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B3821) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.primaryLight : const Color(0xFF16A34A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 14,
                        color: isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLanguages.byCode(currentLang).shortLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 14,
                        color: isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Live Alert Bell with Badge
          IconButton(
            icon: Badge(
              isLabelVisible: activeAlerts.isNotEmpty,
              label: Text(
                '${activeAlerts.length}',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppTheme.errorColor,
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            tooltip: context.tr('alerts'),
            onPressed: () {
              HapticFeedback.lightImpact();
              NavigationHelper.navigateOrSwitchTab(context, ref, '/alerts');
            },
          ),

          // User Profile Avatar with Menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? const Color(0xFF1B3821) : const Color(0xFFDCFCE7),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
            offset: const Offset(0, 48),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'profile',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle, color: Color(0xFF14532D), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('  $userRole', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const Divider(height: 14),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile_view',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, color: Color(0xFF14532D), size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('profile'), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'role',
                child: Row(
                  children: [
                    const Icon(Icons.assignment_ind_rounded, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('role'), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('signOut'), style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              HapticFeedback.lightImpact();
              if (value == 'logout') {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              } else if (value == 'profile' || value == 'profile_view') {
                context.push('/profile');
              } else if (value == 'role') {
                context.push('/apply-role');
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primaryColor,
        backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 1. Obsidian Glassmorphic Operations Hero ─────────────
              _buildCommandCenterHero(context, ref, authState, data, userName, userRole, isDark),

              // ─── Offline / Sync Issue Alert Banner (if error) ─────────
              if (dashState.hasError && data == null)
                _buildSyncErrorNotice(dashState.error?.message ?? 'Connecting to telemetry service...', isDark),

              // ─── 2. Active Hazard Smart Alert Ribbon ──────────────────
              _buildHazardStatusRibbon(context, ref, activeAlerts, data, isDark),

              // ─── 2b. Smart Agricultural Intelligence Command Hub ──────
              _buildSmartIntelligenceHubCard(context, ref, isDark),

              // ─── 3. Live Satellite & IoT Telemetry Matrix (HUD) ───────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dashState.lastUpdated != null
                            ? 'LIVE SATELLITE & IOT HUD • Synced ${DateFormatter.formatRelativeTime(dashState.lastUpdated!)}'
                            : 'LIVE SATELLITE & IOT HUD',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isDark ? AppTheme.telemetryNdvi : const Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTelemetryHUD(context, ref, data, isDark, isLoading: dashState.isLoading),

              // ─── 4. High-Impact Quick Action Command Matrix ───────────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
                child: Text(
                  'COMMAND ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                  ),
                ),
              ),
              _buildQuickActionsMatrix(context, ref, isDark),

              // ─── 5. Agro-Climatic Intelligence & Forecast Strip ───────
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'AGRONOMIC CLIMATOLOGY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildClimatologySnapshotCard(context, ref, data, isDark),

              // ─── 6. Enterprise Categorized Operations & App Matrix ────
              _buildEnterpriseAppDirectory(context, ref, authState, activeAlerts.length, isDark),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 1. Command Center Hero ──────────────────────────────────────

  Widget _buildCommandCenterHero(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    DashboardData? data,
    String userName,
    String userRole,
    bool isDark,
  ) {
    final user = authState.user;
    final jurisdiction = _getJurisdictionLabel(user);
    final timeGreeting = _getTimeOfDayGreeting();
    final roleColor = _getRoleBadgeColor(user?.role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.obsidianGradient : AppTheme.naturalHeroGradient,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.borderDark : const Color(0xFF15803D).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry Pulse & Live Status Ribbon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SENTINEL-2 & LORAWAN ONLINE',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (jurisdiction.isNotEmpty)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.white70),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          jurisdiction,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Executive Welcome & Identity
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$timeGreeting,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Role Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.2),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: roleColor.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_rounded, size: 12, color: roleColor),
                    const SizedBox(width: 4),
                    Text(
                      userRole.toUpperCase(),
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Docked Hero KPI Strip (Glassmorphic)
          _buildHeroKpiStrip(context, data, isDark, isLoading: data == null),
        ],
      ),
    );
  }

  /// Docked Hero KPI strip giving instant operational status
  Widget _buildHeroKpiStrip(BuildContext context, DashboardData? data, bool isDark, {bool isLoading = false}) {
    final totalArea = data != null && data.farmSummary.totalArea > 0
        ? '${data.farmSummary.totalArea.toStringAsFixed(1)} ha'
        : (data != null && data.jurisdictionMetrics.monitoredHectares > 0
            ? '${data.jurisdictionMetrics.monitoredHectares.toStringAsFixed(1)} ha'
            : (isLoading ? '--' : '0.0 ha'));

    final totalFarms = data != null && data.farmSummary.totalFarms > 0
        ? '${data.farmSummary.totalFarms}'
        : (data != null && data.jurisdictionMetrics.totalFarmers > 0
            ? '${data.jurisdictionMetrics.totalFarmers}'
            : (isLoading ? '--' : '0'));

    final activeSensors = data != null && data.farmSummary.activeSensors > 0
        ? '${data.farmSummary.activeSensors}'
        : (data != null && data.jurisdictionMetrics.activeSensors > 0
            ? '${data.jurisdictionMetrics.activeSensors}'
            : (isLoading ? '--' : '0'));

    final systemStatus = data?.systemHealth.status ?? (isLoading ? 'SYNCING' : 'OPERATIONAL');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildHeroKpiItem(icon: Icons.map_outlined, label: 'Monitored', value: totalArea),
          _buildHeroDivider(),
          _buildHeroKpiItem(icon: Icons.agriculture_rounded, label: 'Active Plots', value: totalFarms),
          _buildHeroDivider(),
          _buildHeroKpiItem(icon: Icons.sensors_rounded, label: 'IoT Probes', value: activeSensors),
          _buildHeroDivider(),
          _buildHeroKpiItem(
            icon: Icons.cloud_done_rounded,
            label: 'Telemetry',
            value: systemStatus,
            valueColor: const Color(0xFF86EFAC),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroKpiItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: Colors.white70),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDivider() {
    return Container(
      width: 1,
      height: 22,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  // ─── 2. Hazard Emergency / Stability Banner ──────────────────────

  Widget _buildHazardStatusRibbon(
    BuildContext context,
    WidgetRef ref,
    List<AlertModel> activeAlerts,
    DashboardData? data,
    bool isDark,
  ) {
    if (activeAlerts.isNotEmpty) {
      final primaryAlert = activeAlerts.first;
      final severity = primaryAlert.severity.toUpperCase();
      final isCritical = severity == 'CRITICAL';
      final ribbonColor = isCritical ? AppTheme.criticalRiskColor : AppTheme.highRiskColor;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? (isCritical ? const Color(0xFF2A0F0F) : const Color(0xFF2B1B0E))
              : (isCritical ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED)),
          border: Border(
            bottom: BorderSide(
              color: isDark ? ribbonColor.withValues(alpha: 0.4) : ribbonColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            NavigationHelper.navigateOrSwitchTab(context, ref, '/alerts');
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ribbonColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.crisis_alert_rounded, color: ribbonColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: ribbonColor,
                            borderRadius: AppRadii.roundedXs,
                          ),
                          child: Text(
                            severity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'ACTIVE EMERGENCY ALERT (${activeAlerts.length})',
                            style: TextStyle(
                              color: ribbonColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      primaryAlert.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF7F1D1D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: ribbonColor, size: 20),
            ],
          ),
        ),
      );
    }

    // Reassuring normal status banner when no alerts exist
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF102816) : const Color(0xFFF0FDF4),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1D4525) : const Color(0xFFDCFCE7),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          NavigationHelper.navigateOrSwitchTab(context, ref, '/risks');
        },
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Agro-Climatic Stability: All monitored woredas in normal range',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16A34A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '3D GIS Map >',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 3. Telemetry HUD — Live Backend Data ─────────────────────────

  Widget _buildTelemetryHUD(
    BuildContext context,
    WidgetRef ref,
    DashboardData? data,
    bool isDark, {
    bool isLoading = false,
  }) {
    final weatherState = ref.watch(weatherProvider);

    // 1. NDVI Health (Sentinel-2)
    final ndvi = data?.telemetry.averageNdvi;
    final ndviValue = ndvi != null && ndvi > 0
        ? ndvi.toStringAsFixed(2)
        : (isLoading ? '...' : '--');
    final ndviBadge = ndvi != null && ndvi > 0
        ? _ndviConditionBadge(ndvi)
        : (isLoading ? 'SYNCING' : 'NO DATA');
    final ndviColor = ndvi != null && ndvi > 0
        ? _ndviConditionColor(ndvi)
        : Colors.grey;

    // 2. Soil Moisture & IoT Probes
    final soilMoisture = data?.telemetry.soilMoisture;
    final soilValue = soilMoisture != null && soilMoisture > 0
        ? '${soilMoisture.toStringAsFixed(1)}%'
        : (isLoading ? '--' : 'N/A');
    final activeProbes = data?.farmSummary.activeSensors ?? data?.jurisdictionMetrics.activeSensors ?? 0;
    final soilBadge = activeProbes > 0
        ? '$activeProbes ONLINE'
        : (isLoading ? 'SYNCING' : '0 ONLINE');

    // 3. Climatology & Rain
    final temp = data?.weatherSummary.current?.temperature ?? weatherState.current?.maxTempC;
    final rainfall = data?.weatherSummary.current?.rainfall ?? weatherState.current?.precipitationMm;
    final rainValue = temp != null
        ? '${temp.toStringAsFixed(1)}°C'
        : (isLoading ? '--' : '--');
    final rainBadge = rainfall != null && rainfall > 0
        ? '${rainfall.toStringAsFixed(1)} mm rain'
        : (rainfall != null ? 'DRY' : (isLoading ? 'SYNCING' : 'STABLE'));

    // 4. Composite Hazard Radar
    final critRisks = data?.riskSummary.criticalRisk ?? 0;
    final highRisks = data?.riskSummary.highRisk ?? 0;
    final totalRisks = critRisks + highRisks;
    final riskValue = '$totalRisks Warnings';
    final riskBadge = critRisks > 0 ? 'CRITICAL' : (highRisks > 0 ? 'ELEVATED' : 'STABLE');
    final riskColor = critRisks > 0 ? const Color(0xFFDC2626) : (highRisks > 0 ? const Color(0xFFF97316) : const Color(0xFF10B981));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: context.responsive(compact: 2, medium: 3, expanded: 4),
        mainAxisSpacing: AppSpacing.itemGap,
        crossAxisSpacing: AppSpacing.itemGap,
        childAspectRatio: 1.55,
        children: [
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.satellite_alt_rounded,
            title: 'NDVI Vegetation',
            value: ndviValue,
            badge: ndviBadge,
            badgeColor: ndviColor,
            subtext: 'Sentinel-2 Multi-Spectral',
            route: '/risks',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.water_drop_rounded,
            title: 'Soil Moisture',
            value: soilValue,
            badge: soilBadge,
            badgeColor: const Color(0xFF0284C7),
            subtext: 'LoRaWAN Field Probes',
            route: '/sensors',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.wb_sunny_rounded,
            title: 'Temperature',
            value: rainValue,
            badge: rainBadge,
            badgeColor: const Color(0xFFD97706),
            subtext: data?.weatherSummary.current?.condition ?? 'Partly Cloudy',
            route: '/weather',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.radar_rounded,
            title: 'Hazard Radar',
            value: riskValue,
            badge: riskBadge,
            badgeColor: riskColor,
            subtext: '${data?.riskSummary.totalWoredas ?? 1148} Woredas Monitored',
            route: '/disasters',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _ndviConditionBadge(double ndvi) {
    if (ndvi >= 0.65) return 'OPTIMAL';
    if (ndvi >= 0.50) return 'FAVORABLE';
    if (ndvi >= 0.35) return 'WATCH';
    return 'STRESSED';
  }

  Color _ndviConditionColor(double ndvi) {
    if (ndvi >= 0.65) return const Color(0xFF10B981);
    if (ndvi >= 0.50) return const Color(0xFF22C55E);
    if (ndvi >= 0.35) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  Widget _buildTelemetryCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
    required String subtext,
    required String route,
    required bool isDark,
  }) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () {
        HapticFeedback.lightImpact();
        NavigationHelper.navigateOrSwitchTab(context, ref, route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.14),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Icon(icon, size: 16, color: badgeColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtext,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 4. High-Tech Quick Action Matrix ─────────────────────────────

  Widget _buildQuickActionsMatrix(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final authState = ref.watch(authProvider);
    final canAddFarm = RoleUtils.canManageFarms(authState.user?.role);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 580;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isWide ? 4 : 2,
            mainAxisSpacing: AppSpacing.itemGap,
            crossAxisSpacing: AppSpacing.itemGap,
            childAspectRatio: isWide ? 2.0 : 1.7,
            children: [
              _buildTactileActionCard(
                context,
                icon: Icons.camera_alt_rounded,
                title: context.tr('scanCrop'),
                subtitle: 'AI Crop Diagnostics',
                accentColor: const Color(0xFF16A34A),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/create-diagnosis');
                },
                isDark: isDark,
              ),
              _buildTactileActionCard(
                context,
                icon: Icons.smart_toy_rounded,
                title: context.tr('voiceAi'),
                subtitle: 'Bilingual AI Agronomist',
                accentColor: const Color(0xFF0D9488),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/ai-assistant');
                },
                isDark: isDark,
              ),
              _buildTactileActionCard(
                context,
                icon: Icons.wb_sunny_rounded,
                title: context.tr('weather'),
                subtitle: 'Microclimate & Rain',
                accentColor: const Color(0xFF0284C7),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/weather');
                },
                isDark: isDark,
              ),
              _buildTactileActionCard(
                context,
                icon: canAddFarm ? Icons.add_location_alt_rounded : Icons.map_rounded,
                title: canAddFarm ? 'Register Plot' : context.tr('risks'),
                subtitle: canAddFarm ? 'GPS Polygon Mapping' : 'Spatial Hazard Radar',
                accentColor: const Color(0xFF2563EB),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(canAddFarm ? '/farms/add' : '/risks');
                },
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTactileActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Climatology & Agronomic Advisory Card ─────────────────────

  Widget _buildClimatologySnapshotCard(
    BuildContext context,
    WidgetRef ref,
    DashboardData? data,
    bool isDark,
  ) {
    final weatherState = ref.watch(weatherProvider);
    final curWeather = data?.weatherSummary.current;
    final liveWeather = weatherState.current;

    final temp = curWeather?.temperature ?? liveWeather?.maxTempC;
    final humidity = curWeather?.humidity ?? liveWeather?.relativeHumidity;
    final wind = curWeather?.windSpeed ?? liveWeather?.windSpeedKmh;
    final rainfall = curWeather?.rainfall ?? liveWeather?.precipitationMm;
    final condition = curWeather?.condition ?? liveWeather?.description ?? 'Optimal Crop Climate';
    final forecastList = data?.weatherSummary.forecast ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(14),
        onTap: () {
          HapticFeedback.lightImpact();
          NavigationHelper.navigateOrSwitchTab(context, ref, '/weather');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.wb_cloudy_rounded, color: Color(0xFF0284C7), size: 18),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Today\'s Microclimate',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Text(
                    condition.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0284C7),
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Weather KPI Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherKpi(
                  icon: Icons.thermostat_rounded,
                  label: 'Temperature',
                  value: temp != null ? '${temp.toStringAsFixed(1)}°C' : '--',
                  isDark: isDark,
                ),
                _buildVerticalKpiDivider(isDark),
                _buildWeatherKpi(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: humidity != null ? '${humidity.toInt()}%' : '--',
                  isDark: isDark,
                ),
                _buildVerticalKpiDivider(isDark),
                _buildWeatherKpi(
                  icon: Icons.air_rounded,
                  label: 'Wind Speed',
                  value: wind != null ? '${wind.toStringAsFixed(0)} km/h' : '--',
                  isDark: isDark,
                ),
                _buildVerticalKpiDivider(isDark),
                _buildWeatherKpi(
                  icon: Icons.cloud_download_outlined,
                  label: 'Rainfall',
                  value: rainfall != null ? '${rainfall.toStringAsFixed(1)} mm' : '0.0 mm',
                  isDark: isDark,
                ),
              ],
            ),

            if (forecastList.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
              const SizedBox(height: 10),
              // Mini 3-Day Forecast Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: forecastList.take(3).map((f) {
                  final dayLabel = _formatDayOfWeek(f.date);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                      borderRadius: AppRadii.roundedSm,
                      border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.wb_sunny_outlined, size: 12, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          '${f.tempMax.toInt()}° / ${f.tempMin.toInt()}°',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),
            // Actionable Agronomic Advisory Callout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                borderRadius: AppRadii.roundedSm,
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final alertsListAsync = ref.watch(alertListProvider);
                        final alerts = alertsListAsync.asData?.value ?? [];
                        final advisoryMsg = alerts.isNotEmpty
                            ? 'Seasonal Advisory: ${alerts.first.title} - ${alerts.first.message}'
                            : (data != null && data.recentAlerts.isNotEmpty
                                ? 'Seasonal Advisory: ${data.recentAlerts.first.title}'
                                : 'Seasonal Advisory: Favorable agro-climatic conditions for active weeding, fertilizer application, and pest surveillance.');
                        return Text(
                          advisoryMsg,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF15803D),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherKpi({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF0284C7)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalKpiDivider(bool isDark) {
    return Container(
      width: 1,
      height: 24,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }

  // ─── 2b. Smart Agricultural Intelligence Command Hub ─────────────

  Widget _buildSmartIntelligenceHubCard(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF042F1A), Color(0xFF064E3B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.35) : const Color(0xFF16A34A).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Link to Common Nav
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Flexible(
                            child: Text(
                              'SMART AGRI-INTELLIGENCE',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Color(0xFF10B981),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '8 ENGINES',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Autonomous AI Vision, Soil Calibrations & Climatology',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    NavigationHelper.navigateOrSwitchTab(context, ref, '/crop-protection');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open Hub',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal scrolling rail of all 8 engines
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildEngineQuickPill(context, ref, icon: Icons.biotech_rounded, label: 'Disease Doctor', tag: 'Pathology', color: const Color(0xFF059669), route: '/create-diagnosis', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.smart_toy_rounded, label: 'Voice Agronomist', tag: 'Bilingual', color: const Color(0xFF0284C7), route: '/ai-assistant', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.grass_rounded, label: 'Weed Detector', tag: 'AI Vision', color: const Color(0xFF16A34A), route: '/crop-protection/weed-detector', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.air_rounded, label: 'Spray Radar', tag: 'Weather', color: const Color(0xFF0284C7), route: '/crop-protection/spray-window', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.energy_savings_leaf_rounded, label: 'Nutrient Scan', tag: 'Chlorosis', color: const Color(0xFFD97706), route: '/crop-protection/nutrient-scanner', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.bug_report_rounded, label: 'Pest Scout', tag: 'ETL Engine', color: const Color(0xFFDC2626), route: '/crop-protection/pest-scout', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.science_rounded, label: 'Tank-Mix', tag: 'W-A-L-E-S', color: const Color(0xFF9333EA), route: '/crop-protection/tank-mix', isDark: isDark),
                  _buildEngineQuickPill(context, ref, icon: Icons.straighten_rounded, label: 'Seed Calc', tag: 'Timad/Ha', color: const Color(0xFF0D9488), route: '/crop-protection/seed-calculator', isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineQuickPill(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String tag,
    required Color color,
    required String route,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          NavigationHelper.navigateOrSwitchTab(context, ref, route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 6. Enterprise Categorized Operations & App Matrix ────────────

  Widget _buildEnterpriseAppDirectory(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    int activeAlertCount,
    bool isDark,
  ) {
    final user = authState.user;

    final allItems = [
      // Smart AI Suite (8)
      const _EnterpriseAppItem(
        id: 'ai_weed',
        label: 'Weed Detector',
        amharicLabel: 'የአረም መለያ',
        subtitle: 'Knapsack Dilutions & Herbicides',
        icon: Icons.grass_rounded,
        color: Color(0xFF16A34A),
        category: 'ai',
        tag: 'AI VISION',
        route: '/crop-protection/weed-detector',
      ),
      const _EnterpriseAppItem(
        id: 'ai_spray',
        label: 'Spray Radar',
        amharicLabel: 'የርጭት አየር ሁኔታ',
        subtitle: 'Drift Risk & Rain Window',
        icon: Icons.air_rounded,
        color: Color(0xFF0284C7),
        category: 'ai',
        tag: 'RADAR',
        route: '/crop-protection/spray-window',
      ),
      const _EnterpriseAppItem(
        id: 'ai_nutrient',
        label: 'Nutrient Scanner',
        amharicLabel: 'የቅጠል ንጥረ-ነገር',
        subtitle: 'Leaf Chlorosis & Top-Dressing',
        icon: Icons.energy_savings_leaf_rounded,
        color: Color(0xFFD97706),
        category: 'ai',
        tag: 'SOIL/NPSB',
        route: '/crop-protection/nutrient-scanner',
      ),
      const _EnterpriseAppItem(
        id: 'ai_pest',
        label: 'Pest Scout & ETL',
        amharicLabel: 'የተባይ ቅኝት',
        subtitle: 'Economic Injury Thresholds',
        icon: Icons.bug_report_rounded,
        color: Color(0xFFDC2626),
        category: 'ai',
        tag: 'ETL',
        route: '/crop-protection/pest-scout',
      ),
      const _EnterpriseAppItem(
        id: 'ai_tank_mix',
        label: 'Tank-Mix Validator',
        amharicLabel: 'የኬሚካል ቅልቅል',
        subtitle: 'W-A-L-E-S Mixing Sequence',
        icon: Icons.science_rounded,
        color: Color(0xFF9333EA),
        category: 'ai',
        tag: 'W-A-L-E-S',
        route: '/crop-protection/tank-mix',
      ),
      const _EnterpriseAppItem(
        id: 'ai_seed_calc',
        label: 'Seed Calculator',
        amharicLabel: 'የዘር መጠን አስሊ',
        subtitle: 'Certified Kg / Timad & Ha',
        icon: Icons.straighten_rounded,
        color: Color(0xFF0D9488),
        category: 'ai',
        tag: 'TIMAD/HA',
        route: '/crop-protection/seed-calculator',
      ),
      _EnterpriseAppItem(
        id: 'ai_crop_doctor',
        label: context.tr('diagnosis'),
        amharicLabel: 'የሰብል በሽታ መለያ',
        subtitle: 'Leaf Pathology Diagnostics',
        icon: Icons.biotech_rounded,
        color: const Color(0xFF059669),
        category: 'ai',
        tag: 'PATHOLOGY',
        route: '/diagnosis',
      ),
      const _EnterpriseAppItem(
        id: 'ai_voice',
        label: 'Voice AI',
        amharicLabel: 'ኢትዮፋርም AI',
        subtitle: 'Bilingual Speech & Chat AI',
        icon: Icons.smart_toy_rounded,
        color: Color(0xFF0284C7),
        category: 'ai',
        tag: 'VOICE AI',
        route: '/ai-assistant',
      ),

      // Earth Observation & Climate (5)
      _EnterpriseAppItem(
        id: 'earth_risks',
        label: context.tr('risks'),
        amharicLabel: 'የአደጋ ካርታ',
        subtitle: 'Sentinel-2 Hazard Radar',
        icon: Icons.map_rounded,
        color: const Color(0xFFDC2626),
        category: 'earth',
        tag: 'EARTH',
        route: '/risks',
      ),
      _EnterpriseAppItem(
        id: 'earth_weather',
        label: context.tr('weather'),
        amharicLabel: 'የአየር ሁኔታ',
        subtitle: '7-Day Agronomic Outlook',
        icon: Icons.wb_cloudy_rounded,
        color: const Color(0xFF0284C7),
        category: 'earth',
        tag: 'RADAR',
        route: '/weather',
      ),
      _EnterpriseAppItem(
        id: 'earth_disasters',
        label: context.tr('disasters'),
        amharicLabel: 'የተፈጥሮ አደጋዎች',
        subtitle: 'Drought, Flood & Seismic',
        icon: Icons.thunderstorm_rounded,
        color: const Color(0xFFEA580C),
        category: 'earth',
        tag: 'EARLY WARN',
        route: '/disasters',
      ),
      _EnterpriseAppItem(
        id: 'earth_boundaries',
        label: context.tr('boundaries'),
        amharicLabel: 'ወሰኖች',
        subtitle: 'WMO & Administrative GIS',
        icon: Icons.public_rounded,
        color: const Color(0xFF059669),
        category: 'earth',
        tag: 'WMO',
        route: '/boundaries',
      ),
      _EnterpriseAppItem(
        id: 'earth_alerts',
        label: context.tr('alerts'),
        amharicLabel: 'ማስጠንቀቂያዎች',
        subtitle: 'Active Hazard Dispatcher',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFFD97706),
        category: 'earth',
        tag: 'DISPATCH',
        route: '/alerts',
        badgeCount: activeAlertCount,
      ),

      // Field Operations (4)
      _EnterpriseAppItem(
        id: 'field_farms',
        label: context.tr('farms'),
        amharicLabel: 'የእኔ እርሻዎች',
        subtitle: 'GPS Cadastral Management',
        icon: Icons.agriculture_rounded,
        color: const Color(0xFF15803D),
        category: 'field',
        tag: 'GIS',
        route: '/farms',
        isVisible: (u, auth) => RoleUtils.canManageFarms(u?.role),
      ),
      _EnterpriseAppItem(
        id: 'field_sensors',
        label: context.tr('sensors'),
        amharicLabel: 'ሴንሰሮች',
        subtitle: 'LoRaWAN Soil Probes',
        icon: Icons.sensors_rounded,
        color: const Color(0xFF7C3AED),
        category: 'field',
        tag: 'LoRaWAN',
        route: '/sensors',
        isVisible: (u, auth) => auth.canManageSensors,
      ),
      _EnterpriseAppItem(
        id: 'field_register_plot',
        label: 'Plot Survey',
        amharicLabel: 'አዲስ ማሳ መመዝገቢያ',
        subtitle: 'Polygon Boundary Mapping',
        icon: Icons.add_location_alt_rounded,
        color: const Color(0xFF16A34A),
        category: 'field',
        tag: 'SURVEY',
        route: '/farms/add',
        isVisible: (u, auth) => RoleUtils.canManageFarms(u?.role),
      ),
      const _EnterpriseAppItem(
        id: 'field_crop_protection_suite',
        label: 'Crop Protection Hub',
        amharicLabel: 'የተቀናጀ የሰብል ጥበቃ',
        subtitle: 'Integrated Diagnostic Suite',
        icon: Icons.shield_rounded,
        color: Color(0xFF059669),
        category: 'field',
        tag: 'SUITE',
        route: '/crop-protection',
      ),

      // Executive BI & IAM (4)
      _EnterpriseAppItem(
        id: 'exec_dashboard',
        label: context.tr('dashboard'),
        amharicLabel: 'መቆጣጠሪያ ሰሌዳ',
        subtitle: 'Executive Telemetry Overview',
        icon: Icons.dashboard_rounded,
        color: const Color(0xFF16A34A),
        category: 'executive',
        tag: 'ANALYTICS',
        route: '/dashboard',
      ),
      _EnterpriseAppItem(
        id: 'exec_analytics',
        label: context.tr('analytics'),
        amharicLabel: 'ትንታኔ',
        subtitle: 'Sector BI & Macro Modeling',
        icon: Icons.insights_rounded,
        color: const Color(0xFF4338CA),
        category: 'executive',
        tag: 'BI',
        route: '/analytics',
        isVisible: (u, auth) => RoleUtils.canViewAnalytics(u?.role),
      ),
      _EnterpriseAppItem(
        id: 'exec_ussd',
        label: 'USSD *212#',
        amharicLabel: 'USSD *212#',
        subtitle: 'Smallholder Mobile Broadcast',
        icon: Icons.dialpad_rounded,
        color: const Color(0xFF2563EB),
        category: 'executive',
        tag: 'TELCO',
        route: '/ussd-console',
        isVisible: (u, auth) => auth.canAccessUssdConsole,
      ),
      _EnterpriseAppItem(
        id: 'exec_role',
        label: context.tr('role'),
        amharicLabel: 'የስራ ድርሻ',
        subtitle: 'IAM & Permission Upgrades',
        icon: Icons.assignment_ind_rounded,
        color: const Color(0xFF2563EB),
        category: 'executive',
        tag: 'IAM',
        route: '/apply-role',
      ),
    ];

    final visibleItems = allItems.where((item) {
      if (item.isVisible != null && !item.isVisible!(user, authState)) {
        return false;
      }
      if (_selectedAppCategory == 'all') return true;
      return item.category == _selectedAppCategory;
    }).toList();

    final categories = [
      _CategoryFilter(
        key: 'all',
        label: 'All Operations',
        count: allItems.where((i) => i.isVisible == null || i.isVisible!(user, authState)).length,
      ),
      _CategoryFilter(
        key: 'ai',
        label: 'Smart AI Suite',
        count: allItems.where((i) => i.category == 'ai' && (i.isVisible == null || i.isVisible!(user, authState))).length,
      ),
      _CategoryFilter(
        key: 'earth',
        label: 'Earth & Climate',
        count: allItems.where((i) => i.category == 'earth' && (i.isVisible == null || i.isVisible!(user, authState))).length,
      ),
      _CategoryFilter(
        key: 'field',
        label: 'Field Ops',
        count: allItems.where((i) => i.category == 'field' && (i.isVisible == null || i.isVisible!(user, authState))).length,
      ),
      _CategoryFilter(
        key: 'executive',
        label: 'Executive BI',
        count: allItems.where((i) => i.category == 'executive' && (i.isVisible == null || i.isVisible!(user, authState))).length,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section Title & Active Module Pill
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ENTERPRISE OPERATIONS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  '${visibleItems.length} APPS ACTIVE',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16A34A),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Interactive Category Filter Pills
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.xs, AppSpacing.screenPadding, AppSpacing.sm),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedAppCategory == cat.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedAppCategory = cat.key;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF1E3825) : const Color(0xFFDCFCE7))
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                          width: isSelected ? 1.2 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF14532D))
                                  : (isDark ? Colors.grey.shade300 : const Color(0xFF475569)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF16A34A) : const Color(0xFF15803D))
                                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${cat.count}',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Enterprise App Icon Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.responsive(compact: 3, medium: 4, expanded: 6),
              mainAxisSpacing: AppSpacing.itemGap,
              crossAxisSpacing: AppSpacing.itemGap,
              childAspectRatio: 0.92,
            ),
            itemCount: visibleItems.length,
            itemBuilder: (context, index) {
              return _buildEnterpriseAppCard(context, ref, visibleItems[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnterpriseAppCard(
    BuildContext context,
    WidgetRef ref,
    _EnterpriseAppItem item,
    bool isDark,
  ) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      onTap: () {
        HapticFeedback.lightImpact();
        NavigationHelper.navigateOrSwitchTab(context, ref, item.route);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: item.color.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey.shade100 : const Color(0xFF1E293B),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (item.badgeCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  '${item.badgeCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.tag,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Helpers & Utilities ──────────────────────────────────────────

  Widget _buildSyncErrorNotice(String message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.sm, AppSpacing.screenPadding, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 16, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live telemetry reconnecting ($message)',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.red.shade200 : const Color(0xFF991B1B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(dashboardProvider.notifier).loadDashboard();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.errorColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format jurisdiction breadcrumb safely from user boundaries
  String _getJurisdictionLabel(UserModel? user) {
    if (user == null) return 'National Operations';
    final parts = <String>[];
    if (user.region != null && user.region!.name.isNotEmpty) {
      parts.add(user.region!.name);
    }
    if (user.zone != null && user.zone!.name.isNotEmpty) {
      parts.add(user.zone!.name);
    }
    if (user.woreda != null && user.woreda!.name.isNotEmpty) {
      parts.add(user.woreda!.name);
    }
    final kebele = user.kebeleName ?? user.kebele?.name;
    if (kebele != null && kebele.isNotEmpty) {
      parts.add(kebele);
    }
    if (parts.isEmpty) {
      return 'Federal Democratic Republic of Ethiopia';
    }
    return parts.join(' • ');
  }

  /// Dynamic time of day greeting
  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Role badge color mapping
  Color _getRoleBadgeColor(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF818CF8); // Indigo
      case UserRole.regionalOfficer:
      case UserRole.zonalOfficer:
      case UserRole.woredaOfficer:
        return const Color(0xFF60A5FA); // Blue
      case UserRole.developmentAgent:
        return const Color(0xFF2DD4BF); // Teal
      case UserRole.farmer:
        return const Color(0xFF86EFAC); // Mint Green
      case UserRole.researcher:
        return const Color(0xFFA78BFA); // Violet
      default:
        return const Color(0xFF86EFAC);
    }
  }

  String _formatDayOfWeek(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

/// Model for Classified Enterprise Operations App Icon
class _EnterpriseAppItem {
  final String id;
  final String label;
  final String amharicLabel;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String category; // 'ai', 'earth', 'field', 'executive'
  final String tag;
  final String route;
  final int badgeCount;
  final bool Function(UserModel? user, AuthState authState)? isVisible;

  const _EnterpriseAppItem({
    required this.id,
    required this.label,
    required this.amharicLabel,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.category,
    required this.tag,
    required this.route,
    this.badgeCount = 0,
    this.isVisible,
  });
}

/// Model for Enterprise Category Filter Chip
class _CategoryFilter {
  final String key;
  final String label;
  final int count;

  const _CategoryFilter({
    required this.key,
    required this.label,
    required this.count,
  });
}

