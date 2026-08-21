///
/// @file risk_badge.dart
/// @description Visual indicator pill displaying hazard severity (LOW / MODERATE / HIGH / CRITICAL).
/// @author UI Component Specialist
///
library risk_badge;

import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String level;
  final bool compact;

  const RiskBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = level.toUpperCase();
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (normalized) {
      case 'CRITICAL':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        icon = Icons.gpp_maybe_rounded;
        break;
      case 'HIGH':
        bgColor = const Color(0xFFFFEDD5);
        textColor = const Color(0xFFC2410C);
        icon = Icons.warning_amber_rounded;
        break;
      case 'MODERATE':
      case 'MEDIUM':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        icon = Icons.info_outline_rounded;
        break;
      case 'LOW':
      default:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          normalized,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            normalized,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
