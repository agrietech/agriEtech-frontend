import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../widgets/temperature_trend_chart.dart';
import '../widgets/rainfall_chart.dart';
import '../../../../core/l10n/app_localizations.dart';

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
    _loadWeatherData();
  }

  void _loadWeatherData() {
    if (widget.woredaId != null) {
      ref.read(weatherProviderProvider.notifier).loadForecast(
        woredaId: widget.woredaId,
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weatherState = ref.watch(weatherProviderProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('weather_forecast')),
        elevation: 0,
      ),
      body: weatherState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : weatherState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        weatherState.error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadWeatherData,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.translate('retry')),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadWeatherData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Current weather card
                        if (weatherState.days.isNotEmpty)
                          _buildCurrentWeatherCard(weatherState.days.first, theme, l10n),
                        const SizedBox(height: 20),

                        // 7-day forecast
                        _buildSectionTitle(l10n.translate('7_day_forecast'), Icons.calendar_today),
                        const SizedBox(height: 12),
                        if (weatherState.days.isNotEmpty)
                          ...weatherState.days
                              .take(7)
                              .map((day) => _buildForecastDay(day, theme, l10n)),
                        const SizedBox(height: 20),

                        // Temperature trend chart
                        _buildSectionTitle(
                          l10n.translate('temperature_trend'),
                          Icons.thermostat,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 200,
                              child: weatherState.forecast != null
                                  ? TemperatureTrendChart(forecast: weatherState.forecast!)
                                  : const Center(child: Text('No data')),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Rainfall chart
                        _buildSectionTitle(l10n.translate('rainfall'), Icons.water_drop),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 200,
                              child: weatherState.forecast != null
                                  ? RainfallChart(forecast: weatherState.forecast!)
                                  : const Center(child: Text('No data')),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green[700]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentWeatherCard(dynamic currentDay, ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.translate('today'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentDay.temperature?.toStringAsFixed(1) ?? '--'}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherStat(
                  icon: Icons.water_drop,
                  label: l10n.translate('rainfall'),
                  value: '${currentDay.rainfall?.toStringAsFixed(1) ?? '0'} mm',
                ),
                _buildWeatherStat(
                  icon: Icons.air,
                  label: l10n.translate('humidity'),
                  value: '${currentDay.humidity?.toStringAsFixed(0) ?? '--'}%',
                ),
                _buildWeatherStat(
                  icon: Icons.wind_power,
                  label: l10n.translate('wind'),
                  value: '${currentDay.windSpeed?.toStringAsFixed(1) ?? '--'} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastDay(dynamic day, ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getWeatherIcon(day.rainfall),
            color: Colors.blue[700],
          ),
        ),
        title: Text(
          _formatDate(day.date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${l10n.translate('rain')}: ${day.rainfall?.toStringAsFixed(1) ?? '0'} mm',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.thermostat, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${day.temperatureMax?.toStringAsFixed(0) ?? '--'}° / ${day.temperatureMin?.toStringAsFixed(0) ?? '--'}°',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(double? rainfall) {
    if (rainfall == null || rainfall < 1) return Icons.wb_sunny;
    if (rainfall < 10) return Icons.cloud;
    return Icons.water_drop;
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}';
  }
}
