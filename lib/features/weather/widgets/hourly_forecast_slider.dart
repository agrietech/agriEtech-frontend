import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../models/hourly_forecast_model.dart';

/// World-Standard 24-Hour Meteorological Forecast Slider
class HourlyForecastSlider extends StatelessWidget {
  final List<HourlyForecastModel> hourlyForecasts;

  const HourlyForecastSlider({
    super.key,
    required this.hourlyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyForecasts.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time_rounded, size: AppIconSize.md, color: AppTheme.primaryColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              l10n.translate('24h_forecast'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourlyForecasts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = hourlyForecasts[index];
              final isFirst = index == 0;
              final cond = item.conditionData;

              return Container(
                width: 74,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: isFirst
                      ? AppTheme.primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
                      : (isDark ? const Color(0xFF1E293B) : Colors.white),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(
                    color: isFirst
                        ? AppTheme.primaryColor.withValues(alpha: 0.5)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: isFirst ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isFirst ? l10n.translate('now') : item.hourLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                        color: isFirst ? AppTheme.primaryColor : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      cond.icon,
                      size: 24,
                      color: cond.accentColor,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${item.temperatureC.round()}°',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.precipitationProbability > 5)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 10, color: Color(0xFF0284C7)),
                            const SizedBox(width: 2),
                            Text(
                              '${item.precipitationProbability.round()}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
