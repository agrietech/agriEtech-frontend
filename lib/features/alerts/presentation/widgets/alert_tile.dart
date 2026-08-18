///
/// @file alert_tile.dart
/// @feature alerts
/// @description Alert card matching the Stitch design: colored severity rail,
///   hazard icon avatar, bilingual headline, status line, and action buttons.
/// @author UI Component Developer (alerts)
///
library alert_tile;

import 'package:flutter/material.dart';
import '../../data/models/alert_model.dart';

// Design tokens sourced from docs/DESIGN_SYSTEM.md — keep in sync with
// AppTheme if/when Abraham centralizes these as shared constants.
class _Tokens {
  static const criticalRed = Color(0xFFD32F2F);
  static const warningAmber = Color(0xFFFFA000);
  static const primaryGreen = Color(0xFF2E7D32);
}

class AlertTile extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onOpenMitigationGuide;

  const AlertTile({
    super.key,
    required this.alert,
    this.onTap,
    this.onPlayAudio,
    this.onOpenMitigationGuide,
  });

  Color _severityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return _Tokens.criticalRed;
      case AlertSeverity.high:
        return _Tokens.warningAmber;
      case AlertSeverity.moderate:
        return _Tokens.warningAmber;
      case AlertSeverity.low:
        return _Tokens.primaryGreen;
    }
  }

  String _severityLabel(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return 'CRITICAL WARNING';
      case AlertSeverity.high:
        return 'HIGH ALERT';
      case AlertSeverity.moderate:
        return 'MODERATE ALERT';
      case AlertSeverity.low:
        return 'LOW ADVISORY';
    }
  }

  IconData _hazardIcon(String hazardType) {
    switch (hazardType.toUpperCase()) {
      case 'FLOOD':
        return Icons.flood_rounded;
      case 'LOCUST':
        return Icons.pest_control_rounded;
      case 'VEGETATION':
        return Icons.grass_rounded;
      case 'DROUGHT':
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'JUST NOW';
    if (diff.inMinutes < 60) return '${diff.inMinutes} MIN AGO';
    if (diff.inHours < 24) return '${diff.inHours} HRS AGO';
    return '${diff.inDays}D AGO';
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);
    final title = alert.titleAm != null && alert.titleAm!.isNotEmpty
        ? '${alert.headline} / ${alert.titleAm}'
        : alert.headline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // radius-md
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color,
                    child: Icon(_hazardIcon(alert.hazardType),
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_severityLabel(alert.severity)} • ${_relativeTime(alert.createdAt)}',
                          style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  if (!alert.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (alert.woredaName != null)
                Text(alert.woredaName!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              if (alert.message != null) ...[
                const SizedBox(height: 4),
                Text(
                  alert.message!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
              if (alert.audioAdvisoryUrl != null ||
                  alert.mitigationGuideUrl != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (alert.audioAdvisoryUrl != null)
                      OutlinedButton.icon(
                        onPressed: onPlayAudio,
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text('Play Audio Advisory'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    if (alert.mitigationGuideUrl != null)
                      OutlinedButton.icon(
                        onPressed: onOpenMitigationGuide,
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: const Text('Mitigation Guide'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
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
}
