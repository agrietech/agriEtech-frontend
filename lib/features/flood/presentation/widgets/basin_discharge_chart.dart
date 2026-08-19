import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/flood_risk_model.dart';

/// GloFAS River Basin Discharge Hydrograph Widget
class BasinDischargeChart extends StatelessWidget {
  final FloodRiskModel? floodRisk;
  final List<double>? dischargeSeries;
  final double? currentDischarge;
  final double? returnPeriod2Yr;
  final double? returnPeriod5Yr;

  const BasinDischargeChart({
    super.key,
    this.floodRisk,
    this.dischargeSeries,
    this.currentDischarge,
    this.returnPeriod2Yr,
    this.returnPeriod5Yr,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = dischargeSeries ?? _sampleDischarge;
    final curr = floodRisk?.riverDischarge ?? currentDischarge ?? 340.0;
    final t2 = returnPeriod2Yr ?? 400.0;
    final t5 = returnPeriod5Yr ?? 650.0;

    final spots = series.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final isAlert = curr >= t2;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'River Basin Discharge Hydrograph',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'GloFAS Forecast Flow Rate (m³/s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAlert
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlert ? Icons.warning_amber_rounded : Icons.water,
                      size: 14,
                      color: isAlert
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${curr.toStringAsFixed(0)} m³/s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAlert
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 800,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: t2,
                      color: const Color(0xFFF59E0B),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, bottom: 2),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                        labelResolver: (line) => '2-Yr Alarm ($t2)',
                      ),
                    ),
                    HorizontalLine(
                      y: t5,
                      color: const Color(0xFFDC2626),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 8, bottom: 2),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                        labelResolver: (line) => '5-Yr Alarm ($t5)',
                      ),
                    ),
                  ],
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: 200,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
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
                        final days = ['D-3', 'D-2', 'D-1', 'Today', 'D+1', 'D+2', 'D+3'];
                        final idx = val.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Text(
                            days[idx],
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
                    color: const Color(0xFF0284C7),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF0284C7),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0284C7).withValues(alpha: 0.25),
                          const Color(0xFF0284C7).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<double> _sampleDischarge = [
    180.0,
    220.0,
    290.0,
    340.0,
    420.0,
    390.0,
    310.0,
  ];
}
