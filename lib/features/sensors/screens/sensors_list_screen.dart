import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/role_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/sensor_models.dart';
import '../providers/sensor_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/sensor_statistics_card.dart';
import 'register_sensor_screen.dart';
import 'sensor_detail_screen.dart';

class SensorsListScreen extends ConsumerWidget {
  const SensorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsAsync = ref.watch(sensorListProvider);
    final statistics = ref.watch(sensorStatisticsProvider);
    final lowBatterySensors = ref.watch(lowBatterySensorsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
        actions: [
          if (lowBatterySensors.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text(lowBatterySensors.length.toString()),
                child: const Icon(Icons.battery_alert),
              ),
              tooltip: 'Low Battery Sensors',
              onPressed: () => _showLowBatteryDialog(context, lowBatterySensors),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            tooltip: 'Clear Filters',
            onPressed: () {
              ref.read(sensorListProvider.notifier).clearFilters();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sensorListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Statistics Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SensorStatisticsCard(statistics: statistics),
              ),
            ),

            // Sensor List
            sensorsAsync.when(
              data: (sensors) {
                if (sensors.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sensors_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sensors available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register sensors to get started',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sensor = sensors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SensorCard(
                            sensor: sensor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SensorDetailScreen(
                                    sensor: sensor,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: sensors.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load sensors',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your network connection and try again.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(sensorListProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleUtils.canManageSensors(user?.role)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterSensorScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Register Sensor'),
            )
          : null,
    );
  }

  void _showLowBatteryDialog(
    BuildContext context,
    List<SensorModel> lowBatterySensors,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.red),
            SizedBox(width: 8),
            Text('Low Battery Sensors'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lowBatterySensors.length,
            itemBuilder: (context, index) {
              final sensor = lowBatterySensors[index];
              return ListTile(
                leading: Icon(
                  Icons.sensors,
                  color: _getBatteryColor(sensor.batteryLevel ?? 0),
                ),
                title: Text(sensor.hardwareId),
                subtitle: Text(
                  SensorTypes.getDisplayName(sensor.sensorType),
                ),
                trailing: Text(
                  '${sensor.batteryLevel?.toStringAsFixed(0) ?? '?'}%',
                  style: TextStyle(
                    color: _getBatteryColor(sensor.batteryLevel ?? 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    if (level >= 50) return const Color(0xFF43A047);
    if (level >= 20) return const Color(0xFFFB8C00);
    return const Color(0xFFD32F2F);
  }
}
