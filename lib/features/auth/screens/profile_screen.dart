import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/l10n/app_languages.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/l10n_extension.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../providers/auth_provider.dart';
import 'verify_phone_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final kebeleController = TextEditingController(text: user?.kebeleName ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF132116) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: Color(0xFF1B5E20), size: 24),
                          SizedBox(width: 8),
                          Text('Edit Profile Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Full Name
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Your legal name',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Email
                  const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'officer@ethiofarm.et',
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Kebele
                  const Text('Kebele Name (Village)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: kebeleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Kebele 01 / Dobi Korme',
                      prefixIcon: const Icon(Icons.holiday_village_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const Key('save_profile_button'),
                      onPressed: isSaving
                          ? null
                          : () async {
                              setSheetState(() => isSaving = true);
                              try {
                                await ref.read(authProvider.notifier).updateProfile({
                                  'fullName': nameController.text.trim(),
                                  'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                                  'kebeleName': kebeleController.text.trim().isEmpty ? null : kebeleController.text.trim(),
                                });
                                if (context.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('Profile updated successfully!'),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF1B5E20),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => isSaving = false);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update: ${e.toString()}'),
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSaving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your EthioFarm agricultural intelligence workspace?',
          style: TextStyle(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = user?.fullName ?? 'Agricultural User';
    final userRole = RoleUtils.getRoleDisplayName(user?.role);
    final userPhone = user?.phone ?? 'Not registered';
    final userEmail = user?.email ?? 'None registered';
    final isPhoneVerified = user?.isPhoneVerified ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      drawer: const EthioFarmAppDrawer(),
      appBar: AppBar(
        title: Text(
          context.tr('profile'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('edit_profile_button'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile Details',
            onPressed: () => _showEditProfileDialog(context, user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        child: Column(
          children: [
            // ─── User Profile Executive Card ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppTheme.naturalHeroGradient,
                borderRadius: AppRadii.roundedXl,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isPhoneVerified ? const Color(0xFF16A34A) : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            isPhoneVerified ? Icons.verified : Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    userName,
                    style: AppTypography.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadii.roundedXl,
                    ),
                    child: InkWell(
                      onTap: () => context.push('/apply-role'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, color: Color(0xFF4ADE80), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            userRole,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.screenPadding),

            // ─── Contact Information ────────────────────────────────────
            _buildSection(
              context,
              title: 'Account & Verification',
              icon: Icons.verified_user_outlined,
              isDark: isDark,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        icon: Icons.phone_android_rounded,
                        label: context.tr('phoneNumber'),
                        value: userPhone,
                        isDark: isDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPhoneVerified
                            ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                            : const Color(0xFFD97706).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: isPhoneVerified
                            ? null
                            : () async {
                                final verified = await VerifyPhoneDialog.show(context, phone: userPhone);
                                if (verified == true) {
                                  ref.read(authProvider.notifier).refreshProfile();
                                }
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPhoneVerified ? Icons.check_circle : Icons.sms_failed_rounded,
                              size: 13,
                              color: isPhoneVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPhoneVerified ? 'Verified' : 'Verify OTP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isPhoneVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: context.tr('emailAddress'),
                  value: userEmail,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Administrative Jurisdiction ────────────────────────────
            _buildSection(
              context,
              title: context.tr('jurisdiction'),
              icon: Icons.location_on_outlined,
              isDark: isDark,
              children: [
                _buildInfoRow(
                  icon: Icons.public_rounded,
                  label: 'Region',
                  value: user?.region?.name ?? 'National Scope (ኢትዮጵያ)',
                  isDark: isDark,
                ),
                if (user?.zone != null || user?.zoneId != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.map_outlined,
                    label: 'Administrative Zone',
                    value: user?.zone?.name ?? user?.zoneId ?? 'Regional Desk',
                    isDark: isDark,
                  ),
                ],
                if (user?.woreda != null || user?.woredaId != null) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.holiday_village_outlined,
                    label: 'Woreda (District)',
                    value: user?.woreda?.name ?? user?.woredaId ?? 'District Scope',
                    isDark: isDark,
                  ),
                ],
                if (user?.kebeleName != null && user!.kebeleName!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.home_work_outlined,
                    label: 'Kebele (Village)',
                    value: user.kebeleName!,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Language & Localization ────────────────────────────────
            _buildSection(
              context,
              title: context.tr('language'),
              icon: Icons.language_rounded,
              isDark: isDark,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('lang_$currentLang'),
                  isExpanded: true,
                  initialValue: currentLang,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    filled: true,
                    fillColor: isDark ? AppTheme.cardDark : Colors.grey.shade50,
                  ),
                  items: [
                    for (final language in AppLanguages.all)
                      DropdownMenuItem(
                        value: language.code,
                        child: Text(
                          language.pickerLabel,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(appLocaleProvider.notifier).state = val;
                      ref.read(authProvider.notifier).updateProfile({'preferredLang': val});
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Appearance ─────────────────────────────────────────────
            _buildSection(
              context,
              title: context.tr('appearance'),
              icon: Icons.brightness_6_rounded,
              isDark: isDark,
              children: [
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_rounded, size: 18),
                      label: Text(context.tr('theme_system')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode_rounded, size: 18),
                      label: Text(context.tr('theme_light')),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_rounded, size: 18),
                      label: Text(context.tr('theme_dark')),
                    ),
                  ],
                  selected: <ThemeMode>{ref.watch(themeModeProvider)},
                  onSelectionChanged: (Set<ThemeMode> selection) {
                    ref.read(themeModeProvider.notifier).state = selection.first;
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ─── Security & Role Upgrades ───────────────────────────────
            _buildSection(
              context,
              title: context.tr('security'),
              icon: Icons.security_rounded,
              isDark: isDark,
              children: [
                InkWell(
                  onTap: () => context.push('/apply-role'),
                  borderRadius: AppRadii.roundedSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.assignment_ind_rounded, color: Color(0xFF2563EB), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('applyForRole'),
                                style: AppTypography.subtitle,
                              ),
                              const SizedBox(height: 2),
                              Text('Apply for Woreda, Zonal, Regional, or Researcher role', style: AppTypography.caption.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 16),
                InkWell(
                  onTap: () => context.push('/change-password'),
                  borderRadius: AppRadii.roundedSm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF64748B).withValues(alpha: 0.12),
                            borderRadius: AppRadii.roundedSm,
                          ),
                          child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('changePassword'),
                                style: AppTypography.subtitle,
                              ),
                              const SizedBox(height: 2),
                              Text('Update authentication password and credentials', style: AppTypography.caption.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ─── Sign Out Action ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
                label: Text(
                  context.tr('signOut'),
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
