import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/alert_model.dart';

/// Alert Tile Widget with Priority Badges and Time-Ago Callouts
class AlertTile extends StatelessWidget {
  final AlertModel? alert;
  final String? title;
  final String? message;
  final String? severity;
  final String? hazardType;
  final DateTime? timestamp;
  final VoidCallback? onTap;

  const AlertTile({
    super.key,
    this.alert,
    this.title,
    this.message,
    this.severity,
    this.hazardType,
    this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertTitle = alert?.titleEn ?? title ?? 'Critical Drought Advisory';
    final alertMsg = alert?.messageEn ?? message ?? 'Soil moisture deficit below threshold in Haramaya.';
    final sev = alert?.severity ?? severity ?? 'CRITICAL';
    final hazard = alert?.hazardType ?? hazardType ?? 'DROUGHT';
    final time = alert?.createdAt ?? timestamp ?? DateTime.now();

    final color = _getSeverityColor(sev);
    final icon = _getHazardIcon(hazard);
    final timeStr = DateFormat('MMM d, h:mm a').format(time);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sev.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alertTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alertMsg,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String sev) {
    switch (sev.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFDC2626);
      case 'HIGH':
        return const Color(0xFFEA580C);
      case 'MEDIUM':
      case 'MODERATE':
        return const Color(0xFFD97706);
      case 'LOW':
      default:
        return const Color(0xFF16A34A);
    }
  }

  IconData _getHazardIcon(String hazard) {
    switch (hazard.toUpperCase()) {
      case 'DROUGHT':
        return Icons.wb_sunny_outlined;
      case 'FLOOD':
        return Icons.water_outlined;
      case 'LOCUST':
        return Icons.pest_control_outlined;
      case 'DISEASE':
        return Icons.coronavirus_outlined;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}
