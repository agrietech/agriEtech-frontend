import 'package:flutter/material.dart';
import '../models/risk_models.dart';
import '../../../core/utils/date_formatter.dart';

class RiskAssessmentCard extends StatelessWidget {
  final RiskAssessment assessment;
  final VoidCallback? onTap;

  const RiskAssessmentCard({
    super.key,
    required this.assessment,
    this.onTap,
  });

  Color _getRiskColor() {
    switch (assessment.riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.deepOrange;
      case 'MODERATE':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getHazardIcon() {
    switch (assessment.hazardType.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: riskColor,
                width: 4,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getHazardIcon(),
                      color: riskColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HazardTypeUtils.getDisplayName(assessment.hazardType),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: riskColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                RiskLevelUtils.getDisplayName(assessment.riskLevel),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: riskColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(assessment.riskScore * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: riskColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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
              const SizedBox(height: 12),
              
              // Location and time info
              Row(
                children: [
                  if (assessment.woreda != null) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        assessment.woreda!.name,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatRelativeTime(assessment.assessedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              
              if (assessment.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  assessment.description!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              if (assessment.affectedPopulation != null && 
                  assessment.affectedPopulation! > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: Colors.orange[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatNumber(assessment.affectedPopulation!)} people affected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
