import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/farms_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_view.dart';


class FarmsListScreen extends ConsumerStatefulWidget {
  const FarmsListScreen({super.key});

  @override
  ConsumerState<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends ConsumerState<FarmsListScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, size, date

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(farmsProvider.notifier).loadFarms());
  }

  Future<void> _refreshFarms() async {
    await ref.read(farmsProvider.notifier).refreshFarms();
  }

  List<dynamic> _getFilteredAndSortedFarms(List farms) {
    var filtered = farms.where((farm) {
      final name = (farm.farmName ?? '').toString().toLowerCase();
      final crop = (farm.primaryCrop ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || crop.contains(q);
    }).toList();

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => (a.farmName ?? '').toString().compareTo((b.farmName ?? '').toString()));
        break;
      case 'size':
        filtered.sort((a, b) => ((b.areaHectares ?? 0) as num).compareTo((a.areaHectares ?? 0) as num));
        break;
      case 'date':
        filtered.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);
    final statistics = ref.watch(farmStatisticsProvider);
    final authState = ref.watch(authProvider);

    String getScreenTitle() {
      if (authState.isFarmer) return 'My Farms';
      if (authState.isDevelopmentAgent) return 'Kebele Farm Registry';
      if (authState.isWoredaOfficer) return 'Woreda Farm Registry';
      if (authState.isZonalOfficer) return 'Zonal Farm Registry';
      if (authState.isRegionalOfficer) return 'Regional Farm Registry';
      if (authState.isResearcher) return 'Research Farm Plots';
      if (authState.isAdmin) return 'National Farm Registry';
      return 'Farm Registry';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getScreenTitle()),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: farmsState.isLoading ? null : _refreshFarms,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'size', child: Text('Sort by Size')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: _buildBody(context, farmsState, statistics),
      floatingActionButton: RoleUtils.canManageFarms(authState.user?.role)
          ? FloatingActionButton.extended(
              heroTag: 'fab_farms_list',
              onPressed: () => context.push('/farms/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Farm'),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, FarmsState state, FarmStatistics stats) {
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasFarms) {
      return const ListSkeleton(count: 4);
    }

    if (state.hasError && !state.hasFarms) {
      return AppErrorView(
        title: 'Failed to load farms',
        message: state.error?.message ?? 'Unknown error occurred while fetching farm registry.',
        onRetry: _refreshFarms,
      );
    }

    if (!state.hasFarms) {
      return EmptyStateView(
        icon: Icons.agriculture_rounded,
        title: 'No Registered Farms',
        message: 'Start by mapping your farm plot boundaries to receive hyper-local risk forecasts, weather alerts, and soil health monitoring.',
        actionLabel: 'Register Farm Plot',
        onAction: () => context.push('/farms/add'),
      );
    }

    final filteredFarms = _getFilteredAndSortedFarms(state.farms);

    return RefreshIndicator(
      onRefresh: _refreshFarms,
      child: Column(
        children: [
          // Statistics summary
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.landscape,
                  label: 'Total Farms',
                  value: stats.totalFarms.toString(),
                ),
                _StatItem(
                  icon: Icons.square_foot,
                  label: 'Total Area',
                  value: '${stats.totalArea.toStringAsFixed(1)} ha',
                ),
                _StatItem(
                  icon: Icons.grass,
                  label: 'Crop Types',
                  value: stats.cropDistribution.length.toString(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search farms...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Farms list
          Expanded(
            child: filteredFarms.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: theme.primaryColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No farms found',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFarms.length,
                    itemBuilder: (context, index) {
                      final farm = filteredFarms[index];
                      return _FarmCard(
                        farm: farm,
                        onTap: () => context.push('/farms/${farm.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: theme.primaryColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E2E1E),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final dynamic farm;
  final VoidCallback onTap;

  const _FarmCard({
    required this.farm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSensors = farm.sensors != null && farm.sensors.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.15),
                            theme.primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.agriculture,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  farm.farmName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.satellite_alt, size: 10, color: Color(0xFF10B981)),
                                    SizedBox(width: 4),
                                    Text(
                                      'NDVI 0.72',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.grass,
                                size: 15,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                farm.primaryCrop,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${farm.areaHectares.toStringAsFixed(2)} ha',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sensors,
                          size: 14,
                          color: hasSensors ? const Color(0xFF0284C7) : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasSensors
                              ? '${farm.sensors.length} IoT Sensor(s) Active'
                              : 'No Sensors Linked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: hasSensors ? const Color(0xFF0284C7) : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (farm.createdAt != null) ...[
                          Icon(
                            Icons.history,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormatter.formatRelativeTime(farm.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

