import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/role_utils.dart';
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
        title: const Text('Alerts'),
        actions: [
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Alerts will appear here when created',
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
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load alerts',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your network connection and try again.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(alertListProvider.notifier).refresh(),
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
      floatingActionButton: canCreateAlerts
          ? FloatingActionButton.extended(
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  _getSeverityIcon(alert.severity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHazardTypeDisplay(alert.hazardType),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Message
              Text(
                'Message',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                alert.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 24),

              // Action Items
              if (alert.actionItems.isNotEmpty) ...[
                Text(
                  'Action Items',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...alert.actionItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
              ],

              // Details
              _buildDetailRow(
                context,
                'Severity',
                _getSeverityDisplay(alert.severity),
                _getSeverityColor(alert.severity),
              ),
              _buildDetailRow(
                context,
                'Priority',
                'Priority ${alert.priority}',
                null,
              ),
              if (alert.woreda != null)
                _buildDetailRow(
                  context,
                  'Location',
                  alert.woreda!.name,
                  null,
                ),
              _buildDetailRow(
                context,
                'Status',
                alert.isActive ? 'Active' : 'Expired',
                alert.isActive ? const Color(0xFF43A047) : Colors.grey,
              ),
              if (alert.validUntil != null)
                _buildDetailRow(
                  context,
                  'Valid Until',
                  DateFormatter.formatDateTime(
                      DateTime.parse(alert.validUntil!)),
                  null,
                ),
              _buildDetailRow(
                context,
                'Created',
                DateFormatter.formatRelative(DateTime.parse(alert.createdAt)),
                null,
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _getSeverityIcon(String severity) {
    final color = _getSeverityColor(severity);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.warning, color: color, size: 32),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'HIGH':
        return const Color(0xFFF4511E);
      case 'MODERATE':
        return const Color(0xFFFB8C00);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  String _getSeverityDisplay(String severity) {
    return severity[0] + severity.substring(1).toLowerCase();
  }

  String _getHazardTypeDisplay(String hazardType) {
    return hazardType.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
