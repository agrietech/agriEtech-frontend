import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/sensor_models.dart';
import '../providers/sensor_provider.dart';

class SensorDetailScreen extends ConsumerStatefulWidget {
  final SensorModel sensor;

  const SensorDetailScreen({
    super.key,
    required this.sensor,
  });

  @override
  ConsumerState<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends ConsumerState<SensorDetailScreen> {
  String _selectedPeriod = '24h';
  final List<String> _periods = ['24h', '7d', '30d'];

  @override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(sensorTelemetryProvider((
      sensorId: widget.sensor.id,
      startDate: _getStartDate(),
      endDate: null,
      limit: _getLimit(),
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sensor.hardwareId),
        actions: [
          IconButton(
            icon: Icon(
              widget.sensor.isActive ? Icons.sensors : Icons.sensors_off,
            ),
            tooltip: widget.sensor.isActive ? 'Active' : 'Inactive',
            onPressed: null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sensorTelemetryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Sensor Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Hardware ID',
                      widget.sensor.hardwareId,
                      Icons.qr_code,
                    ),
                    _buildInfoRow(
                      context,
                      'Type',
                      SensorTypes.getDisplayName(widget.sensor.sensorType),
                      Icons.category,
                    ),
                    if (widget.sensor.farm != null)
                      _buildInfoRow(
                        context,
                        'Farm',
                        widget.sensor.farm!.farmName,
                        Icons.agriculture,
                      ),
                    _buildInfoRow(
                      context,
                      'Status',
                      widget.sensor.isActive ? 'Active' : 'Inactive',
                      widget.sensor.isActive ? Icons.check_circle : Icons.cancel,
                      valueColor: widget.sensor.isActive
                          ? Colors.green
                          : Colors.grey,
                    ),
                    if (widget.sensor.batteryLevel != null)
                      _buildBatteryRow(context, widget.sensor.batteryLevel!),
                    if (widget.sensor.lastCalibration != null)
                      _buildInfoRow(
                        context,
                        'Last Calibration',
                        DateFormatter.formatDate(
                          DateTime.parse(widget.sensor.lastCalibration!),
                        ),
                        Icons.tune,
                      ),
                    _buildInfoRow(
                      context,
                      'Registered',
                      DateFormatter.formatRelative(
                        DateTime.parse(widget.sensor.createdAt),
                      ),
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Period Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telemetry Data',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: _periods.map((period) {
                        return ButtonSegment(
                          value: period,
                          label: Text(_getPeriodLabel(period)),
                        );
                      }).toList(),
                      selected: {_selectedPeriod},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedPeriod = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Telemetry Charts
            telemetryAsync.when(
              data: (readings) {
                if (readings.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No telemetry data available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Different charts based on sensor type
                    if (_hasSoilMoistureData(readings))
                      _buildChart(
                        context,
                        'Soil Moisture',
                        readings,
                        (r) => r.soilMoisture,
                        '%',
                        Colors.blue,
                      ),
                    if (_hasSoilTempData(readings))
                      _buildChart(
                        context,
                        'Soil Temperature',
                        readings,
                        (r) => r.soilTemp,
                        '°C',
                        Colors.orange,
                      ),
                    if (_hasAmbientTempData(readings))
                      _buildChart(
                        context,
                        'Ambient Temperature',
                        readings,
                        (r) => r.ambientTemp,
                        '°C',
                        Colors.red,
                      ),
                    if (_hasHumidityData(readings))
                      _buildChart(
                        context,
                        'Humidity',
                        readings,
                        (r) => r.humidity,
                        '%',
                        Colors.cyan,
                      ),
                    if (_hasRainfallData(readings))
                      _buildChart(
                        context,
                        'Rainfall',
                        readings,
                        (r) => r.rainfallMm,
                        'mm',
                        Colors.indigo,
                      ),
                  ],
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load telemetry data',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryRow(BuildContext context, double level) {
    final color = _getBatteryColor(level);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(_getBatteryIcon(level), size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            'Battery',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: level / 100,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${level.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    String title,
    List<SensorReading> readings,
    double? Function(SensorReading) getValue,
    String unit,
    Color color,
  ) {
    final spots = <FlSpot>[];
    for (var i = 0; i < readings.length; i++) {
      final value = getValue(readings[i]);
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}$unit',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: spots.length > 10 ? spots.length / 5 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= readings.length) {
                            return const Text('');
                          }
                          final reading = readings[value.toInt()];
                          final time = DateTime.parse(reading.recordedAt);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormatter.formatTime(time),
                              style: const TextStyle(fontSize: 10),
                            ),
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
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case '24h':
        return 'Last 24h';
      case '7d':
        return 'Last 7 days';
      case '30d':
        return 'Last 30 days';
      default:
        return period;
    }
  }

  String? _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case '24h':
        return now.subtract(const Duration(hours: 24)).toIso8601String();
      case '7d':
        return now.subtract(const Duration(days: 7)).toIso8601String();
      case '30d':
        return now.subtract(const Duration(days: 30)).toIso8601String();
      default:
        return null;
    }
  }

  int _getLimit() {
    switch (_selectedPeriod) {
      case '24h':
        return 144; // Every 10 minutes
      case '7d':
        return 168; // Hourly
      case '30d':
        return 360; // Every 2 hours
      default:
        return 100;
    }
  }

  bool _hasSoilMoistureData(List<SensorReading> readings) {
    return readings.any((r) => r.soilMoisture != null);
  }

  bool _hasSoilTempData(List<SensorReading> readings) {
    return readings.any((r) => r.soilTemp != null);
  }

  bool _hasAmbientTempData(List<SensorReading> readings) {
    return readings.any((r) => r.ambientTemp != null);
  }

  bool _hasHumidityData(List<SensorReading> readings) {
    return readings.any((r) => r.humidity != null);
  }

  bool _hasRainfallData(List<SensorReading> readings) {
    return readings.any((r) => r.rainfallMm != null);
  }

  Color _getBatteryColor(double level) {
    if (level >= 50) return Colors.green;
    if (level >= 20) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon(double level) {
    if (level >= 90) return Icons.battery_full;
    if (level >= 60) return Icons.battery_5_bar;
    if (level >= 40) return Icons.battery_4_bar;
    if (level >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }
}
