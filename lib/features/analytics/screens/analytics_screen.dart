import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'WEEKLY';
  final List<String> _periods = ['DAILY', 'WEEKLY', 'MONTHLY'];

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsDataProvider(_selectedPeriod));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insights'),
        actions: [
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
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: _periods.map((period) {
                return ButtonSegment(
                  value: period,
                  label: Text(_formatPeriod(period)),
                );
              }).toList(),
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedPeriod = selection.first);
              },
            ),
          ),

          // Charts
          Expanded(
            child: analyticsAsync.when(
              data: (data) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(analyticsDataProvider(_selectedPeriod));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Risk Trends Chart
                    _buildRiskTrendsCard(data),
                    const SizedBox(height: 16),

                    // Alert Frequency Chart
                    _buildAlertFrequencyCard(data),
                    const SizedBox(height: 16),

                    // Crop Distribution Chart
                    _buildCropDistributionCard(data),
                    const SizedBox(height: 16),

                    // Regional Summary
                    _buildRegionalSummaryCard(data),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load analytics: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(analyticsDataProvider(_selectedPeriod));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTrendsCard(Map<String, dynamic> data) {
    final trends = data['riskTrends'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Level Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= trends.length) return const Text('');
                          return Text(
                            DateFormatter.formatShortDate(
                              DateTime.parse(trends[value.toInt()]['date']),
                            ),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: trends
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                (e.value['critical'] as num).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: trends
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                (e.value['high'] as num).toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Critical', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem('High', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertFrequencyCard(Map<String, dynamic> data) {
    final frequency = data['alertFrequency'] as Map<String, int>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alert Frequency by Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: frequency.isEmpty
                  ? const Center(child: Text('No data available'))
                  : PieChart(
                      PieChartData(
                        sections: frequency.entries.map((entry) {
                          return PieChartSectionData(
                            value: entry.value.toDouble(),
                            title: '${entry.value}',
                            color: _getHazardColor(entry.key),
                            radius: 80,
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
              children: frequency.entries.map((entry) {
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

  Widget _buildCropDistributionCard(Map<String, dynamic> data) {
    final distribution = data['cropDistribution'] as Map<String, int>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: distribution.isEmpty
                  ? const Center(child: Text('No data available'))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: distribution.values.fold(0, (a, b) => a > b ? a : b).toDouble() * 1.2,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final crops = distribution.keys.toList();
                                if (value.toInt() >= crops.length) return const Text('');
                                return Text(
                                  crops[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: distribution.entries.toList().asMap().entries.map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value.value.toDouble(),
                                color: Colors.green,
                                width: 20,
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
    final regional = data['regionalBreakdown'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regional Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (regional.isEmpty)
              const Center(child: Text('No regional data available'))
            else
              ...regional.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Chip(
                        label: Text('${entry.value} farms'),
                        backgroundColor: Colors.blue[50],
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text(
          'Choose export format:\n\n'
          '• PDF - Printable report\n'
          '• CSV - Raw data export',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export feature coming soon'),
                ),
              );
            },
            child: const Text('Export PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV export feature coming soon'),
                ),
              );
            },
            child: const Text('Export CSV'),
          ),
        ],
      ),
    );
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        return 'Weekly';
      case 'MONTHLY':
        return 'Monthly';
      default:
        return period;
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Color _getHazardColor(String hazardType) {
    switch (hazardType) {
      case 'DROUGHT':
        return Colors.brown;
      case 'FLOOD':
        return Colors.blue;
      case 'LOCUST_PEST':
        return Colors.red;
      case 'VEGETATION_STRESS':
        return Colors.orange;
      case 'FROST':
        return Colors.cyan;
      case 'HEAT_STRESS':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }
}
