import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';

class ProfessionalDashboardScreen extends ConsumerStatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  ConsumerState<ProfessionalDashboardScreen> createState() =>
      _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState
    extends ConsumerState<ProfessionalDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Professional AppBar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.translate('dashboard'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      bottom: -50,
                      child: Icon(
                        Icons.agriculture,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/alerts'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(dashboardAnalyticsProvider),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Tab selector
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Trends'),
                      Tab(text: 'Regions'),
                    ],
                  ),
                ),

                // Tab content
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(),
                      _TrendsTab(),
                      _RegionsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Overview Tab with Risk Statistics
class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        final riskOverview = analytics.riskOverview;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Overview Cards
              Text(
                'Risk Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Risk Distribution Pie Chart
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: [
                                    PieChartSectionData(
                                      value: riskOverview.lowRisk.toDouble(),
                                      title: riskOverview.lowRisk.toString(),
                                      color: AppTheme.lowRiskColor,
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: riskOverview.moderateRisk.toDouble(),
                                      title: riskOverview.moderateRisk.toString(),
                                      color: AppTheme.moderateRiskColor,
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: riskOverview.highRisk.toDouble(),
                                      title: riskOverview.highRisk.toString(),
                                      color: AppTheme.highRiskColor,
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: riskOverview.criticalRisk.toDouble(),
                                      title: riskOverview.criticalRisk.toString(),
                                      color: AppTheme.criticalRiskColor,
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _RiskLegendItem(
                                    color: AppTheme.lowRiskColor,
                                    label: 'Low',
                                    value: riskOverview.lowRisk,
                                  ),
                                  const SizedBox(height: 8),
                                  _RiskLegendItem(
                                    color: AppTheme.moderateRiskColor,
                                    label: 'Moderate',
                                    value: riskOverview.moderateRisk,
                                  ),
                                  const SizedBox(height: 8),
                                  _RiskLegendItem(
                                    color: AppTheme.highRiskColor,
                                    label: 'High',
                                    value: riskOverview.highRisk,
                                  ),
                                  const SizedBox(height: 8),
                                  _RiskLegendItem(
                                    color: AppTheme.criticalRiskColor,
                                    label: 'Critical',
                                    value: riskOverview.criticalRisk,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Woredas Monitored',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${riskOverview.total}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Weather Summary
              Text(
                'Weather Today',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _WeatherMetric(
                            icon: Icons.thermostat,
                            label: 'Temperature',
                            value:
                                '${analytics.weatherSummary.avgTemperature.toStringAsFixed(1)}°C',
                          ),
                          _WeatherMetric(
                            icon: Icons.water_drop,
                            label: 'Rainfall',
                            value:
                                '${analytics.weatherSummary.totalRainfall.toStringAsFixed(1)}mm',
                          ),
                          _WeatherMetric(
                            icon: Icons.opacity,
                            label: 'Humidity',
                            value:
                                '${analytics.weatherSummary.avgHumidity.toStringAsFixed(0)}%',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crop Calendar
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          Text(
                            'Ethiopian Crop Calendar',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Season: ${analytics.cropCalendar.currentSeason}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crop Stage: ${analytics.cropCalendar.cropStage}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Recommended Activities:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...analytics.cropCalendar.recommendedActivities
                                .map((activity) => Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(activity)),
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error loading dashboard'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(dashboardAnalyticsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// Trends Tab with Line Charts
class _TrendsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(dashboardTrendsProvider('30_DAYS'));

    return trendsAsync.when(
      data: (trends) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Trend Chart
              _TrendCard(
                title: 'Risk Score Trend (30 Days)',
                color: Colors.orange,
                icon: Icons.trending_up,
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trends.riskTrend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.value,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Rainfall Trend
              _TrendCard(
                title: 'Rainfall Trend (30 Days)',
                color: Colors.blue,
                icon: Icons.water_drop,
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: trends.rainfallTrend
                          .asMap()
                          .entries
                          .map((e) => BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.value,
                                    color: Colors.blue,
                                    width: 8,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Temperature Trend
              _TrendCard(
                title: 'Temperature Trend (30 Days)',
                color: Colors.red,
                icon: Icons.thermostat,
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trends.temperatureTrend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.value,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // NDVI Trend
              _TrendCard(
                title: 'Vegetation Health (NDVI)',
                color: Colors.green,
                icon: Icons.grass,
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trends.ndviTrend
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.value,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error loading trends')),
    );
  }
}

// Regions Tab
class _RegionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    return analyticsAsync.when(
      data: (analytics) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: analytics.regionalBreakdown.length,
          itemBuilder: (context, index) {
            final region = analytics.regionalBreakdown[index];
            return _RegionalRiskCard(region: region);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('Error loading regions')),
    );
  }
}

// Supporting Widgets
class _RiskLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _RiskLegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Widget child;

  const _TrendCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _RegionalRiskCard extends StatelessWidget {
  final dynamic region;

  const _RegionalRiskCard({required this.region});

  @override
  Widget build(BuildContext context) {
    final total =
        region.lowRisk + region.moderateRisk + region.highRisk + region.criticalRisk;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.location_city, color: Colors.white),
        ),
        title: Text(
          region.regionName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$total Woredas • Avg Score: ${region.avgRiskScore.toStringAsFixed(2)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RiskBar(
                  label: 'Low',
                  value: region.lowRisk,
                  total: total,
                  color: AppTheme.lowRiskColor,
                ),
                const SizedBox(height: 8),
                _RiskBar(
                  label: 'Moderate',
                  value: region.moderateRisk,
                  total: total,
                  color: AppTheme.moderateRiskColor,
                ),
                const SizedBox(height: 8),
                _RiskBar(
                  label: 'High',
                  value: region.highRisk,
                  total: total,
                  color: AppTheme.highRiskColor,
                ),
                const SizedBox(height: 8),
                _RiskBar(
                  label: 'Critical',
                  value: region.criticalRisk,
                  total: total,
                  color: AppTheme.criticalRiskColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _RiskBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total * 100) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$value (${percentage.toStringAsFixed(0)}%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
