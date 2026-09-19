import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/dashboard_models.dart';

/// Farmer-specific dashboard view
/// Shows: My Farms, Active Alerts, Sensors, Recent Diagnoses, Advisories
class FarmerDashboardView extends StatelessWidget {
  final DashboardData data;

  const FarmerDashboardView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = data.userProfile ?? {};
    final farms = data.farmOverview ?? [];
    final alerts = data.activeAlerts ?? [];
    final diagnoses = data.recentDiagnoses ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Summary Card
          AppSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('farm_portfolio'),
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildStatChip(
                        icon: Icons.agriculture_rounded,
                        label: '${profile['totalFarms'] ?? 0} ${l10n.translate('farms')}',
                        color: const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatChip(
                        icon: Icons.landscape_rounded,
                        label: '${profile['totalArea']?.toStringAsFixed(1) ?? 0} ha',
                        color: const Color(0xFF0891B2),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatChip(
                        icon: Icons.sensors_rounded,
                        label: '${profile['activeSensors'] ?? 0}/${profile['totalSensors'] ?? 0} ${l10n.translate('sensors')}',
                        color: const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick Actions
          Text(
            l10n.translate('quick_actions'),
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.report_problem_rounded,
                  label: l10n.translate('report_issue'),
                  color: const Color(0xFFDC2626),
                  route: '/diagnosis/create',
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: l10n.translate('diagnose_crop'),
                  color: const Color(0xFF0D9488),
                  route: '/diagnosis/create',
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.wb_cloudy_rounded,
                  label: l10n.translate('7_day_forecast'),
                  color: const Color(0xFF0284C7),
                  route: '/weather',
                ),
                _buildQuickAction(
                  context,
                  icon: Icons.trending_up_rounded,
                  label: l10n.translate('market_prices'),
                  color: const Color(0xFFD97706),
                  route: '/analytics',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // My Farms
          Text(
            l10n.translate('farms'),
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          if (farms.isEmpty)
            AppSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.agriculture_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: AppSpacing.sm),
                      Text(l10n.translate('no_farms_registered'), style: AppTypography.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/farms/add'),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.translate('add_first_farm')),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...farms.map((farm) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppSurfaceCard(
                onTap: () => context.push('/farms/${farm['id']}'),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    child: const Icon(Icons.agriculture_rounded, color: Color(0xFF16A34A)),
                  ),
                  title: Text(farm['name'] ?? 'Farm', style: AppTypography.titleSmall),
                  subtitle: Text('${farm['area'] ?? 0} ha • ${farm['crop'] ?? 'Mixed'}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (farm['alertCount'] != null && farm['alertCount'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Text(
                            '${farm['alertCount']} alerts',
                            style: AppTypography.caption.copyWith(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        farm['sensorCount'] != null ? '${farm['sensorCount']} sensors' : 'No sensors',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ),
            )),

          const SizedBox(height: AppSpacing.lg),

          // Active Alerts
          if (alerts.isNotEmpty) ...[
            Text(
              l10n.translate('active_alerts'),
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...alerts.take(5).map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppSurfaceCard(
                child: ListTile(
                  leading: Icon(
                    alert['isUrgent'] == true 
                      ? Icons.warning_rounded 
                      : Icons.info_outline_rounded,
                    color: alert['isUrgent'] == true 
                      ? const Color(0xFFDC2626) 
                      : const Color(0xFFD97706),
                  ),
                  title: Text(alert['title'] ?? 'Alert', style: AppTypography.titleSmall),
                  subtitle: Text(alert['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => context.push('/alerts/${alert['id']}'),
                ),
              ),
            )),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Recent Diagnoses
          if (diagnoses.isNotEmpty) ...[
            const Text(
              'Recent Diagnoses',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...diagnoses.take(3).map((diagnosis) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppSurfaceCard(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEF4444),
                    child: Icon(Icons.coronavirus_rounded, color: Colors.white, size: 20),
                  ),
                  title: Text(diagnosis['diseaseName'] ?? 'Unknown', style: AppTypography.titleSmall),
                  subtitle: Text(diagnosis['farmName'] ?? ''),
                  trailing: Text(
                    _formatDate(diagnosis['diagnosedAt']),
                    style: AppTypography.caption,
                  ),
                  onTap: () => context.push('/diagnosis/${diagnosis['id']}'),
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: AppRadius.radiusMd,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption.copyWith(color: color),
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

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = date is DateTime ? date : DateTime.parse(date.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);
      
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${(diff.inDays / 7).floor()}w ago';
    } catch (e) {
      return '';
    }
  }
}
