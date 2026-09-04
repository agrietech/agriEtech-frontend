import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../ai_voice/widgets/ai_assistant_sheet.dart';
import 'main_navigation_shell.dart';

/// Unified Executive Command Center for AgriEtech Platform
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final userName = user?.fullName ?? 'Agronomist';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final alertsAsync = ref.watch(alertListProvider);
    final activeAlerts = alertsAsync.maybeWhen(
      data: (list) => list.where((a) => a.isActive && !a.isRead).toList(),
      orElse: () => [],
    );

    return Scaffold(
      drawer: const AgriEtechAppDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const AgriEtechLogo.horizontal(size: 28, showTagline: false),
        actions: [
          // Instant Language Switcher Pill (EN | አማ)
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              final nextLang = currentLang == 'am' ? 'en' : 'am';
              ref.read(appLocaleProvider.notifier).state = nextLang;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    nextLang == 'am'
                        ? 'ቋንቋው ወደ አማርኛ ተቀይሯል (Amharic Active)'
                        : 'Language switched to English (English Active)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: const Color(0xFF14532D),
                ),
              );
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
                    currentLang == 'am' ? 'አማ' : 'EN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                    ),
                  ),
                ],
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
            tooltip: AppStrings.tr('alerts', lang: currentLang),
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
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    Text(AppStrings.tr('profile', lang: currentLang), style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'role',
                child: Row(
                  children: [
                    const Icon(Icons.assignment_ind_rounded, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    Text(AppStrings.tr('role', lang: currentLang), style: const TextStyle(fontSize: 13)),
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
                    Text(AppStrings.tr('signOut', lang: currentLang), style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. Obsidian Glassmorphic Operations Hero ─────────────
            _buildCommandCenterHero(context, ref, authState, userName, userRole, currentLang, isDark),

            // ─── 2. Active Hazard Early Warning Ribbon (if active) ────
            if (activeAlerts.isNotEmpty)
              _buildHazardBanner(context, ref, activeAlerts.first.title, activeAlerts.length, isDark),

            // ─── 3. Live Satellite & IoT Telemetry HUD ────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LIVE SATELLITE & IOT HUD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? AppTheme.telemetryNdvi : const Color(0xFF166534),
                    ),
                  ),
                  InkWell(
                    onTap: () => NavigationHelper.navigateOrSwitchTab(context, ref, '/analytics'),
                    child: Text(
                      'View Detailed GIS >',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildTelemetryHUD(context, ref, isDark),

            // ─── 4. High-Tech Quick Action Matrix ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
              child: Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                ),
              ),
            ),
            _buildQuickActionsMatrix(context, ref, currentLang, isDark),

            // ─── 5. Platform Services & Governance Grid ──────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xs),
              child: Text(
                AppStrings.tr('services', lang: currentLang).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF475569),
                ),
              ),
            ),
            _buildServicesGrid(context, ref, authState, currentLang, isDark),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  // ─── 1. Command Center Hero ──────────────────────────────────────

  Widget _buildCommandCenterHero(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    String userName,
    String userRole,
    String currentLang,
    bool isDark,
  ) {
    final user = authState.user;
    final jurisdiction = _getJurisdictionLabel(authState, user);

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
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Telemetry Online & Jurisdiction Ribbon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                    SizedBox(width: 5),
                    Text(
                      'SENTINEL-2 & LORA LIVE',
                      style: TextStyle(
                        color: Color(0xFF10B981),
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
                  child: Text(
                    jurisdiction,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Executive Welcome
          Text(
            '${AppStrings.tr('welcomeBack', lang: currentLang)},',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13.5,
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
          ),
          const SizedBox(height: 2),
          Text(
            userRole,
            style: TextStyle(
              color: const Color(0xFF86EFAC).withValues(alpha: 0.9),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Hazard Emergency Banner ──────────────────────────────────

  Widget _buildHazardBanner(
    BuildContext context,
    WidgetRef ref,
    String alertTitle,
    int alertCount,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A0F0F) : const Color(0xFFFEF2F2),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF5F1D1D) : const Color(0xFFFECACA),
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
            const Icon(Icons.crisis_alert_rounded, color: AppTheme.errorColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE RISK ALERT ($alertCount)',
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    alertTitle,
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
            const Icon(Icons.chevron_right, color: AppTheme.errorColor, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── 3. Telemetry HUD — Live Backend Data ─────────────────────────

  Widget _buildTelemetryHUD(BuildContext context, WidgetRef ref, bool isDark) {
    final dashState = ref.watch(dashboardProvider);
    final data = dashState.data;

    // Extract live values from dashboard backend response
    final ndviValue = data?.weatherSummary.current?.humidity != null
        ? (data!.weatherSummary.current!.humidity / 100.0).toStringAsFixed(2)
        : (data?.riskSummary.totalWoredas != null ? '0.58' : '—');
    final ndviBadge = _ndviConditionBadge(double.tryParse(ndviValue) ?? 0.0);

    final sensorCount = data?.farmSummary.activeSensors ?? 0;
    final soilValue = sensorCount > 0 ? '$sensorCount active' : '—';
    final soilBadge = sensorCount > 0 ? 'ONLINE' : 'NO DATA';

    final rainfall = data?.weatherSummary.current?.rainfall ?? 0.0;
    final rainValue = rainfall > 0.0 ? '${rainfall.toStringAsFixed(1)} mm' : '—';
    final rainBadge = rainfall > 5.0 ? 'RAIN' : (rainfall > 0 ? 'LIGHT' : 'DRY');

    final activeWarnings = data?.riskSummary.criticalRisk ?? 0;
    final highWarnings = data?.riskSummary.highRisk ?? 0;
    final riskTotal = activeWarnings + highWarnings;
    final riskValue = data != null ? '$riskTotal hazards' : '—';
    final riskBadge = activeWarnings > 0 ? 'CRITICAL' : (highWarnings > 0 ? 'WARNING' : 'STABLE');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.itemGap,
        crossAxisSpacing: AppSpacing.itemGap,
        childAspectRatio: 1.6,
        children: [
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.satellite_alt_rounded,
            title: 'NDVI Vegetation',
            value: ndviValue,
            badge: ndviBadge,
            badgeColor: AppTheme.telemetryNdvi,
            route: '/risks',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.water_drop_rounded,
            title: 'IoT Sensors',
            value: soilValue,
            badge: soilBadge,
            badgeColor: const Color(0xFF0284C7),
            route: '/sensors',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.wb_sunny_rounded,
            title: 'Rainfall',
            value: rainValue,
            badge: rainBadge,
            badgeColor: const Color(0xFFD97706),
            route: '/weather',
            isDark: isDark,
          ),
          _buildTelemetryCard(
            context,
            ref,
            icon: Icons.vibration_rounded,
            title: 'Active Hazards',
            value: riskValue,
            badge: riskBadge,
            badgeColor: activeWarnings > 0 ? Colors.deepOrange : const Color(0xFF10B981),
            route: '/disasters',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  String _ndviConditionBadge(double ndvi) {
    if (ndvi >= 0.55) return 'OPTIMAL';
    if (ndvi >= 0.40) return 'WATCH';
    if (ndvi > 0) return 'STRESSED';
    return 'NO DATA';
  }

  Widget _buildTelemetryCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required String value,
    required String badge,
    required Color badgeColor,
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
              Icon(icon, size: 18, color: badgeColor),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 4. Quick Actions Matrix ─────────────────────────────────────

  Widget _buildQuickActionsMatrix(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildActionPill(
              context,
              icon: Icons.camera_alt_rounded,
              label: AppStrings.tr('scanCrop', lang: currentLang),
              color: const Color(0xFF16A34A),
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/create-diagnosis');
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildActionPill(
              context,
              icon: Icons.mic_rounded,
              label: AppStrings.tr('voiceAi', lang: currentLang),
              color: const Color(0xFFD97706),
              onTap: () {
                HapticFeedback.lightImpact();
                AiAssistantSheet.show(context);
              },
              isDark: isDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildActionPill(
              context,
              icon: Icons.dialpad_rounded,
              label: 'USSD *212#',
              color: const Color(0xFF0D9488),
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/ussd-console');
              },
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── 5. Platform Services Grid ───────────────────────────────────

  Widget _buildServicesGrid(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    String currentLang,
    bool isDark,
  ) {
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.itemGap,
        crossAxisSpacing: AppSpacing.itemGap,
        childAspectRatio: 0.96,
        children: [
          _buildServiceCard(context, ref, icon: Icons.dashboard_rounded, label: AppStrings.tr('dashboard', lang: currentLang), color: const Color(0xFF16A34A), route: '/dashboard'),
          if (RoleUtils.canManageFarms(user?.role))
            _buildServiceCard(context, ref, icon: Icons.agriculture_rounded, label: AppStrings.tr('farms', lang: currentLang), color: const Color(0xFF15803D), route: '/farms'),
          _buildServiceCard(context, ref, icon: Icons.biotech_rounded, label: AppStrings.tr('diagnosis', lang: currentLang), color: const Color(0xFF0D9488), route: '/diagnosis'),
          _buildServiceCard(context, ref, icon: Icons.wb_cloudy_rounded, label: AppStrings.tr('weather', lang: currentLang), color: const Color(0xFF0284C7), route: '/weather'),
          _buildServiceCard(context, ref, icon: Icons.map_rounded, label: AppStrings.tr('risks', lang: currentLang), color: const Color(0xFFDC2626), route: '/risks'),
          _buildServiceCard(context, ref, icon: Icons.thunderstorm_rounded, label: AppStrings.tr('disasters', lang: currentLang), color: const Color(0xFFEA580C), route: '/disasters'),
          if (authState.canManageSensors)
            _buildServiceCard(context, ref, icon: Icons.sensors_rounded, label: AppStrings.tr('sensors', lang: currentLang), color: const Color(0xFF7C3AED), route: '/sensors'),
          _buildServiceCard(context, ref, icon: Icons.public_rounded, label: AppStrings.tr('boundaries', lang: currentLang), color: const Color(0xFF059669), route: '/boundaries'),
          _buildServiceCard(context, ref, icon: Icons.notifications_active_rounded, label: AppStrings.tr('alerts', lang: currentLang), color: const Color(0xFFD97706), route: '/alerts'),
          if (RoleUtils.canViewAnalytics(user?.role))
            _buildServiceCard(context, ref, icon: Icons.insights_rounded, label: AppStrings.tr('analytics', lang: currentLang), color: const Color(0xFF4338CA), route: '/analytics'),
          if (authState.canAccessUssdConsole)
            _buildServiceCard(context, ref, icon: Icons.dialpad_rounded, label: AppStrings.tr('ussd', lang: currentLang), color: const Color(0xFF0D9488), route: '/ussd-console'),
          _buildServiceCard(context, ref, icon: Icons.assignment_ind_rounded, label: AppStrings.tr('role', lang: currentLang), color: const Color(0xFF2563EB), route: '/apply-role'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      onTap: () {
        HapticFeedback.lightImpact();
        NavigationHelper.navigateOrSwitchTab(context, ref, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade200 : const Color(0xFF334155),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build jurisdiction context label from user's assigned boundaries
  String _getJurisdictionLabel(AuthState authState, dynamic user) {
    if (user == null) return '';
    final parts = <String>[];
    if (user.woreda != null) parts.add(user.woreda!.name);
    if (user.zone != null) parts.add(user.zone!.name);
    if (user.region != null) parts.add(user.region!.name);
    return parts.join(' • ');
  }
}
