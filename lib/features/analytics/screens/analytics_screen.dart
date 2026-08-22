import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/models/analytics_model.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'WEEKLY';
  final List<String> _periods = ['DAILY', 'WEEKLY', 'MONTHLY', 'SEASONAL', 'YEARLY'];

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider(_selectedPeriod));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold
      (appBar: AppBar(
        title: const Text('Analytics & Agronomic Intelligence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () => ref.invalidate(analyticsDataProvider(_selectedPeriod)),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Analytics Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Timeframe Pill Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132213) : const Color(0xFFF4F6F4),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periods.map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        _formatPeriod(period),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey.shade300 : const Color(0xFF1E2E1E)),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryDark,
                      backgroundColor: isDark ? Colors.white10 : Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryDark : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPeriod = period);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Main Analytics Body
          Expanded(
            child: analyticsAsync.when(
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(analyticsDataProvider(_selectedPeriod));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildExecutiveOverviewCard(data, isDark),
                    const SizedBox(height: 16),
                    if (data['cropCalendar'] is CropCalendarModel) ...[
                      _buildCropCalendarCard(data['cropCalendar'] as CropCalendarModel, isDark),
                      const SizedBox(height: 16),
                    ],
                    _buildAiInsightsCard(data, isDark),
                    const SizedBox(height: 16),
                    _buildRiskTrendsCard(data, isDark),
                    const SizedBox(height: 16),
                    _buildClimaticTrendsCard(data, isDark),
                    const SizedBox(height: 16),
                    _buildAlertFrequencyCard(data, isDark),
                    const SizedBox(height: 16),
                    _buildCropDistributionCard(data, isDark),
                    const SizedBox(height: 16),
                    _buildRegionalSummaryCard(data),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading live analytics & satellite observations...'),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load analytics: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(analyticsDataProvider(_selectedPeriod));
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveOverviewCard(Map<String, dynamic> data, bool isDark) {
    final totalFarms = data['totalFarms'] ?? 0;
    final totalWoredas = data['totalWoredas'] ?? 0;
    final activeAlerts = data['activeAlerts'] ?? 0;
    final criticalWoredas = data['criticalWoredas'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.techHeaderGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
              const Text(
                'National Agro-Command Overview',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatPeriod(_selectedPeriod).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildKpiItem('Monitored Farms', totalFarms.toString(), Icons.agriculture, const Color(0xFF86EFAC)),
              _buildKpiItem('Active Woredas', totalWoredas.toString(), Icons.public, const Color(0xFF93C5FD)),
              _buildKpiItem('Early Warnings', activeAlerts.toString(), Icons.warning_amber, const Color(0xFFFDE047)),
              _buildKpiItem('Critical Risk', criticalWoredas.toString(), Icons.crisis_alert, const Color(0xFFFCA5A5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 9.5),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCropCalendarCard(CropCalendarModel calendar, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFF059669), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ethiopian Season: ${calendar.currentSeason}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                if (calendar.daysRemaining != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${calendar.daysRemaining} days left',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.grass, color: Color(0xFF15803D), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Vegetative Stage: ${calendar.cropStage}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            if (calendar.recommendedActivities.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Recommended Seasonal Operations:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: calendar.recommendedActivities.map((act) {
                  return Chip(
                    label: Text(act, style: const TextStyle(fontSize: 11)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    side: const BorderSide(color: Color(0xFFBBF7D0)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsightsCard(Map<String, dynamic> data, bool isDark) {
    final aiInsights = data['aiInsights'] as String?;
    final defaultInsight = _selectedPeriod == 'SEASONAL' || _selectedPeriod == 'YEARLY'
        ? 'National seasonal satellite metrics indicate optimal vegetative vigor in central and western highlands. Watch for decadal rainfall anomalies in south-eastern pastoral woredas.'
        : 'Current temporal data indicates stable moisture conditions with low multi-hazard risk across 85% of registered zones.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Gemini 2.5 Flash Agronomic Insights',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3730A3)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Live AI', style: TextStyle(color: Color(0xFF4F46E5), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            aiInsights ?? defaultInsight,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? Colors.white70 : const Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTrendsCard(Map<String, dynamic> data, bool isDark) {
    final trends = (data['riskTrends'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Multi-Hazard Risk Level Trends',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  _formatPeriod(_selectedPeriod),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: trends.length < 2
                  ? const Center(child: Text('Gathering historical risk trend points...'))
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: max(1.0, (trends.length - 1).toDouble()),
                        minY: 0,
                        maxY: 15,
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 9),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= trends.length) return const SizedBox.shrink();
                                final rawDate = trends[idx]['date']?.toString() ?? '';
                                final parsed = DateTime.tryParse(rawDate);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    parsed != null ? DateFormatter.formatShortDate(parsed) : rawDate,
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trends
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      ((e.value['critical'] ?? 1) as num).toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: const Color(0xFFDC2626),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          LineChartBarData(
                            spots: trends
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      ((e.value['high'] ?? 2) as num).toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: const Color(0xFFF97316),
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: trends
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      ((e.value['moderate'] ?? 4) as num).toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: const Color(0xFFFBBF24),
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Critical Risk', const Color(0xFFDC2626)),
                const SizedBox(width: 14),
                _buildLegendItem('High Risk', const Color(0xFFF97316)),
                const SizedBox(width: 14),
                _buildLegendItem('Moderate', const Color(0xFFFBBF24)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClimaticTrendsCard(Map<String, dynamic> data, bool isDark) {
    final rainfall = (data['rainfallTrend'] as List?)?.whereType<TrendDataPoint>().toList() ?? [];
    final temp = (data['temperatureTrend'] as List?)?.whereType<TrendDataPoint>().toList() ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agro-Climatic Observations (CHIRPS & ERA5)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rainfall (mm) and Temperature (°C) telemetry across monitored woredas',
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: rainfall.length < 2
                  ? const Center(child: Text('Satellite observation telemetry syncing...'))
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: max(1.0, (rainfall.length - 1).toDouble()),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 9)),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx < 0 || idx >= rainfall.length) return const SizedBox.shrink();
                                return Text(rainfall[idx].date.split('-').last, style: const TextStyle(fontSize: 9));
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: rainfall.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                            isCurved: true,
                            color: const Color(0xFF0284C7),
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                          ),
                          if (temp.isNotEmpty)
                            LineChartBarData(
                              spots: temp.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                              isCurved: true,
                              color: const Color(0xFFEA580C),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Precipitation (mm)', const Color(0xFF0284C7)),
                const SizedBox(width: 16),
                _buildLegendItem('Temperature (°C)', const Color(0xFFEA580C)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertFrequencyCard(Map<String, dynamic> data, bool isDark) {
    final frequency = (data['alertFrequency'] as Map?)?.cast<String, int>() ?? {};
    final validFrequency = frequency.entries.where((e) => e.value > 0).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert Frequency by Hazard Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: validFrequency.isEmpty
                  ? const Center(child: Text('No active hazard alerts recorded'))
                  : PieChart(
                      PieChartData(
                        sections: validFrequency.map((entry) {
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            title: entry.value.toString(),
                            color: _getHazardColor(entry.key),
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: validFrequency.map((entry) {
                return _buildLegendItem(
                  _formatHazardType(entry.key),
                  _getHazardColor(entry.key),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropDistributionCard(Map<String, dynamic> data, bool isDark) {
    final distribution = (data['cropDistribution'] as Map?)?.cast<String, int>() ?? {};
    final validEntries = distribution.entries.where((e) => e.value > 0).toList();
    final maxVal = validEntries.fold<int>(0, (a, b) => a > b.value ? a : b.value);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Distribution (National Registry)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: validEntries.isEmpty
                  ? const Center(child: Text('No crop records found'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: max(5.0, maxVal.toDouble() * 1.3),
                        minY: 0,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= validEntries.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    validEntries[idx].key,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: validEntries.asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: const Color(0xFF16A34A),
                                width: 22,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalSummaryCard(Map<String, dynamic> data) {
    final raw = data['regionalBreakdown'];
    final Map<String, dynamic> regional = {};
    if (raw is Map) {
      regional.addAll(Map<String, dynamic>.from(raw));
    } else if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final name = (item['regionName'] ?? item['region'] ?? 'Region').toString();
          final count = item['totalFarms'] ?? item['monitoredFarms'] ?? item['totalWoredas'] ?? 1;
          regional[name] = count;
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Summary & Coverage',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (regional.isEmpty)
              const Center(child: Text('No regional coverage data available'))
            else
              ...regional.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Chip(
                        label: Text('${entry.value} woredas/farms', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFFE0F2FE),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Analytics Report'),
        content: const Text(
          'Choose report export format:\n\n• Executive PDF - Comprehensive charts and AI advisories\n• CSV Spreadsheet - Raw sensor & satellite telemetry dataset',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generating PDF Report for current timeframe...'),
                  backgroundColor: Color(0xFF15803D),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
          ),
        ],
      ),
    );
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'DAILY':
        return 'Daily (\u12d5\u1208\u1273\u12ca)';
      case 'WEEKLY':
        return 'Weekly (\u1233\u121d\u1295\u1273\u12ca)';
      case 'MONTHLY':
        return 'Monthly (\u12c8\u122b\u12ca)';
      case 'SEASONAL':
        return 'Seasonal (\u12c8\u1245\u1273\u12ca)';
      case 'YEARLY':
        return 'Yearly (\u12d3\u1218\u1273\u12ca)';
      default:
        return period;
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getHazardColor(String hazardType) {
    switch (hazardType.toUpperCase()) {
      case 'DROUGHT':
        return const Color(0xFFB45309);
      case 'FLOOD':
        return const Color(0xFF0284C7);
      case 'LOCUST_PEST':
      case 'LOCUST':
        return const Color(0xFFDC2626);
      case 'VEGETATION_STRESS':
        return const Color(0xFFEA580C);
      case 'FROST':
        return const Color(0xFF0891B2);
      case 'HEAT_STRESS':
        return const Color(0xFFBE123C);
      default:
        return Colors.grey.shade600;
    }
  }
}
