import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_hero_card.dart';
import '../widgets/evapotranspiration_card.dart';
import '../widgets/forecast_day_item.dart';
import '../widgets/rainfall_chart.dart';
import '../widgets/temperature_trend_chart.dart';

/// Clean Architecture Weather Forecast Screen
class WeatherScreen extends ConsumerStatefulWidget {
  final String? woredaId;
  final double? latitude;
  final double? longitude;

  const WeatherScreen({
    super.key,
    this.woredaId,
    this.latitude,
    this.longitude,
  });

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadWeatherData());
  }

  void _loadWeatherData() {
    final user = ref.read(currentUserProvider);
    final targetWoredaId = widget.woredaId ?? user?.woredaId;
    if (targetWoredaId == null || targetWoredaId.isEmpty) {
      ref.read(weatherProvider.notifier).setMissingWoredaError();
      return;
    }
    ref.read(weatherProvider.notifier).loadForecast(
          woredaId: targetWoredaId,
          latitude: widget.latitude,
          longitude: widget.longitude,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weatherState = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('weather_forecast')),
        elevation: 0,
      ),
      body: weatherState.isLoading
          ? const WeatherSkeleton()
          : weatherState.error != null
              ? ErrorView(
                  message: weatherState.error!,
                  onRetry: _loadWeatherData,
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadWeatherData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Current weather hero card
                        if (weatherState.days.isNotEmpty)
                          CurrentWeatherHeroCard(forecast: weatherState.days.first),
                        const SizedBox(height: AppSpacing.sm),

                        // Sentinel-1 SAR Radar All-Weather Telemetry Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                            borderRadius: AppRadii.roundedMd,
                            border: Border.all(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.radar_rounded, color: Color(0xFF0284C7), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.translate('sar_radar_active'),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0369A1),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.translate('sar_radar_desc'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.35,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // Agronomic Evapotranspiration (ET₀) & Irrigation Card
                        const EvapotranspirationCard(),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // 7-day forecast
                        _buildSectionHeader(
                          title: l10n.translate('7_day_forecast'),
                          icon: Icons.calendar_today_rounded,
                        ),
                        const SizedBox(height: AppSpacing.itemGap),
                        if (weatherState.days.isNotEmpty)
                          ...weatherState.days
                              .take(7)
                              .map((day) => ForecastDayItem(day: day)),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // Temperature trend chart
                        _buildSectionHeader(
                          title: l10n.translate('temperature_trend'),
                          icon: Icons.thermostat_rounded,
                        ),
                        const SizedBox(height: AppSpacing.itemGap),
                        AppSurfaceCard(
                          child: SizedBox(
                            height: 200,
                            child: weatherState.forecastModel != null
                                ? TemperatureTrendChart(forecast: weatherState.forecastModel)
                                : Center(child: Text(l10n.translate('no_data'))),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // Rainfall chart
                        _buildSectionHeader(
                          title: l10n.translate('rainfall'),
                          icon: Icons.water_drop_rounded,
                        ),
                        const SizedBox(height: AppSpacing.itemGap),
                        AppSurfaceCard(
                          child: SizedBox(
                            height: 200,
                            child: weatherState.forecastModel != null
                                ? RainfallChart(forecast: weatherState.forecastModel)
                                : Center(child: Text(l10n.translate('no_data'))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: AppIconSize.md, color: AppTheme.primaryColor),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
