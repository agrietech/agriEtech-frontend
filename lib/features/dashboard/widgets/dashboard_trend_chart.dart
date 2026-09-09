import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/dashboard_models.dart';

/// Interactive multi-parameter trend chart for dashboard
class DashboardTrendChart extends StatefulWidget {
  final DashboardData dashboardData;

  const DashboardTrendChart({
    super.key,
    required this.dashboardData,
  });

  @override
  State<DashboardTrendChart> createState() => _DashboardTrendChartState();
}

class _DashboardTrendChartState extends State<DashboardTrendChart> {
  int _selectedMetric = 0; // 0: Rain, 1: NDVI, 2: Moisture

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final forecast = widget.dashboardData.weatherSummary.forecast ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getMetricColor(_selectedMetric).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMetricIcon(_selectedMetric),
                        size: 18,
                        color: _getMetricColor(_selectedMetric),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '7-Day Agronomic Trends',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'DAILY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented Metric Toggle
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildMetricPill(0, 'Rainfall (mm)', Icons.water_drop_outlined, const Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  _buildMetricPill(1, 'NDVI Health', Icons.eco_outlined, AppTheme.telemetryNdvi),
                  const SizedBox(width: 8),
                  _buildMetricPill(2, 'Soil Moisture (%)', Icons.grass_outlined, const Color(0xFF0D9488)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Chart Canvas
            SizedBox(
              height: 190,
              child: _buildChart(context, forecast, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricPill(int index, String label, IconData icon, Color activeColor) {
    final isSelected = _selectedMetric == index;
    return InkWell(
      onTap: () => setState(() => _selectedMetric = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : activeColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : activeColor,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context, List<DailyForecast> forecast, bool isDark) {
    final spots = _generateSpots(forecast);
    final color = _getMetricColor(_selectedMetric);
    final unit = _getMetricUnit(_selectedMetric);

    if (spots.isEmpty) {
      return const Center(child: Text('Loading trends...'));
    }

    double maxY = spots.map((s) => s.y).fold(0.0, math.max);
    if (_selectedMetric == 0) {
      maxY = math.max(15.0, maxY * 1.3);
    } else if (_selectedMetric == 1) {
      maxY = 1.0;
    } else {
      maxY = math.max(50.0, maxY * 1.2);
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1.0, (spots.length - 1).toDouble()),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                String formatted;
                if (_selectedMetric == 1) {
                  formatted = value.toStringAsFixed(1);
                } else {
                  formatted = value.toInt().toString();
                }
                return Text(
                  formatted,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= forecast.length) return const SizedBox.shrink();
                final day = forecast[idx].date;
                final isToday = DateFormatter.isToday(day);
                final label = isToday ? 'Today' : DateFormatter.getDayOfWeek(day).substring(0, 3);
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? color : Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final idx = spot.spotIndex;
                final dateStr = idx < forecast.length
                    ? DateFormatter.formatShortDate(forecast[idx].date)
                    : 'Day ${idx + 1}';
                return LineTooltipItem(
                  '$dateStr\n${spot.y.toStringAsFixed(_selectedMetric == 1 ? 2 : 1)} $unit',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(List<DailyForecast> forecast) {
    if (forecast.isEmpty) {
      // Generate synthetic 5-day spots if forecast array is empty
      final baseNdvi = widget.dashboardData.telemetry.averageNdvi;
      final baseSoil = widget.dashboardData.telemetry.soilMoisture;
      return List.generate(5, (i) {
        if (_selectedMetric == 0) return FlSpot(i.toDouble(), (i % 2 == 0 ? 3.5 : 0.0) + i * 0.8);
        if (_selectedMetric == 1) return FlSpot(i.toDouble(), math.min(0.9, baseNdvi + (i - 2) * 0.02));
        return FlSpot(i.toDouble(), math.min(60.0, baseSoil + (i - 2) * 1.5));
      });
    }

    final baseNdvi = widget.dashboardData.telemetry.averageNdvi;
    final baseSoil = widget.dashboardData.telemetry.soilMoisture;

    return forecast.asMap().entries.map((entry) {
      final idx = entry.key.toDouble();
      final item = entry.value;

      double val;
      if (_selectedMetric == 0) {
        val = item.rainfall;
      } else if (_selectedMetric == 1) {
        // NDVI: smooth trajectory based on rain and telemetry
        val = math.min(0.88, math.max(0.35, baseNdvi + (item.rainfall > 2 ? 0.04 : -0.02)));
      } else {
        // Soil Moisture: proportional to humidity and rainfall
        val = math.min(65.0, math.max(18.0, baseSoil + (item.rainfall * 1.8)));
      }
      return FlSpot(idx, val);
    }).toList();
  }

  Color _getMetricColor(int metric) {
    switch (metric) {
      case 0:
        return const Color(0xFF0284C7); // Rainfall sky blue
      case 1:
        return AppTheme.telemetryNdvi; // NDVI green
      case 2:
      default:
        return const Color(0xFF0D9488); // Soil moisture teal
    }
  }

  IconData _getMetricIcon(int metric) {
    switch (metric) {
      case 0:
        return Icons.water_drop;
      case 1:
        return Icons.eco;
      case 2:
      default:
        return Icons.grass;
    }
  }

  String _getMetricUnit(int metric) {
    switch (metric) {
      case 0:
        return 'mm';
      case 1:
        return 'Index';
      case 2:
      default:
        return '%';
    }
  }
}
