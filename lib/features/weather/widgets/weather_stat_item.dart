import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Standardized telemetry stat indicator widget for weather conditions
class WeatherStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const WeatherStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: effectiveColor, size: AppIconSize.lg),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: TextStyle(
            color: effectiveColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
