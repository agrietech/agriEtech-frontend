import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/alert_models.dart';
import '../providers/alert_provider.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_filter_chips.dart';
import '../widgets/alert_statistics_card.dart';
import 'create_alert_screen.dart';

class AlertsListScreen extends ConsumerStatefulWidget {
  const AlertsListScreen({super.key});

  @override
  ConsumerState<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends ConsumerState<AlertsListScreen> {
  String? _selectedSeverity;
  String? _selectedHazardType;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertListProvider);
    final statistics = ref.watch(alertStatisticsProvider);
    final user = ref.watch(currentUserProvider);

    final canCreateAlerts = RoleUtils.canCreateAlerts(user?.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts & Advisories',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Live backend status indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFF16A34A), size: 7),
                SizedBox(width: 4),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark All as Read',
            onPressed: () {
              ref.read(alertListProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All alerts marked as read'),
                  backgroundColor: Color(0xFF2E7D32),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            tooltip: 'Clear Filters',
            onPressed: () {
              setState(() {
                _selectedSeverity = null;
                _selectedHazardType = null;
              });
              ref.read(alertListProvider.notifier).clearFilters();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(alertListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Statistics Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AlertStatisticsCard(statistics: statistics),
              ),
            ),

            // Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AlertFilterChips(
                  selectedSeverity: _selectedSeverity,
                  selectedHazardType: _selectedHazardType,
                  onSeverityChanged: (severity) {
                    setState(() => _selectedSeverity = severity);
                    ref
                        .read(alertListProvider.notifier)
                        .filterBySeverity(severity);
                  },
                  onHazardTypeChanged: (hazardType) {
                    setState(() => _selectedHazardType = hazardType);
                    ref
                        .read(alertListProvider.notifier)
                        .filterByHazardType(hazardType);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Alert List
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: Icons.notifications_active_outlined,
                      title: 'All Clear — No Active Alerts',
                      message: 'There are currently no active drought, pest, flood, or frost hazards reported for your administrative jurisdiction.',
                      actionLabel: 'Refresh Hazard Telemetry',
                      onAction: () => ref.read(alertListProvider.notifier).refresh(),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alert = alerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AlertCard(
                            alert: alert,
                            onTap: () => _showAlertDetails(context, alert),
                          ),
                        );
                      },
                      childCount: alerts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: ListSkeleton(count: 3),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: AppErrorView(
                  icon: Icons.notifications_off_rounded,
                  title: 'Unable to load alerts',
                  message: error.toString(),
                  onRetry: () => ref.read(alertListProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreateAlerts
          ? FloatingActionButton.extended(
              heroTag: 'fab_alerts_list',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateAlertScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_alert),
              label: const Text('Create Alert'),
            )
          : null,
    );
  }

  void _showAlertDetails(BuildContext context, AlertModel alert) {
    if (!alert.isRead) {
      ref.read(alertListProvider.notifier).markAsRead(alert.id);
    }
    context.push('/alerts/${alert.id}', extra: alert);
  }
}
