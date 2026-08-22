import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class RiskSummaryCard extends StatelessWidget {
  final RiskSummary riskSummary;
  final VoidCallback? onTap;

  const RiskSummaryCard({
    super.key,
    required this.riskSummary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = riskSummary.totalWoredas;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Risk Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Risk level cards
              Row(
                children: [
                  Expanded(
                    child: _RiskLevelItem(
                      label: 'Low',
                      count: riskSummary.lowRisk,
                      total: total,
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RiskLevelItem(
                      label: 'Moderate',
                      count: riskSummary.moderateRisk,
                      total: total,
                      color: Colors.orange,
                      icon: Icons.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RiskLevelItem(
                      label: 'High',
                      count: riskSummary.highRisk,
                      total: total,
                      color: Colors.deepOrange,
                      icon: Icons.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RiskLevelItem(
                      label: 'Critical',
                      count: riskSummary.criticalRisk,
                      total: total,
                      color: Colors.red,
                      icon: Icons.dangerous,
                    ),
                  ),
                ],
              ),
              
              if (riskSummary.affectedPopulation > 0) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 20,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Affected Population: ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      _formatNumber(riskSummary.affectedPopulation),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _RiskLevelItem extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _RiskLevelItem({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (count / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (total > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
