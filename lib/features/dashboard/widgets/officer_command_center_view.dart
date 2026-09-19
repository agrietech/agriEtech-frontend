import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/dashboard_models.dart';

/// Officer Command Center Dashboard
/// Shows: Jurisdiction Stats, Emergency Panel, Risk Map, Farm Analytics, Sensor Network
class OfficerCommandCenterView extends StatelessWidget {
  final DashboardData data;

  const OfficerCommandCenterView({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final jurisdiction = data.jurisdiction ?? {};
    final emergencyPanel = data.emergencyPanel ?? {};
    final riskMap = data.riskMap ?? {};
    final farmAnalytics = data.farmAnalytics ?? {};
    final sensorNetwork = data.sensorNetwork ?? {};
    final agents = data.developmentAgents ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jurisdiction Header
          AppSurfaceCard(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF16A34A),
                    Color(0xFF15803D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jurisdiction['woredaName'] ?? 'Jurisdiction',
                    style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildStatBadge(
                        icon: Icons.people_rounded,
                        value: '${jurisdiction['totalFarmers'] ?? 0}',
                        label: 'Farmers',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatBadge(
                        icon: Icons.agriculture_rounded,
                        value: '${jurisdiction['totalFarms'] ?? 0}',
                        label: 'Farms',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStatBadge(
                        icon: Icons.landscape_rounded,
                        value: '${jurisdiction['totalArea']?.toStringAsFixed(0) ?? 0}',
                        label: 'Hectares',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Emergency Panel
          if ((emergencyPanel['activeEmergencies'] ?? 0) > 0) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFDC2626)),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Color(0xFFDC2626), size: 32),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${emergencyPanel['activeEmergencies']} ACTIVE EMERGENCIES',
                          style: AppTypography.titleMedium.copyWith(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Immediate action required',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/alerts'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('VIEW'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Quick Actions for Officers
          const Text(
            'Command Actions',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.campaign_rounded,
                  label: 'Broadcast Alert',
                  color: const Color(0xFFDC2626),
                  route: '/alerts/create',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.check_circle_rounded,
                  label: 'Approve Requests',
                  color: const Color(0xFF16A34A),
                  route: '/apply-role',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.assessment_rounded,
                  label: 'View Reports',
                  color: const Color(0xFF0284C7),
                  route: '/analytics',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.map_rounded,
                  label: 'Risk Map',
                  color: const Color(0xFFD97706),
                  route: '/risks',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Risk Assessment
          const Text(
            'Risk Assessment',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          AppSurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getRiskColor(riskMap['overallRiskLevel'])
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getRiskColor(riskMap['overallRiskLevel']),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getRiskLevel(riskMap['overallRiskLevel']),
                            style: AppTypography.titleLarge.copyWith(
                              color: _getRiskColor(riskMap['overallRiskLevel']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Risk Level',
                              style: AppTypography.titleSmall,
                            ),
                            Text(
                              riskMap['overallRiskLevel']?.toString().toUpperCase() ?? 'NORMAL',
                              style: AppTypography.headlineSmall.copyWith(
                                color: _getRiskColor(riskMap['overallRiskLevel']),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                        onPressed: () => context.push('/risk-map'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Farm Analytics & Sensor Network
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Farm Analytics',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            _buildMetricRow(
                              'Total Farms',
                              '${farmAnalytics['totalFarms'] ?? 0}',
                              Icons.agriculture_rounded,
                            ),
                            const Divider(),
                            _buildMetricRow(
                              'At Risk',
                              '${farmAnalytics['atRisk'] ?? 0}',
                              Icons.warning_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sensor Network',
                      style: AppTypography.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppSurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          children: [
                            _buildMetricRow(
                              'Active',
                              '${sensorNetwork['activeSensors'] ?? 0}/${sensorNetwork['totalSensors'] ?? 0}',
                              Icons.sensors_rounded,
                            ),
                            const Divider(),
                            _buildMetricRow(
                              'Health',
                              '${sensorNetwork['networkHealth'] ?? 0}%',
                              Icons.health_and_safety_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Development Agents
          if (agents['total'] != null && agents['total'] > 0) ...[
            const Text(
              'Development Agents',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppSurfaceCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Color(0xFF16A34A), size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${agents['total'] ?? 0} Total Agents',
                            style: AppTypography.titleSmall,
                          ),
                          Text(
                            '${agents['active'] ?? 0} active in last 7 days',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: AppRadius.radiusMd,
      child: AppSurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(label, style: AppTypography.bodySmall),
        ),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getRiskColor(dynamic risk) {
    final level = risk?.toString().toUpperCase() ?? 'NORMAL';
    switch (level) {
      case 'CRITICAL':
        return const Color(0xFFDC2626);
      case 'HIGH':
        return const Color(0xFFEA580C);
      case 'MODERATE':
        return const Color(0xFFD97706);
      case 'LOW':
      case 'NORMAL':
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _getRiskLevel(dynamic risk) {
    final level = risk?.toString().toUpperCase() ?? 'NORMAL';
    switch (level) {
      case 'CRITICAL':
        return '!!!';
      case 'HIGH':
        return '!!';
      case 'MODERATE':
        return '!';
      case 'LOW':
      case 'NORMAL':
      default:
        return '✓';
    }
  }
}
