import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../models/weather_forecast_model.dart';
import '../theme/weather_theme.dart';

/// World-Standard Temperature Trend Chart with Proportional Daily Thermal Capsules
class TemperatureTrendChart extends StatelessWidget {
  final WeatherForecastModel? forecast;

  const TemperatureTrendChart({
    super.key,
    this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (forecast == null || forecast!.daily.temperatureMax.isEmpty) {
      return Center(child: Text(l10n.translate('no_data')));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final daily = forecast!.daily;

    final allMin = daily.temperatureMin.reduce((a, b) => a < b ? a : b);
    final allMax = daily.temperatureMax.reduce((a, b) => a > b ? a : b);
    final totalSpan = (allMax - allMin).clamp(2.0, 50.0);

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
                    color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.thermostat_rounded, size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Weekly Range: ${allMin.round()}° – ${allMax.round()}°C',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
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
                  'High/Low Thermal Profile',
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

        // Thermal Capsule Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackHeight = constraints.maxHeight - 56; // Room for top/bottom labels

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(daily.time.length, (index) {
                  final date = daily.time[index];
                  final maxT = daily.temperatureMax[index];
                  final minT = daily.temperatureMin[index];
                  final isToday = index == 0;
                  final wCodes = daily.weatherCodes;
                  final wCode = (wCodes != null && index < wCodes.length) ? wCodes[index] : '0';
                  final cond = WeatherTheme.resolve(weatherCode: wCode);

                  final dateParts = date.split('-');
                  final monthDay = dateParts.length >= 3
                      ? '${dateParts[1]}/${dateParts[2]}'
                      : (date.length >= 10 ? date.substring(5) : date);

                  // Calculate proportional vertical bounds
                  final bottomFraction = ((minT - allMin) / totalSpan).clamp(0.0, 0.85);
                  final topFraction = ((maxT - allMin) / totalSpan).clamp(bottomFraction + 0.15, 1.0);
                  final capsuleHeight = ((topFraction - bottomFraction) * trackHeight).clamp(16.0, trackHeight);
                  final bottomOffset = bottomFraction * trackHeight;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Max Temp Label
                          Text(
                            '${maxT.round()}°',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Proportional Thermal Track
                          SizedBox(
                            height: trackHeight,
                            width: 14,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Background track
                                Container(
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                // Thermal Capsule
                                Positioned(
                                  bottom: bottomOffset,
                                  child: Container(
                                    height: capsuleHeight,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Color(0xFF38BDF8), // Cool Low
                                          Color(0xFFF59E0B), // Warm Mid
                                          Color(0xFFEF4444), // Hot High
                                        ],
                                        stops: [0.0, 0.55, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Min Temp Label
                          Text(
                            '${minT.round()}°',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Weather Icon
                          Icon(
                            cond.icon,
                            size: 14,
                            color: cond.accentColor,
                          ),
                          const SizedBox(height: 2),

                          // Date
                          Text(
                            isToday ? l10n.translate('today') : monthDay,
                            style: TextStyle(
                              fontSize: 9.5,
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
