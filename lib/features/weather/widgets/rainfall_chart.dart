import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../models/weather_forecast_model.dart';

/// World-Standard Meteorological Rainfall Chart with Proportional Volumetric Bars
class RainfallChart extends StatelessWidget {
  final WeatherForecastModel? forecast;

  const RainfallChart({
    super.key,
    this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (forecast == null || forecast!.daily.precipitationSum.isEmpty) {
      return Center(child: Text(l10n.translate('no_data')));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final daily = forecast!.daily;
    final totalRain = daily.precipitationSum.fold<double>(0.0, (sum, val) => sum + val);
    final maxRain = daily.precipitationSum.fold<double>(0.0, (max, val) => val > max ? val : max);
    final effectiveMax = maxRain > 5.0 ? maxRain : 10.0;
    final rainyDaysCount = daily.precipitationSum.where((val) => val >= 1.0).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Summary Metric
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '7-Day Total: ${totalRain.toStringAsFixed(1)} mm',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0284C7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$rainyDaysCount rainy ${rainyDaysCount == 1 ? 'day' : 'days'} expected',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Volumetric Bar Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight - 45; // Space for labels

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(daily.time.length, (index) {
                  final date = daily.time[index];
                  final precip = daily.precipitationSum[index];
                  final probList = daily.precipitationProbabilityMax;
                  final prob = (probList != null && index < probList.length)
                      ? probList[index]
                      : (precip > 2 ? 75.0 : 10.0);

                  final barFraction = (precip / effectiveMax).clamp(0.0, 1.0);
                  final barHeight = (barFraction * availableHeight).clamp(6.0, availableHeight);
                  final hasRain = precip > 0.2;

                  final dateParts = date.split('-');
                  final monthDay = dateParts.length >= 3
                      ? '${dateParts[1]}/${dateParts[2]}'
                      : (date.length >= 10 ? date.substring(5) : date);
                  final isToday = index == 0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Amount Label
                          Text(
                            precip > 0 ? precip.toStringAsFixed(1) : '0',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: hasRain ? FontWeight.bold : FontWeight.normal,
                              color: hasRain
                                  ? const Color(0xFF0284C7)
                                  : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Proportional Volumetric Bar
                          Container(
                            height: barHeight,
                            width: 14,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: hasRain
                                    ? [
                                        const Color(0xFF0284C7),
                                        const Color(0xFF38BDF8),
                                      ]
                                    : [
                                        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                      ],
                              ),
                              boxShadow: hasRain
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rain Probability Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: prob >= 30
                                  ? const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${prob.round()}%',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: prob >= 50 ? FontWeight.bold : FontWeight.w500,
                                color: prob >= 30
                                    ? const Color(0xFF0284C7)
                                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Date
                          Text(
                            isToday ? l10n.translate('today') : monthDay,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? AppTheme.primaryColor
                                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}
