import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/role_utils.dart';
import '../l10n/app_localizations.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/ai_voice/widgets/ai_assistant_sheet.dart';
import '../../features/alerts/providers/alert_provider.dart';
import '../../features/home/screens/main_navigation_shell.dart';

/// Enterprise-grade navigation drawer with structured international-standard hierarchy.
/// Follows Material 3 navigation drawer guidelines with role-adaptive modules.
class AgriEtechAppDrawer extends ConsumerWidget {
  const AgriEtechAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = user?.fullName ?? 'User';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final userPhone = user?.phone ?? '';

    final alertsState = ref.watch(alertListProvider);
    final activeAlertsCount = alertsState.maybeWhen(
      data: (list) => list.where((a) => a.isActive && !a.isRead).length,
      orElse: () => 0,
    );

    return Drawer(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          // ─── Profile Header ─────────────────────────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                context.push('/profile');
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(AppSpacing.lg, MediaQuery.of(context).padding.top + AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppTheme.naturalHeroGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: AppRadius.radiusMd,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: AppTypography.titleLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (userPhone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  userPhone,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 2, vertical: AppSpacing.xxs + 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            userRole,
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Navigation Items ───────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
              children: [
                // ── Operations ──
                _buildSectionLabel(context, 'OPERATIONS'),
                _buildNavTile(context, ref, icon: Icons.dashboard_rounded, label: AppStrings.tr('dashboard', lang: currentLang), route: '/dashboard', color: const Color(0xFF16A34A)),
                if (RoleUtils.canManageFarms(user?.role))
                  _buildNavTile(context, ref, icon: Icons.agriculture_rounded, label: AppStrings.tr('farms', lang: currentLang), route: '/farms', color: const Color(0xFF15803D)),
                _buildNavTile(context, ref, icon: Icons.biotech_rounded, label: AppStrings.tr('diagnosis', lang: currentLang), route: '/diagnosis', color: const Color(0xFF0D9488)),
                _buildNavTile(context, ref, icon: Icons.wb_cloudy_rounded, label: AppStrings.tr('weather', lang: currentLang), route: '/weather', color: const Color(0xFF0284C7)),

                _buildDivider(isDark),

                // ── Intelligence ──
                _buildSectionLabel(context, 'INTELLIGENCE'),
                _buildNavTile(context, ref, icon: Icons.map_rounded, label: AppStrings.tr('risks', lang: currentLang), route: '/risks', color: const Color(0xFFDC2626)),
                _buildNavTile(context, ref, icon: Icons.thunderstorm_rounded, label: AppStrings.tr('disasters', lang: currentLang), route: '/disasters', color: const Color(0xFFEA580C)),
                if (authState.canManageSensors)
                  _buildNavTile(context, ref, icon: Icons.sensors_rounded, label: AppStrings.tr('sensors', lang: currentLang), route: '/sensors', color: const Color(0xFF7C3AED)),
                _buildNavTile(context, ref, icon: Icons.public_rounded, label: AppStrings.tr('boundaries', lang: currentLang), route: '/boundaries', color: const Color(0xFF059669)),

                _buildDivider(isDark),

                // ── Channels ──
                _buildSectionLabel(context, 'CHANNELS'),
                if (RoleUtils.canViewAnalytics(user?.role))
                  _buildNavTile(context, ref, icon: Icons.insights_rounded, label: AppStrings.tr('analytics', lang: currentLang), route: '/analytics', color: const Color(0xFF4338CA)),
                _buildNavTile(
                  context,
                  ref,
                  icon: Icons.notifications_active_rounded,
                  label: AppStrings.tr('alerts', lang: currentLang),
                  route: '/alerts',
                  color: const Color(0xFFD97706),
                  badge: activeAlertsCount,
                ),
                if (authState.canAccessUssdConsole)
                  _buildNavTile(context, ref, icon: Icons.dialpad_rounded, label: AppStrings.tr('ussd', lang: currentLang), route: '/ussd-console', color: const Color(0xFF0D9488)),
                _buildAssistantTile(context, currentLang),

                _buildDivider(isDark),

                // ── Account ──
                _buildSectionLabel(context, 'ACCOUNT'),
                _buildNavTile(context, ref, icon: Icons.person_outline_rounded, label: AppStrings.tr('profile', lang: currentLang), route: '/profile', color: const Color(0xFF14532D)),
                _buildNavTile(context, ref, icon: Icons.assignment_ind_rounded, label: AppStrings.tr('role', lang: currentLang), route: '/apply-role', color: const Color(0xFF2563EB)),
                _buildNavTile(context, ref, icon: Icons.lock_outline_rounded, label: AppStrings.tr('security', lang: currentLang), route: '/change-password', color: const Color(0xFF64748B)),

                const SizedBox(height: AppSpacing.xs),

                // ── Quick Language Switcher (Amharic / English) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(appLocaleProvider.notifier).state = 'en';
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: currentLang == 'en'
                                    ? (isDark ? AppTheme.primaryColor : Colors.white)
                                    : Colors.transparent,
                                borderRadius: AppRadius.radiusSm,
                                boxShadow: currentLang == 'en'
                                    ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    fontWeight: currentLang == 'en' ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                    color: currentLang == 'en'
                                        ? (isDark ? Colors.white : const Color(0xFF14532D))
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(appLocaleProvider.notifier).state = 'am';
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: currentLang == 'am'
                                    ? (isDark ? AppTheme.primaryColor : Colors.white)
                                    : Colors.transparent,
                                borderRadius: AppRadius.radiusSm,
                                boxShadow: currentLang == 'am'
                                    ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'አማርኛ',
                                  style: TextStyle(
                                    fontWeight: currentLang == 'am' ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12,
                                    color: currentLang == 'am'
                                        ? (isDark ? Colors.white : const Color(0xFF14532D))
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // ── Sign Out ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text(AppStrings.tr('signOut', lang: currentLang)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.4)),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Platform Version Footer ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.eco_rounded, size: 14, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  AppStrings.tr('appVersion', lang: currentLang),
                    style: AppTypography.caption.copyWith(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  Widget _buildSectionLabel(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs + 2, AppSpacing.lg, AppSpacing.xxs),
      child: Text(
        title,
          style: AppTypography.overline.copyWith(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
          ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String route,
    required Color color,
    int badge = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentRoute = GoRouterState.of(context).uri.path;
    final isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      child: Material(
        color: isActive
            ? (isDark ? const Color(0xFF1A3A1E) : const Color(0xFFDCFCE7))
            : Colors.transparent,
        borderRadius: AppRadius.radiusMd,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            NavigationHelper.navigateOrSwitchTab(context, ref, route);
          },
          borderRadius: AppRadius.radiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.radiusSm + const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? (isDark ? Colors.white : const Color(0xFF14532D))
                          : (isDark ? Colors.grey.shade300 : const Color(0xFF334155)),
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: AppTypography.overline.copyWith(color: Colors.white),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isActive
                        ? (isDark ? Colors.white54 : const Color(0xFF16A34A))
                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantTile(BuildContext context, String currentLang) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.radiusMd,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            AiAssistantSheet.show(context);
          },
          borderRadius: AppRadius.radiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: AppRadius.radiusSm + const BorderRadius.all(Radius.circular(2)),
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 19),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.tr('assistant', lang: currentLang),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'AI',
                    style: AppTypography.overline.copyWith(
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
