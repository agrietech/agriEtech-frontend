import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/forecast_model.dart';

/// Apple Weather & Google Weather style 7-day forecast item with continuous temperature range bar
class ForecastDayItem extends StatelessWidget {
  final ForecastModel day;
  final double weeklyMinTemp;
  final double weeklyMaxTemp;
  final bool isToday;

  const ForecastDayItem({
    super.key,
    required this.day,
    this.weeklyMinTemp = 10.0,
    this.weeklyMaxTemp = 32.0,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = l10n.locale.languageCode;
    final cond = day.conditionData;

    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          // Day Name & Date
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isToday ? l10n.translate('today') : _formatDay(day.parsedDate),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13.5,
                    color: isToday
                        ? AppTheme.primaryColor
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                Text(
                  '${day.parsedDate.day}/${day.parsedDate.month}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Weather Condition Icon Badge with ambient condition tint
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cond.accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: AppRadii.roundedSm,
            ),
            child: Icon(
              cond.icon,
              color: cond.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),

          // Rain Probability & Volume / Condition Badge
          SizedBox(
            width: 66,
            child: (day.precipitationProbability >= 15.0 || day.rainfall > 0.2)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.water_drop_rounded,
                            size: 13,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${day.precipitationProbability.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                      if (day.rainfall > 0.4)
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            '${day.rainfall.toStringAsFixed(1)} mm',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  )
                : Text(
                    cond.getLocalizedName(lang),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: 10),

          // Min Temperature
          SizedBox(
            width: 26,
            child: Text(
              '${day.temperatureMin.toStringAsFixed(0)}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Proportional Continuous Temperature Range Bar
          Expanded(
            child: _buildTemperatureRangeBar(isDark: isDark),
          ),
          const SizedBox(width: 8),

          // Max Temperature
          SizedBox(
            width: 26,
            child: Text(
              '${day.temperatureMax.toStringAsFixed(0)}°',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Apple Weather style horizontal temperature range bar
  Widget _buildTemperatureRangeBar({required bool isDark}) {
    final span = (weeklyMaxTemp - weeklyMinTemp).clamp(1.0, 50.0);
    final leftFrac = ((day.temperatureMin - weeklyMinTemp) / span).clamp(0.0, 0.95);
    final rightFrac = ((day.temperatureMax - weeklyMinTemp) / span).clamp(leftFrac + 0.05, 1.0);
    final barWidthFrac = (rightFrac - leftFrac).clamp(0.05, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final barLeft = leftFrac * totalWidth;
        final barWidth = barWidthFrac * totalWidth;

        return SizedBox(
          height: 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background track
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                    borderRadius: AppRadii.roundedPill,
                  ),
                ),
              ),

              // Active range gradient
              Positioned(
                left: barLeft,
                width: barWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: AppRadii.roundedPill,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF38BDF8), // Cool cyan for min
                        Color(0xFFF59E0B), // Warm amber for mid
                        Color(0xFFF97316), // Orange for max
                      ],
                    ),
                  ),
                ),
              ),

              // Today's current temperature dot indicator
              if (isToday)
                Positioned(
                  left: (((day.temperature - weeklyMinTemp) / span) * totalWidth).clamp(2.0, totalWidth - 8.0),
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDay(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}
