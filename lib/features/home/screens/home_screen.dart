import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/agrietech_logo.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/widgets/language_selector.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../alerts/providers/alert_provider.dart';
import '../../alerts/models/alert_models.dart';
import 'main_navigation_shell.dart';
import '../widgets/home_command_center_hero.dart';
import '../widgets/home_all_icons_grid.dart';

/// Unified Executive & Smallholder Agricultural Command Center for EthioFarm Platform
/// Automatically adapts between Farmer-First high-touch UX and Officer Geospatial Command Center.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _homeRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Proactively initialize dashboard telemetry & live weather data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashState = ref.read(dashboardProvider);
      if (dashState.data == null && !dashState.isLoading) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });

    // Auto-refresh telemetry & weather every 60 seconds to keep hourly metrics continuously alive
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
    final dashState = ref.watch(dashboardProvider);
    final data = dashState.data;
    final currentLang = ref.watch(appLocaleProvider);
    final userName =
        user?.fullName.isNotEmpty == true ? user!.fullName : 'Agronomist';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            label:
                'Change language. Current: ${AppLanguages.byCode(currentLang).englishName}',
            child: Tooltip(
              message: AppLanguages.byCode(currentLang).pickerLabel,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  LanguageSelector.show(context);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B3821)
                        : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.primaryLight
                          : const Color(0xFF16A34A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 14,
                        color: isDark
                            ? AppTheme.primaryLight
                            : const Color(0xFF14532D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppLanguages.byCode(currentLang).shortLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.primaryLight
                              : const Color(0xFF14532D),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 14,
                        color: isDark
                            ? AppTheme.primaryLight
                            : const Color(0xFF14532D),
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
                style:
                    const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
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
              backgroundColor:
                  isDark ? const Color(0xFF1B3821) : const Color(0xFFDCFCE7),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color:
                      isDark ? AppTheme.primaryLight : const Color(0xFF14532D),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            shape:
                const RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
            offset: const Offset(0, 48),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'profile',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle,
                            color: Color(0xFF14532D), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('  $userRole',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                    const Divider(height: 14),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile_view',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        color: Color(0xFF14532D), size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('profile'),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'role',
                child: Row(
                  children: [
                    const Icon(Icons.assignment_ind_rounded,
                        color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('role'),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded,
                        color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 10),
                    Text(context.tr('signOut'),
                        style: const TextStyle(
                            color: AppTheme.errorColor, fontSize: 13)),
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. Top Hero Command Banner
                  HomeCommandCenterHero(
                    authState: authState,
                    data: data,
                    userName: userName,
                    userRole: userRole,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 8),

                  // ─── 2. All Icons Grid (No Categories or Extra Text) ─
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.sm,
                    ),
                    child: HomeAllIconsGrid(
                      isDark: isDark,
                      activeAlertsCount: activeAlerts.length,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
