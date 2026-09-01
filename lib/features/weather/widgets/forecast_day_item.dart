import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/forecast_model.dart';

/// Single item row for 7-day weather forecast list
class ForecastDayItem extends StatelessWidget {
  final ForecastModel day;

  const ForecastDayItem({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Weather Condition Icon Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.telemetryFlood.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Icon(
              _getWeatherIcon(day.rainfall),
              color: AppTheme.telemetryFlood,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Date & Rain Amount
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(day.parsedDate),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.translate('rain')}: ${day.rainfall.toStringAsFixed(1)} mm',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Temperature Range
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.thermostat_rounded,
                size: AppIconSize.sm,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '${day.temperatureMax.toStringAsFixed(0)}° / ${day.temperatureMin.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(double rainfall) {
    if (rainfall < 1) return Icons.wb_sunny_rounded;
    if (rainfall < 10) return Icons.cloud_rounded;
    return Icons.water_drop_rounded;
  }

  String _formatDate(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${dt.day}/${dt.month}';
  }
}
