import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/alert_models.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onToggleRead;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onToggleRead,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(alert.severity);
    final hazardIcon = _getHazardIcon(alert.hazardType);
    final woredaName = alert.woreda?.name ?? 'Target Woreda: National Coverage';

    return Card(
      elevation: alert.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alert.isRead
              ? severityColor.withValues(alpha: 0.25)
              : severityColor.withValues(alpha: 0.8),
          width: alert.isRead ? 1 : 2,
        ),
      ),
      color: alert.isRead ? Colors.white : const Color(0xFFFAFFFA),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Hazard Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hazardIcon,
                      color: severityColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and Hazard Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!alert.isRead) ...[
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            Expanded(
                              child: Text(
                                alert.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _formatHazardType(alert.hazardType),
                              style: TextStyle(
                                color: severityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Priority ${alert.priority}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Severity Badge
                  _buildSeverityBadge(context, alert.severity),
                ],
              ),

              const SizedBox(height: 12),

              // Message Preview
              Text(
                alert.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: alert.isRead ? Colors.grey[700] : Colors.black87,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Woreda & Location Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, size: 15, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        woredaName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B5E20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.push('/farms');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Inspect Farms',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF2E7D32)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  // Timestamp
                  Icon(Icons.access_time, size: 15, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatRelativeSafe(alert.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),

                  const Spacer(),

                  // Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: alert.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: alert.isActive ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alert.isActive ? 'Active Hazard' : 'Resolved',
                          style: TextStyle(
                            color: alert.isActive ? Colors.green.shade800 : Colors.grey.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(BuildContext context, String severity) {
    final color = _getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'HIGH':
        return const Color(0xFFF4511E);
      case 'MODERATE':
        return const Color(0xFFFB8C00);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  IconData _getHazardIcon(String hazardType) {
    switch (hazardType.toUpperCase()) {
      case 'DROUGHT':
        return Icons.water_drop_outlined;
      case 'FLOOD':
        return Icons.flood;
      case 'LOCUST_PEST':
      case 'LOCUST':
        return Icons.pest_control;
      case 'VEGETATION_STRESS':
        return Icons.grass;
      case 'FROST':
        return Icons.ac_unit;
      case 'HEAT_STRESS':
        return Icons.wb_sunny;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
