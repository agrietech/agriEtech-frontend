import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';

/// Agronomic Evapotranspiration (ET₀) and irrigation advisory card
class EvapotranspirationCard extends StatelessWidget {
  final double referenceEt0;
  final double effectiveRain;
  final double netDeficit;
  final String status;
  final String? advisoryText;

  const EvapotranspirationCard({
    super.key,
    this.referenceEt0 = 4.2,
    this.effectiveRain = 1.8,
    this.netDeficit = -2.4,
    this.status = 'OPTIMAL',
    this.advisoryText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppTheme.telemetrySensor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: const Icon(
                  Icons.opacity_rounded,
                  color: AppTheme.telemetrySensor,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('evapotranspiration_title'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    Text(
                      l10n.translate('evapotranspiration_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  l10n.translate('status_${status.toLowerCase()}'),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Metric Tiles
          Row(
            children: [
              _buildETMetric(
                label: l10n.translate('et0_ref'),
                value: '${referenceEt0.toStringAsFixed(1)} mm/day',
                caption: l10n.translate('et0_caption'),
                color: AppTheme.telemetrySensor,
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildETMetric(
                label: l10n.translate('effective_rain'),
                value: '${effectiveRain.toStringAsFixed(1)} mm',
                caption: l10n.translate('effective_rain_caption'),
                color: AppTheme.telemetryNdvi,
                isDark: isDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              _buildETMetric(
                label: l10n.translate('net_deficit'),
                value: '${netDeficit.toStringAsFixed(1)} mm',
                caption: l10n.translate('net_deficit_caption'),
                color: AppTheme.telemetryDrought,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Advisory banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162A1D) : AppTheme.surfaceLight,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: AppIconSize.md,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    advisoryText ?? l10n.translate('irrigation_advisory'),
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: isDark ? Colors.grey.shade300 : AppTheme.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildETMetric({
    required String label,
    required String value,
    required String caption,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.surfaceLight,
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
