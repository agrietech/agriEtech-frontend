import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/ndvi_model.dart';

/// Interactive NDVI (Normalized Difference Vegetation Index) Chart
class NdviChart extends StatelessWidget {
  final List<NdviModel>? data;
  final String title;

  const NdviChart({
    super.key,
    this.data,
    this.title = 'NDVI Vegetation Health Trend',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartData = data ?? _sampleNdviData;

    final spots = chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.ndviValue);
    }).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco, size: 14, color: Color(0xFF2E7D32)),
                    SizedBox(width: 4),
                    Text(
                      'MODIS / Sentinel-2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0.0,
                maxY: 1.0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) => FlLine(
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
                      interval: 0.2,
                      getTitlesWidget: (val, meta) => Text(
                        val.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < chartData.length) {
                          return Text(
                            chartData[idx].period,
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
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: const Color(0xFF2E7D32),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: const Color(0xFF2E7D32),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF2E7D32).withValues(alpha: 0.35),
                          const Color(0xFF2E7D32).withValues(alpha: 0.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Healthy (≥0.6)', const Color(0xFF2E7D32)),
              _buildLegend('Moderate (0.3-0.6)', const Color(0xFFF59E0B)),
              _buildLegend('Stressed (<0.3)', const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static final List<NdviModel> _sampleNdviData = [
    NdviModel(
      woredaId: 'w1',
      period: 'Dek 1',
      ndviValue: 0.42,
      vciValue: 45.0,
      healthStatus: 'MODERATE',
      observedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    NdviModel(
      woredaId: 'w1',
      period: 'Dek 2',
      ndviValue: 0.58,
      vciValue: 60.0,
      healthStatus: 'HEALTHY',
      observedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    NdviModel(
      woredaId: 'w1',
      period: 'Dek 3',
      ndviValue: 0.68,
      vciValue: 72.0,
      healthStatus: 'HEALTHY',
      observedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    NdviModel(
      woredaId: 'w1',
      period: 'Current',
      ndviValue: 0.74,
      vciValue: 80.0,
      healthStatus: 'HEALTHY',
      observedAt: DateTime.now(),
    ),
  ];
}
