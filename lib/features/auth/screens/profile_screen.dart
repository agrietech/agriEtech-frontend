import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = user?.fullName ?? 'Agricultural User';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final userPhone = user?.phone ?? 'Not registered';
    final userEmail = user?.email ?? 'None';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      drawer: const AgriEtechAppDrawer(),
      appBar: AppBar(
        title: Text(
          AppStrings.tr('profile', lang: currentLang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        child: Column(
          children: [
            // ─── User Profile Card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppTheme.naturalHeroGradient,
                borderRadius: AppRadii.roundedXl,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    userName,
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadii.roundedXl,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFF4ADE80), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          userRole,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.screenPadding),

            // ─── Contact Information ────────────────────────────────────
            _buildSection(
              context,
              title: 'Account Information',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
              children: [
                _buildInfoRow(
                  icon: Icons.phone_android_rounded,
                  label: AppStrings.tr('phoneNumber', lang: currentLang),
                  value: userPhone,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: AppStrings.tr('emailAddress', lang: currentLang),
                  value: userEmail,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Administrative Jurisdiction ────────────────────────────
            _buildSection(
              context,
              title: AppStrings.tr('jurisdiction', lang: currentLang),
              icon: Icons.location_on_outlined,
              isDark: isDark,
              children: [
                _buildInfoRow(
                  icon: Icons.public_rounded,
                  label: 'Region',
                  value: user?.region?.name ?? 'National Scope',
                  isDark: isDark,
                ),
                if (user?.zone != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.map_outlined,
                    label: 'Zone',
                    value: user!.zone!.name,
                    isDark: isDark,
                  ),
                ],
                if (user?.woreda != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.holiday_village_outlined,
                    label: 'Woreda',
                    value: user!.woreda!.name,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Language & Localization ────────────────────────────────
            _buildSection(
              context,
              title: AppStrings.tr('language', lang: currentLang),
              icon: Icons.language_rounded,
              isDark: isDark,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('lang_$currentLang'),
                  initialValue: currentLang,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    filled: true,
                    fillColor: isDark ? AppTheme.cardDark : Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English (International)')),
                    DropdownMenuItem(value: 'am', child: Text('አማርኛ (Amharic)')),
                    DropdownMenuItem(value: 'om', child: Text('Afaan Oromoo (Oromo)')),
                    DropdownMenuItem(value: 'ti', child: Text('ትግርኛ (Tigrinya)')),
                    DropdownMenuItem(value: 'so', child: Text('Soomaali (Somali)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(appLocaleProvider.notifier).state = val;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Security & Role Upgrades ───────────────────────────────
            _buildSection(
              context,
              title: AppStrings.tr('security', lang: currentLang),
              icon: Icons.security_rounded,
              isDark: isDark,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: const Icon(Icons.assignment_ind_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                  title: Text(
                    AppStrings.tr('applyForRole', lang: currentLang),
                    style: AppTypography.subtitle,
                  ),
                  subtitle: Text('Upgrade jurisdictional administrative scope', style: AppTypography.caption.copyWith(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => context.push('/apply-role'),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withValues(alpha: 0.12),
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  title: Text(
                    AppStrings.tr('changePassword', lang: currentLang),
                    style: AppTypography.subtitle,
                  ),
                  subtitle: Text('Update login authentication credentials', style: AppTypography.caption.copyWith(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () => context.push('/change-password'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ─── Sign Out Action ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
                label: Text(
                  AppStrings.tr('signOut', lang: currentLang),
                  style: AppTypography.subtitle.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.4)),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedLg),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF14532D)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.subtitle,
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
