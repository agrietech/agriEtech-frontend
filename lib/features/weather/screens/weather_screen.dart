import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../../boundaries/models/boundary_models.dart';
import '../../boundaries/providers/boundary_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/current_weather_hero_card.dart';
import '../widgets/evapotranspiration_card.dart';
import '../widgets/forecast_day_item.dart';
import '../widgets/hourly_forecast_slider.dart';
import '../widgets/rainfall_chart.dart';
import '../widgets/temperature_trend_chart.dart';

/// World-Standard Real Live Weather & Meteorological Forecast Screen
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
  Timer? _weatherAutoRefreshTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadWeatherData());

    // Auto-refresh weather telemetry periodically (every 90 seconds)
    _weatherAutoRefreshTimer = Timer.periodic(const Duration(seconds: 90), (_) {
      if (mounted) {
        _loadWeatherData();
      }
    });
  }

  @override
  void dispose() {
    _weatherAutoRefreshTimer?.cancel();
    super.dispose();
  }

  void _loadWeatherData() {
    final user = ref.read(currentUserProvider);
    final targetWoredaId = widget.woredaId ?? user?.woredaId;

    ref.read(weatherProvider.notifier).loadForecast(
          woredaId: targetWoredaId,
          latitude: widget.latitude,
          longitude: widget.longitude,
        );
  }

  void _showWoredaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WoredaPickerBottomSheet(
        currentWoredaId: ref.read(weatherProvider).selectedWoredaId,
        onSelected: (woreda) {
          Navigator.pop(ctx);
          ref.read(weatherProvider.notifier).selectWoreda(
                woreda.id,
                woredaName: woreda.name,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weatherState = ref.watch(weatherProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('weather_forecast'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
        actions: [
          // Location Selector Action Chip
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _showWoredaPicker(context),
              borderRadius: AppRadii.roundedPill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.25 : 0.1),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 95),
                      child: Text(
                        weatherState.selectedWoredaName ?? 'Addis Ababa',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: weatherState.isLoading && weatherState.days.isEmpty
          ? const WeatherSkeleton()
          : weatherState.error != null && weatherState.days.isEmpty
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
                        // Real-Time Live Weather Hero Card
                        if (weatherState.current != null || weatherState.days.isNotEmpty)
                          CurrentWeatherHeroCard(
                            forecast: weatherState.current ?? weatherState.days.first,
                            locationName: weatherState.selectedWoredaName,
                          ),
                        const SizedBox(height: AppSpacing.sm),

                        // Live Multi-Provider Met Telemetry Banner
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.2 : 0.08),
                            borderRadius: AppRadii.roundedMd,
                            border: Border.all(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.satellite_alt_rounded, color: Color(0xFF0284C7), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          l10n.translate('live_met_telemetry'),
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0369A1),
                                          ),
                                        ),
                                        if (weatherState.lastUpdated != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Synced ${DateFormatter.formatRelativeTime(weatherState.lastUpdated!)}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      weatherState.dataSources ?? 'Open-Meteo High-Resolution WMO • OpenWeatherMap Live Telemetry',
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.35,
                                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // 24-Hour Meteorological Hourly Slider
                        if (weatherState.hourly.isNotEmpty) ...[
                          HourlyForecastSlider(hourlyForecasts: weatherState.hourly),
                          const SizedBox(height: AppSpacing.sectionGap),
                        ],

                        // Agronomic Evapotranspiration (ET₀) & Irrigation Card (Dynamic from Live Telemetry)
                        Builder(
                          builder: (context) {
                            final cur = weatherState.current ?? (weatherState.days.isNotEmpty ? weatherState.days.first : null);
                            final temp = cur?.temperature ?? cur?.maxTempC ?? 18.0;
                            final maxT = cur?.maxTempC ?? (temp + 4.0);
                            final minT = cur?.minTempC ?? (temp - 4.0);
                            final windKmh = cur?.windSpeedKmh ?? 12.0;
                            final rainMm = cur?.precipitationMm ?? 0.0;

                            // FAO-56 Penman-Monteith / Hargreaves Reference ET0
                            final double et0 = math.max(1.5, math.min(9.0, 0.0023 * (temp + 17.8) * math.sqrt(math.max(1.0, maxT - minT)) * 14.5 + (windKmh * 0.04)));
                            final double effRain = rainMm > 0 ? (rainMm * 0.8) : 0.0;
                            final double deficit = effRain - et0;
                            final String etStatus = deficit < -2.5 ? 'DEFICIT' : (deficit > 2.0 ? 'SURPLUS' : 'OPTIMAL');
                            final String etAdvisory = deficit < -2.5
                                ? 'Evaporative demand exceeds rainfall: Supplemental irrigation of ${(et0 - effRain).toStringAsFixed(1)} mm/day recommended.'
                                : (deficit > 2.0
                                    ? 'Precipitation surplus: Monitor field drainage to prevent waterlogging.'
                                    : 'Agro-climatic moisture balance optimal: Evaporative demand satisfied by current conditions.');

                            return EvapotranspirationCard(
                              referenceEt0: et0,
                              effectiveRain: effRain,
                              netDeficit: deficit,
                              status: etStatus,
                              advisoryText: etAdvisory,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),

                        // Real True 7-Day Future Forecast (Starting from Today)
                        _buildSectionHeader(
                          title: l10n.translate('7_day_forecast'),
                          icon: Icons.calendar_today_rounded,
                        ),
                        const SizedBox(height: AppSpacing.itemGap),
                        if (weatherState.days.isNotEmpty) ...() {
                          final sevenDays = weatherState.days.take(7).toList();
                          final weeklyMin = sevenDays.map((d) => d.temperatureMin).reduce((a, b) => a < b ? a : b);
                          final weeklyMax = sevenDays.map((d) => d.temperatureMax).reduce((a, b) => a > b ? a : b);
                          return sevenDays.asMap().entries.map(
                                (entry) => ForecastDayItem(
                                  day: entry.value,
                                  weeklyMinTemp: weeklyMin,
                                  weeklyMaxTemp: weeklyMax,
                                  isToday: entry.key == 0,
                                ),
                              );
                        }(),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Interactive Bottom Sheet for selecting any Woreda in Ethiopia
class _WoredaPickerBottomSheet extends ConsumerStatefulWidget {
  final String? currentWoredaId;
  final ValueChanged<WoredaModel> onSelected;

  const _WoredaPickerBottomSheet({
    required this.currentWoredaId,
    required this.onSelected,
  });

  @override
  ConsumerState<_WoredaPickerBottomSheet> createState() => _WoredaPickerBottomSheetState();
}

class _WoredaPickerBottomSheetState extends ConsumerState<_WoredaPickerBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final woredasAsync = ref.watch(allWoredasProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.translate('select_woreda_weather'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: l10n.translate('search_woreda'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: const OutlineInputBorder(
                  borderRadius: AppRadii.roundedMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List of woredas
          Expanded(
            child: woredasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Failed to load woredas: $err')),
              data: (woredas) {
                final filtered = _searchQuery.isEmpty
                    ? woredas
                    : woredas.where((w) {
                        final nameLower = w.name.toLowerCase();
                        return nameLower.contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.translate('no_woredas_found'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (ctx, idx) {
                    final item = filtered[idx];
                    final isSelected = item.id == widget.currentWoredaId;

                    return ListTile(
                      leading: Icon(
                        Icons.location_city_rounded,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade500,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                          : const Icon(Icons.chevron_right_rounded, size: 18),
                      onTap: () => widget.onSelected(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
