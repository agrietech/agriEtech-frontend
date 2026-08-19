import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Historical Multi-Season Trend Chart Widget
class TrendChart extends StatelessWidget {
  final String title;
  final String subtitle;
  final String unit;
  final List<double>? currentSeries;
  final List<double>? baselineSeries;
  final List<String>? xLabels;
  final Color primaryColor;

  const TrendChart({
    super.key,
    this.title = 'Seasonal Precipitation vs 10-Yr Climatology',
    this.subtitle = 'Dekadal Rainfall Accumulation (mm)',
    this.unit = 'mm',
    this.currentSeries,
    this.baselineSeries,
    this.xLabels,
    this.primaryColor = const Color(0xFF0284C7),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curr = currentSeries ?? [45, 62, 88, 110, 140, 125, 95, 70, 40];
    final base = baselineSeries ?? [50, 55, 75, 90, 115, 110, 85, 60, 45];
    final labels = xLabels ?? ['D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', 'D9'];

    final spotsCurr = curr.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();
    final spotsBase = base.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(
                            labels[idx],
                            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Baseline series (dashed gray)
                  LineChartBarData(
                    spots: spotsBase,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: Colors.grey.shade400,
                    barWidth: 2,
                    dashArray: [4, 4],
                    dotData: const FlDotData(show: false),
                  ),
                  // Current series (solid primary color with fill)
                  LineChartBarData(
                    spots: spotsCurr,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: primaryColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withValues(alpha: 0.25),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Current Season ($unit)', primaryColor, isDashed: false),
              const SizedBox(width: 24),
              _buildLegend('10-Year Climatology Baseline', Colors.grey.shade500, isDashed: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, {required bool isDashed}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
