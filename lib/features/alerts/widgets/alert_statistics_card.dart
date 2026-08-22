import 'package:flutter/material.dart';
import '../models/alert_models.dart';

class AlertStatisticsCard extends StatelessWidget {
  final AlertStatistics statistics;

  const AlertStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    statistics.total,
                    Colors.blue,
                    Icons.notifications,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active',
                    statistics.active,
                    Colors.green,
                    Icons.notification_important,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Severity Breakdown
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Critical',
                    statistics.critical,
                    Colors.red,
                    Icons.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'High',
                    statistics.high,
                    Colors.deepOrange,
                    Icons.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Moderate',
                    statistics.moderate,
                    Colors.orange,
                    Icons.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Low',
                    statistics.low,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),

            // Hazard Type Breakdown (if available)
            if (statistics.byHazardType != null &&
                statistics.byHazardType!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'By Hazard Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statistics.byHazardType!.entries
                    .map((entry) => _buildHazardChip(
                          context,
                          entry.key,
                          entry.value,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardChip(BuildContext context, String hazardType, int count) {
    return Chip(
      avatar: Icon(
        _getHazardIcon(hazardType),
        size: 16,
        color: Colors.grey[700],
      ),
      label: Text(
        '${_formatHazardType(hazardType)}: $count',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  IconData _getHazardIcon(String hazardType) {
    switch (hazardType) {
      case 'DROUGHT':
        return Icons.water_drop_outlined;
      case 'FLOOD':
        return Icons.flood;
      case 'LOCUST_PEST':
        return Icons.bug_report;
      case 'VEGETATION_STRESS':
        return Icons.grass;
      case 'FROST':
        return Icons.ac_unit;
      case 'HEAT_STRESS':
        return Icons.wb_sunny;
      default:
        return Icons.warning;
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
