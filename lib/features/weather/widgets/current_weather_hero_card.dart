import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../models/forecast_model.dart';
import '../theme/weather_theme.dart';
import 'weather_metrics_grid.dart';

/// World-Standard Hero Weather Card with dynamic atmospheric imagery and metrics
class CurrentWeatherHeroCard extends StatefulWidget {
  final ForecastModel forecast;
  final String? locationName;

  const CurrentWeatherHeroCard({
    super.key,
    required this.forecast,
    this.locationName,
  });

  @override
  State<CurrentWeatherHeroCard> createState() => _CurrentWeatherHeroCardState();
}

class _CurrentWeatherHeroCardState extends State<CurrentWeatherHeroCard> {
  WeatherConditionData? _overrideCondition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = l10n.locale.languageCode;

    // Use simulated condition if selected, otherwise resolved condition from telemetry
    final activeCondition = _overrideCondition ?? widget.forecast.conditionData;

    // Synthesize display forecast if condition is overridden
    final displayForecast = _overrideCondition != null
        ? _buildSimulatedForecast(widget.forecast, _overrideCondition!)
        : widget.forecast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Condition Previewer Pill Selector (Standards Inspector)
        Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildConditionSelectorChip(
                label: '📡 ${l10n.translate('live_telemetry')}',
                isSelected: _overrideCondition == null,
                onTap: () => setState(() => _overrideCondition = null),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              ...WeatherTheme.allConditions.map((cond) {
                final isSelected = _overrideCondition?.type == cond.type;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildConditionSelectorChip(
                    label: '${_getConditionEmoji(cond.type)} ${cond.getLocalizedName(lang)}',
                    isSelected: isSelected,
                    onTap: () => setState(() => _overrideCondition = cond),
                    isDark: isDark,
                    activeColor: cond.accentColor,
                  ),
                );
              }),
            ],
          ),
        ),

        // Hero Weather Artwork Card
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: AppRadii.roundedLg,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: activeCondition.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: activeCondition.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Atmospheric Background Landscape Artwork (Supabase Storage CDN + local asset fallback)
              Positioned.fill(
                child: Image.network(
                  activeCondition.supabaseUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    activeCondition.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx2, err2, stack2) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.70),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Date / Today & Weather Condition Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.locationName != null && widget.locationName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 13, color: Colors.white70),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.locationName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              l10n.translate('today'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              displayForecast.date,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                        // Localized Condition Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: AppRadii.roundedPill,
                            border: Border.all(
                              color: activeCondition.accentColor.withValues(alpha: 0.7),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                activeCondition.icon,
                                size: 16,
                                color: activeCondition.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                activeCondition.getLocalizedName(lang),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Main Temperature & Weather Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${displayForecast.temperature.toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 64,
                                    fontWeight: FontWeight.w200,
                                    letterSpacing: -3,
                                    height: 1.0,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'C',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // High / Low Span
                            Text(
                              'H: ${displayForecast.temperatureMax.toStringAsFixed(0)}°   L: ${displayForecast.temperatureMin.toStringAsFixed(0)}°',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Prominent Weather Emblem with Glow
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: activeCondition.accentColor.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            activeCondition.icon,
                            size: 34,
                            color: activeCondition.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // "Feels Like" Indicator Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thermostat_rounded, size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.translate('feels_like')} ${displayForecast.apparentTemp.toStringAsFixed(0)}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${displayForecast.getFeelsLikeSummary(lang)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // 6-Card International Metrics Grid
        WeatherMetricsGrid(forecast: displayForecast),
      ],
    );
  }

  /// Chip for inspector
  Widget _buildConditionSelectorChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? activeColor,
  }) {
    final effectiveActiveColor = activeColor ?? const Color(0xFF0284C7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveActiveColor
                : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
            borderRadius: AppRadii.roundedPill,
            border: Border.all(
              color: isSelected
                  ? effectiveActiveColor
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
            ),
          ),
        ),
      ),
    );
  }

  String _getConditionEmoji(WeatherConditionType type) {
    switch (type) {
      case WeatherConditionType.sunny:
        return '☀️';
      case WeatherConditionType.partlyCloudy:
        return '⛅';
      case WeatherConditionType.cloudy:
        return '☁️';
      case WeatherConditionType.fog:
        return '🌫️';
      case WeatherConditionType.drizzle:
        return '🌦️';
      case WeatherConditionType.rainy:
        return '🌧️';
      case WeatherConditionType.thunderstorm:
        return '⚡';
      case WeatherConditionType.frost:
        return '❄️';
      case WeatherConditionType.windy:
        return '💨';
    }
  }

  /// Synthesizes simulated forecast for condition preview
  ForecastModel _buildSimulatedForecast(ForecastModel base, WeatherConditionData cond) {
    switch (cond.type) {
      case WeatherConditionType.sunny:
        return ForecastModel(
          date: base.date,
          maxTempC: 28.0,
          minTempC: 15.0,
          precipitationMm: 0.0,
          windSpeedKmh: 10.5,
          weatherCode: '0',
          description: cond.nameEn,
          precipitationProbability: 5.0,
          relativeHumidity: 42.0,
          uvIndex: 8.5,
          cloudCover: 10.0,
          windDirectionDeg: 120.0,
          surfacePressureHpa: 1018.0,
        );
      case WeatherConditionType.partlyCloudy:
        return ForecastModel(
          date: base.date,
          maxTempC: 25.0,
          minTempC: 14.0,
          precipitationMm: 0.5,
          windSpeedKmh: 14.0,
          weatherCode: '2',
          description: cond.nameEn,
          precipitationProbability: 25.0,
          relativeHumidity: 55.0,
          uvIndex: 6.0,
          cloudCover: 45.0,
          windDirectionDeg: 140.0,
          surfacePressureHpa: 1015.0,
        );
      case WeatherConditionType.cloudy:
        return ForecastModel(
          date: base.date,
          maxTempC: 21.0,
          minTempC: 13.0,
          precipitationMm: 1.2,
          windSpeedKmh: 16.0,
          weatherCode: '3',
          description: cond.nameEn,
          precipitationProbability: 40.0,
          relativeHumidity: 70.0,
          uvIndex: 3.5,
          cloudCover: 90.0,
          windDirectionDeg: 160.0,
          surfacePressureHpa: 1012.0,
        );
      case WeatherConditionType.rainy:
        return ForecastModel(
          date: base.date,
          maxTempC: 19.0,
          minTempC: 12.0,
          precipitationMm: 18.5,
          windSpeedKmh: 24.0,
          weatherCode: '65',
          description: cond.nameEn,
          precipitationProbability: 90.0,
          relativeHumidity: 88.0,
          uvIndex: 2.0,
          cloudCover: 98.0,
          windDirectionDeg: 210.0,
          surfacePressureHpa: 1004.0,
        );
      case WeatherConditionType.thunderstorm:
        return ForecastModel(
          date: base.date,
          maxTempC: 20.0,
          minTempC: 11.0,
          precipitationMm: 32.0,
          windSpeedKmh: 38.0,
          windGustsKmh: 58.0,
          weatherCode: '95',
          description: cond.nameEn,
          precipitationProbability: 95.0,
          relativeHumidity: 94.0,
          uvIndex: 1.5,
          cloudCover: 100.0,
          windDirectionDeg: 240.0,
          surfacePressureHpa: 998.0,
        );
      case WeatherConditionType.fog:
        return ForecastModel(
          date: base.date,
          maxTempC: 17.0,
          minTempC: 9.0,
          precipitationMm: 0.8,
          windSpeedKmh: 6.0,
          weatherCode: '45',
          description: cond.nameEn,
          precipitationProbability: 30.0,
          relativeHumidity: 96.0,
          uvIndex: 2.5,
          cloudCover: 85.0,
          windDirectionDeg: 80.0,
          surfacePressureHpa: 1016.0,
        );
      case WeatherConditionType.frost:
        return ForecastModel(
          date: base.date,
          maxTempC: 14.0,
          minTempC: 1.5,
          precipitationMm: 0.0,
          windSpeedKmh: 8.0,
          weatherCode: '71',
          description: cond.nameEn,
          precipitationProbability: 0.0,
          relativeHumidity: 65.0,
          uvIndex: 5.5,
          cloudCover: 5.0,
          windDirectionDeg: 350.0,
          surfacePressureHpa: 1025.0,
        );
      case WeatherConditionType.drizzle:
      case WeatherConditionType.windy:
        return base;
    }
  }
}
