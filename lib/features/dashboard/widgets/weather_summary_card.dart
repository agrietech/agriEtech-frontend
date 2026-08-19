import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/dashboard_models.dart';

class WeatherSummaryCard extends StatelessWidget {
  final WeatherSummary weatherSummary;
  final VoidCallback? onTap;

  const WeatherSummaryCard({
    super.key,
    required this.weatherSummary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = weatherSummary.current;
    final forecast = weatherSummary.forecast ?? [];

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weather Forecast',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                ],
              ),
              
              if (weatherSummary.alerts?.hasAlerts == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          weatherSummary.alerts!.warnings!.first,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (current != null) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _WeatherMetric(
                      icon: Icons.thermostat,
                      label: 'Temperature',
                      value: '${current.temperature.toStringAsFixed(1)}°C',
                      color: Colors.orange,
                    ),
                    _WeatherMetric(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${current.humidity.toStringAsFixed(0)}%',
                      color: Colors.blue,
                    ),
                    _WeatherMetric(
                      icon: Icons.water,
                      label: 'Rainfall',
                      value: '${current.rainfall.toStringAsFixed(1)}mm',
                      color: Colors.lightBlue,
                    ),
                  ],
                ),
              ],
              
              if (forecast.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: forecast.take(5).map((day) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _ForecastDay(forecast: day),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ForecastDay extends StatelessWidget {
  final DailyForecast forecast;

  const _ForecastDay({required this.forecast});

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.wb_cloudy;
    
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
      case 'overcast':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.water_drop;
      case 'stormy':
      case 'thunderstorm':
        return Icons.thunderstorm;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateFormatter.isToday(forecast.date);
    final dayName = isToday 
        ? 'Today' 
        : DateFormatter.getDayOfWeek(forecast.date).substring(0, 3);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday 
            ? theme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday
              ? theme.primaryColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            dayName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            _getWeatherIcon(forecast.condition),
            size: 32,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 8),
          Text(
            '${forecast.tempMax.toStringAsFixed(0)}°',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${forecast.tempMin.toStringAsFixed(0)}°',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          if (forecast.rainfall > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 12,
                  color: Colors.blue,
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.rainfall.toStringAsFixed(0)}mm',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
