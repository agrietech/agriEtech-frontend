import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';

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
        title: const Text('IoT Sensor Network'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sensorListProvider.notifier).refresh();
              ref.invalidate(sensorStatisticsProvider);
            },
          ),
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
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: Icons.sensors_outlined,
                      title: 'No Active IoT Sensors',
                      message: 'Deploy LoRa/Cellular soil moisture, canopy temperature, and micro-climate nodes to capture ground-truth telemetry.',
                      actionLabel: 'Register Sensor Node',
                      onAction: () => context.push('/sensors/register'),
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
                child: ListSkeleton(count: 3),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: AppErrorView(
                  icon: Icons.sensors_off_rounded,
                  title: 'Unable to load sensors',
                  message: error.toString(),
                  onRetry: () => ref.read(sensorListProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleUtils.canManageSensors(user?.role)
          ? FloatingActionButton.extended(
              heroTag: 'fab_sensors_list',
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
    if (level >= 50) return AppTheme.primaryColor;
    if (level >= 20) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
