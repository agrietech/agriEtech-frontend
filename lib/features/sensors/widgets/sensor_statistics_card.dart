import 'package:flutter/material.dart';
import '../models/sensor_models.dart';

class SensorStatisticsCard extends StatelessWidget {
  final SensorStatistics statistics;

  const SensorStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    statistics.total,
                    Colors.blue,
                    Icons.sensors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Active',
                    statistics.active,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Inactive',
                    statistics.inactive,
                    Colors.grey,
                    Icons.cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Low Battery',
                    statistics.lowBattery,
                    Colors.red,
                    Icons.battery_alert,
                  ),
                ),
              ],
            ),

            // Sensor Type Distribution (if available)
            if (statistics.byType != null && statistics.byType!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'By Sensor Type',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statistics.byType!.entries
                    .map((entry) => _buildTypeChip(
                          context,
                          entry.key,
                          entry.value,
                        ))
                    .toList(),
              ),
            ],

            // Farm Distribution (if available)
            if (statistics.byFarm != null && statistics.byFarm!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'By Farm',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statistics.byFarm!.entries
                    .map((entry) => Chip(
                          label: Text(
                            '${entry.key}: ${entry.value}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          backgroundColor: Colors.grey[100],
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String sensorType, int count) {
    return Chip(
      avatar: Icon(
        _getSensorIcon(sensorType),
        size: 16,
        color: _getSensorColor(sensorType),
      ),
      label: Text(
        '${SensorTypes.getDisplayName(sensorType)}: $count',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: _getSensorColor(sensorType).withValues(alpha: 0.1),
      side: BorderSide(color: _getSensorColor(sensorType).withValues(alpha: 0.3)),
    );
  }

  IconData _getSensorIcon(String type) {
    switch (type) {
      case SensorTypes.soilMoisture:
        return Icons.water_drop;
      case SensorTypes.temperature:
        return Icons.thermostat;
      case SensorTypes.rainGauge:
        return Icons.shower;
      case SensorTypes.leafWetness:
        return Icons.grass;
      default:
        return Icons.sensors;
    }
  }

  Color _getSensorColor(String type) {
    switch (type) {
      case SensorTypes.soilMoisture:
        return Colors.blue;
      case SensorTypes.temperature:
        return Colors.orange;
      case SensorTypes.rainGauge:
        return Colors.indigo;
      case SensorTypes.leafWetness:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
