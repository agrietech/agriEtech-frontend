import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'mfa_setup_screen.dart';
import 'sessions_list_screen.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final mfaEnabled = user?.mfaEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Security Status Card
          _SecurityStatusCard(mfaEnabled: mfaEnabled),
          
          const SizedBox(height: AppSpacing.lg),

          // Two-Factor Authentication Section
          const _SectionHeader(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Add an extra layer of security to your account',
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: mfaEnabled
                          ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                          : const Color(0xFF0891B2).withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Icon(
                      mfaEnabled ? Icons.check_circle : Icons.qr_code_scanner,
                      color: mfaEnabled
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF0891B2),
                    ),
                  ),
                  title: Text(
                    mfaEnabled
                        ? '2FA Enabled'
                        : 'Enable Two-Factor Authentication',
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: Text(
                    mfaEnabled
                        ? 'Your account is protected with 2FA'
                        : 'Use an authenticator app to protect your account',
                    style: AppTypography.bodySmall,
                  ),
                  trailing: mfaEnabled
                      ? IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey),
                          onPressed: () => _showDisableMfaDialog(context, ref),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: mfaEnabled
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MfaSetupScreen(),
                            ),
                          );
                        },
                ),
                if (mfaEnabled)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'You\'ll need your authenticator app to sign in',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Active Sessions Section
          const _SectionHeader(
            icon: Icons.devices,
            title: 'Active Sessions',
            subtitle: 'Manage devices where you\'re signed in',
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(
                  Icons.devices,
                  color: Color(0xFF7C3AED),
                ),
              ),
              title: const Text(
                'View Active Sessions',
                style: AppTypography.titleMedium,
              ),
              subtitle: const Text(
                'See and manage all devices signed into your account',
                style: AppTypography.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SessionsListScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Password Section
          const _SectionHeader(
            icon: Icons.lock,
            title: 'Password',
            subtitle: 'Keep your account secure',
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: const Icon(
                  Icons.key,
                  color: Color(0xFFD97706),
                ),
              ),
              title: const Text(
                'Change Password',
                style: AppTypography.titleMedium,
              ),
              subtitle: const Text(
                'Update your password regularly',
                style: AppTypography.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/change-password');
              },
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Security Tips
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: const Color(0xFF0891B2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF0891B2),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Security Tips',
                      style: AppTypography.titleSmall.copyWith(
                        color: const Color(0xFF0891B2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SecurityTip('Enable 2FA for maximum account protection'),
                const _SecurityTip('Use a strong, unique password'),
                const _SecurityTip('Review active sessions regularly'),
                const _SecurityTip('Never share your password or backup codes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDisableMfaDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Two-Factor Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will make your account less secure. Enter your password to confirm.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(authProvider.notifier)
                    .disableMfa(passwordController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('2FA disabled successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to disable 2FA: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Disable 2FA'),
          ),
        ],
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  final bool mfaEnabled;

  const _SecurityStatusCard({required this.mfaEnabled});

  @override
  Widget build(BuildContext context) {
    final statusColor = mfaEnabled ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final statusText = mfaEnabled ? 'Excellent' : 'Good';
    final statusMessage = mfaEnabled
        ? 'Your account has strong security protections'
        : 'Enable 2FA to improve your account security';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.1),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            mfaEnabled ? Icons.verified_user : Icons.shield,
            size: 48,
            color: statusColor,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Security Status: $statusText',
            style: AppTypography.titleLarge.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            statusMessage,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey.shade700),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityTip extends StatelessWidget {
  final String text;

  const _SecurityTip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: const Color(0xFF0891B2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
