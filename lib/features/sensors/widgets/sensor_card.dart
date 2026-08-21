import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/sensor_models.dart';

class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  final VoidCallback? onTap;

  const SensorCard({
    super.key,
    required this.sensor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sensorColor = _getSensorColor(sensor.sensorType);
    final statusColor = sensor.isActive ? Colors.green : Colors.grey;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Sensor Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sensorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSensorIcon(sensor.sensorType),
                      color: sensorColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Sensor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.hardwareId,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          SensorTypes.getDisplayName(sensor.sensorType),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Status Indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sensor.isActive ? 'Active' : 'Inactive',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Battery Level
              if (sensor.batteryLevel != null) ...[
                Row(
                  children: [
                    Icon(
                      _getBatteryIcon(sensor.batteryLevel!),
                      size: 20,
                      color: _getBatteryColor(sensor.batteryLevel!),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Battery',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: sensor.batteryLevel! / 100,
                        backgroundColor: Colors.grey[200],
                        color: _getBatteryColor(sensor.batteryLevel!),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${sensor.batteryLevel!.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getBatteryColor(sensor.batteryLevel!),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Latest Reading Preview
              if (sensor.latestReading != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: _buildLatestReadingInfo(context, sensor.latestReading!),
                ),
                const SizedBox(height: 12),
              ],

              // Footer Row
              Row(
                children: [
                  // Farm
                  if (sensor.farm != null) ...[
                    Icon(Icons.agriculture, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        sensor.farm!.farmName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),

                  const SizedBox(width: 8),

                  // Last Updated
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatRelativeSafe(sensor.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestReadingInfo(BuildContext context, SensorReading reading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (reading.soilMoisture != null)
          _buildReadingValue(
            context,
            'Soil Moisture',
            '${reading.soilMoisture!.toStringAsFixed(1)}%',
          ),
        if (reading.soilTemp != null)
          _buildReadingValue(
            context,
            'Soil Temp',
            '${reading.soilTemp!.toStringAsFixed(1)}°C',
          ),
        if (reading.ambientTemp != null)
          _buildReadingValue(
            context,
            'Temp',
            '${reading.ambientTemp!.toStringAsFixed(1)}°C',
          ),
        if (reading.humidity != null)
          _buildReadingValue(
            context,
            'Humidity',
            '${reading.humidity!.toStringAsFixed(0)}%',
          ),
        if (reading.rainfallMm != null)
          _buildReadingValue(
            context,
            'Rainfall',
            '${reading.rainfallMm!.toStringAsFixed(1)}mm',
          ),
      ],
    );
  }

  Widget _buildReadingValue(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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

  IconData _getBatteryIcon(double level) {
    if (level >= 90) return Icons.battery_full;
    if (level >= 60) return Icons.battery_5_bar;
    if (level >= 40) return Icons.battery_4_bar;
    if (level >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(double level) {
    if (level >= 50) return Colors.green;
    if (level >= 20) return Colors.orange;
    return Colors.red;
  }
}
