import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../models/forecast_model.dart';
import '../theme/weather_theme.dart';

/// World-Standard Weather Metrics Grid (Apple Weather / AccuWeather standard)
class WeatherMetricsGrid extends StatelessWidget {
  final ForecastModel forecast;

  const WeatherMetricsGrid({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = l10n.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid of 6 international metrics (2 columns)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Precipitation & Probability
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: l10n.translate('precipitation'),
                mainValue: '${forecast.precipitationMm.toStringAsFixed(1)} mm',
                subtitle: '${forecast.precipitationProbability.toStringAsFixed(0)}% ${l10n.translate('probability')}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadii.roundedPill,
                      child: LinearProgressIndicator(
                        value: (forecast.precipitationProbability / 100.0).clamp(0.0, 1.0),
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      forecast.precipitationMm > 0
                          ? '${l10n.translate('expected_today')}: ${forecast.precipitationMm.toStringAsFixed(1)} mm'
                          : l10n.translate('no_precipitation_expected'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 2. WHO UV Index
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.wb_sunny_rounded,
                iconColor: UvIndexStandards.getColor(forecast.uvIndex),
                title: l10n.translate('uv_index'),
                mainValue: forecast.uvIndex.toStringAsFixed(1),
                subtitle: UvIndexStandards.getCategory(forecast.uvIndex, lang),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // 5-color segment UV bar
                    Container(
                      height: 6,
                      decoration: const BoxDecoration(
                        borderRadius: AppRadii.roundedPill,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF22C55E), // Low
                            Color(0xFFF59E0B), // Moderate
                            Color(0xFFF97316), // High
                            Color(0xFFEF4444), // Very High
                            Color(0xFFA855F7), // Extreme
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      UvIndexStandards.getAdvice(forecast.uvIndex, lang),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. Wind Velocity, Gusts & Compass
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.air_rounded,
                iconColor: const Color(0xFF14B8A6),
                title: l10n.translate('wind'),
                mainValue: '${forecast.windSpeedKmh.toStringAsFixed(1)} km/h',
                subtitle: '${forecast.windDirectionCardinal} • ${forecast.windDirectionDeg.toStringAsFixed(0)}°',
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            forecast.windGustsKmh != null
                                ? '${l10n.translate('gusts')}: ${forecast.windGustsKmh!.toStringAsFixed(0)} km/h'
                                : l10n.translate('gentle_breeze'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            forecast.windSpeedKmh > 30
                                ? l10n.translate('wind_caution')
                                : l10n.translate('wind_calm'),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rotating Compass Graphic
                    _buildCompassWidget(
                      directionDeg: forecast.windDirectionDeg,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 4. Humidity & Dew Point
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.water_rounded,
                iconColor: const Color(0xFF06B6D4),
                title: l10n.translate('humidity'),
                mainValue: '${forecast.relativeHumidity.toStringAsFixed(0)}%',
                subtitle: '${l10n.translate('dew_point')}: ${forecast.dewPoint.toStringAsFixed(1)}°C',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: Text(
                        forecast.getDewPointComfort(lang),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0891B2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      forecast.getFeelsLikeSummary(lang),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5. Atmospheric Surface Pressure
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: l10n.translate('pressure'),
                mainValue: '${forecast.surfacePressureHpa.toStringAsFixed(0)} hPa',
                subtitle: forecast.getPressureTendency(lang),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadii.roundedPill,
                      child: LinearProgressIndicator(
                        value: ((forecast.surfacePressureHpa - 950) / 100.0).clamp(0.0, 1.0),
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${l10n.translate('standard_baseline')}: 1013 hPa',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // 6. Cloud Cover & Optical Clarity
            Expanded(
              child: _buildMetricCard(
                isDark: isDark,
                icon: Icons.cloud_queue_rounded,
                iconColor: const Color(0xFF64748B),
                title: l10n.translate('cloud_cover'),
                mainValue: '${forecast.cloudCover.toStringAsFixed(0)}%',
                subtitle: forecast.cloudCover < 20
                    ? l10n.translate('sky_clear')
                    : (forecast.cloudCover < 60
                        ? l10n.translate('sky_partly_cloudy')
                        : l10n.translate('sky_overcast')),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: AppRadii.roundedPill,
                      child: LinearProgressIndicator(
                        value: (forecast.cloudCover / 100.0).clamp(0.0, 1.0),
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF64748B)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      forecast.cloudCover > 50
                          ? l10n.translate('optical_masked_hint')
                          : l10n.translate('high_solar_radiation'),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Compact Metric Card
  Widget _buildMetricCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String mainValue,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Main Metric Number
          Text(
            mainValue,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Custom child widget (gauges, progress bars, advisory)
          child,
        ],
      ),
    );
  }

  /// Compact Rotating Compass Indicator
  Widget _buildCompassWidget({
    required double directionDeg,
    required bool isDark,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass Cardinal N marker
          const Positioned(
            top: 2,
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
          // Rotated Arrow
          Transform.rotate(
            angle: (directionDeg * (math.pi / 180.0)),
            child: const Icon(
              Icons.navigation_rounded,
              size: 20,
              color: Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }
}
