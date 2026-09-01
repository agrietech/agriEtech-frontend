import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../models/forecast_model.dart';
import 'weather_stat_item.dart';

/// Hero weather summary card displaying current day temperature, condition and stats
class CurrentWeatherHeroCard extends StatelessWidget {
  final ForecastModel forecast;

  const CurrentWeatherHeroCard({
    super.key,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadii.roundedLg,
        gradient: AppTheme.techHeaderGradient,
        boxShadow: AppShadows.elevated(isDark: theme.brightness == Brightness.dark),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('today'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedPill,
                ),
                child: Text(
                  forecast.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${forecast.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherStatItem(
                icon: Icons.water_drop_outlined,
                label: l10n.translate('rainfall'),
                value: '${forecast.rainfall.toStringAsFixed(1)} mm',
              ),
              WeatherStatItem(
                icon: Icons.air_rounded,
                label: l10n.translate('humidity'),
                value: '${forecast.humidity.toStringAsFixed(0)}%',
              ),
              WeatherStatItem(
                icon: Icons.wind_power_rounded,
                label: l10n.translate('wind'),
                value: '${forecast.windSpeed.toStringAsFixed(1)} m/s',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
