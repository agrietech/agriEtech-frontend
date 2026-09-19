import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/dashboard_models.dart';

/// Admin Control Panel Dashboard
/// Shows: System Overview, User Metrics, Activity Stats, Security Status
class AdminControlPanelView extends StatelessWidget {
  final DashboardData data;

  const AdminControlPanelView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final systemOverview = data.systemOverview ?? {};
    final userMetrics = data.userMetrics ?? {};
    final recentActivity = data.recentActivity ?? {};
    final securityStatus = data.securityStatus ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Status Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF4F46E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, 
                  color: Colors.white, size: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Administrator',
                        style: AppTypography.titleLarge.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Status: ${systemOverview['systemStatus'] ?? 'OPERATIONAL'}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: systemOverview['systemStatus'] == 'OPERATIONAL'
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: systemOverview['systemStatus'] == 'OPERATIONAL'
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFEF4444),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // System Metrics Grid
          const Text(
            'System Overview',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.people_rounded,
                  label: 'Total Users',
                  value: '${systemOverview['totalUsers'] ?? 0}',
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.agriculture_rounded,
                  label: 'Total Farms',
                  value: '${systemOverview['totalFarms'] ?? 0}',
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.sensors_rounded,
                  label: 'Total Sensors',
                  value: '${systemOverview['totalSensors'] ?? 0}',
                  color: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.warning_rounded,
                  label: 'Active Alerts',
                  value: '${systemOverview['activeAlerts'] ?? 0}',
                  color: const Color(0xFFEA580C),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // User Metrics
          const Text(
            'User Distribution',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          AppSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildUserRoleRow(
                    'Farmers',
                    userMetrics['byRole']?['FARMER'] ?? 0,
                    const Color(0xFF16A34A),
                  ),
                  const Divider(),
                  _buildUserRoleRow(
                    'Development Agents',
                    userMetrics['byRole']?['DEVELOPMENT_AGENT'] ?? 0,
                    const Color(0xFF0891B2),
                  ),
                  const Divider(),
                  _buildUserRoleRow(
                    'Officers',
                    (userMetrics['byRole']?['WOREDA_OFFICER'] ?? 0) +
                    (userMetrics['byRole']?['ZONAL_OFFICER'] ?? 0) +
                    (userMetrics['byRole']?['REGIONAL_OFFICER'] ?? 0),
                    const Color(0xFF6366F1),
                  ),
                  const Divider(),
                  _buildUserRoleRow(
                    'Researchers',
                    userMetrics['byRole']?['RESEARCHER'] ?? 0,
                    const Color(0xFF8B5CF6),
                  ),
                  const Divider(),
                  _buildUserRoleRow(
                    'Admins',
                    userMetrics['byRole']?['ADMIN'] ?? 0,
                    const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          if ((userMetrics['pendingRoleRequests'] ?? 0) > 0)
            AppSurfaceCard(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pending_actions_rounded, color: Color(0xFFD97706)),
                ),
                title: Text(
                  '${userMetrics['pendingRoleRequests']} Pending Role Requests',
                  style: AppTypography.titleSmall,
                ),
                subtitle: const Text('Requires approval'),
                trailing: ElevatedButton(
                  onPressed: () => context.push('/apply-role'),
                  child: const Text('REVIEW'),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // Recent Activity (24h)
          const Text(
            'Recent Activity',
            style: AppTypography.titleMedium,
          ),
          Text(
            recentActivity['period']?.toString() ?? 'Last 24 hours',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  icon: Icons.person_add_rounded,
                  label: 'New Users',
                  value: '${recentActivity['newUsers'] ?? 0}',
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildActivityCard(
                  icon: Icons.campaign_rounded,
                  label: 'Alerts',
                  value: '${recentActivity['newAlerts'] ?? 0}',
                  color: const Color(0xFFEA580C),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Security Status
          const Text(
            'Security Status',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: securityStatus['securityLevel'] == 'ELEVATED'
                  ? const Color(0xFFEA580C).withValues(alpha: 0.1)
                  : const Color(0xFF16A34A).withValues(alpha: 0.1),
              border: Border.all(
                color: securityStatus['securityLevel'] == 'ELEVATED'
                    ? const Color(0xFFEA580C)
                    : const Color(0xFF16A34A),
              ),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      securityStatus['securityLevel'] == 'ELEVATED'
                          ? Icons.warning_rounded
                          : Icons.shield_rounded,
                      color: securityStatus['securityLevel'] == 'ELEVATED'
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF16A34A),
                      size: 32,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Level: ${securityStatus['securityLevel'] ?? 'NORMAL'}',
                            style: AppTypography.titleSmall.copyWith(
                              color: securityStatus['securityLevel'] == 'ELEVATED'
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                          Text(
                            '${securityStatus['lockedAccounts'] ?? 0} locked accounts • ${securityStatus['failedLoginsLast24h'] ?? 0} failed logins',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _buildSecurityMetric(
                        'Locked Accounts',
                        '${securityStatus['lockedAccounts'] ?? 0}',
                      ),
                    ),
                    Expanded(
                      child: _buildSecurityMetric(
                        'Active Sessions',
                        '${securityStatus['activeSessions'] ?? 0}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Admin Actions
          const Text(
            'System Actions',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/analytics'),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('View Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/alerts/create'),
                  icon: const Icon(Icons.campaign_rounded),
                  label: const Text('System Alert'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRoleRow(String role, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(role, style: AppTypography.bodyMedium),
        ),
        Text(
          count.toString(),
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
                  Text(label, style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        )),
        Text(label, style: AppTypography.caption, textAlign: TextAlign.center),
      ],
    );
  }
}
