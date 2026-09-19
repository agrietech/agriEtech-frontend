import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../../boundaries/models/boundary_models.dart';
import '../../boundaries/providers/boundary_provider.dart';
import '../providers/farms_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/l10n/app_localizations.dart';

class FarmsListScreen extends ConsumerStatefulWidget {
  const FarmsListScreen({super.key});

  @override
  ConsumerState<FarmsListScreen> createState() => _FarmsListScreenState();
}

class _FarmsListScreenState extends ConsumerState<FarmsListScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, size, date
  String? _selectedFarmId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(farmsProvider.notifier).loadFarms());
  }

  Future<void> _refreshFarms() async {
    await ref.read(farmsProvider.notifier).refreshFarms();
  }

  List<FarmModel> _getFilteredAndSortedFarms(
    List<FarmModel> farms,
    UserModel? user,
    List<WoredaModel> allowedWoredas,
  ) {
    var scoped = farms;
    if (user != null) {
      if (user.role == UserRole.farmer) {
        // Farmers only see their own farms
        scoped = farms.where((f) => f.userId.isEmpty || f.userId == user.id).toList();
      } else if (user.role == UserRole.developmentAgent) {
        // DAs only see farms in their assigned woreda
        final wId = user.woredaId;
        final wName = user.woreda?.name.toLowerCase();
        scoped = farms.where((f) {
          if (wId != null && f.woredaId != null) return f.woredaId == wId;
          if (wName != null && f.woreda?.name != null) return f.woreda!.name.toLowerCase().contains(wName);
          return true;
        }).toList();
      } else if (user.role == UserRole.woredaOfficer) {
        // Woreda Officers only see farms in their woreda
        final wId = user.woredaId;
        final wName = user.woreda?.name.toLowerCase();
        scoped = farms.where((f) {
          if (wId != null && f.woredaId != null) return f.woredaId == wId;
          if (wName != null && f.woreda?.name != null) return f.woreda!.name.toLowerCase().contains(wName);
          return true;
        }).toList();
      } else if (user.role == UserRole.zonalOfficer || user.role == UserRole.regionalOfficer) {
        // Zonal and Regional Officers only see farms in woredas belonging to their jurisdiction
        final allowedIds = allowedWoredas.map((w) => w.id).toSet();
        final allowedNames = allowedWoredas.map((w) => w.name.toLowerCase()).toSet();
        scoped = farms.where((f) {
          if (f.woredaId != null && allowedIds.contains(f.woredaId)) return true;
          if (f.woreda?.name != null && allowedNames.contains(f.woreda!.name.toLowerCase())) return true;
          return false;
        }).toList();
      }
      // Researcher and Admin see all
    }

    var filtered = scoped.where((farm) {
      final name = farm.farmName.toLowerCase();
      final crop = farm.primaryCrop.toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || crop.contains(q);
    }).toList();

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.farmName.compareTo(b.farmName));
        break;
      case 'size':
        filtered.sort((a, b) => b.areaHectares.compareTo(a.areaHectares));
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
    final l10n = AppLocalizations.of(context);

    String getScreenTitle() {
      if (authState.isFarmer) return l10n.translate('farms');
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
      floatingActionButton: RoleUtils.canAddFarm(authState.user?.role)
          ? FloatingActionButton.extended(
              heroTag: 'fab_farms_list',
              onPressed: () => context.push('/farms/add'),
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Add Farm (GIS Polygon)'),
            )
          : null,
    );
  }

  Future<void> _confirmDeleteFarm(BuildContext context, dynamic farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Delete Farm Plot?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${farm.farmName}"?\n\n'
          'This will permanently remove the GIS polygon boundary, telemetry logs, and sensor links.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Farm'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(farmsProvider.notifier).deleteFarm(farm.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Farm plot "${farm.farmName}" deleted.'),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete farm: $e'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildBody(BuildContext context, FarmsState state, FarmStatistics stats) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

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

    final allowedWoredas = ref.watch(scopedWoredasProvider).value ?? const [];
    final filteredFarms = _getFilteredAndSortedFarms(state.farms, authState.user, allowedWoredas);
    final totalScopedArea = filteredFarms.fold<double>(0.0, (sum, f) => sum + f.areaHectares);
    final cropSet = filteredFarms.map((f) => f.primaryCrop).where((c) => c.isNotEmpty).toSet();

    final statsBar = Container(
      padding: const EdgeInsets.all(16),
      color: theme.primaryColor.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.landscape,
            label: 'Total Farms',
            value: filteredFarms.length.toString(),
          ),
          _StatItem(
            icon: Icons.square_foot,
            label: 'Total Area',
            value: '${totalScopedArea.toStringAsFixed(1)} ha',
          ),
          _StatItem(
            icon: Icons.grass,
            label: 'Crop Types',
            value: cropSet.length.toString(),
          ),
        ],
      ),
    );

    final searchBar = Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.translate('search_farms'),
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
    );

    if (context.isWide) {
      final selectedFarm = filteredFarms.isEmpty
          ? null
          : filteredFarms.firstWhere(
              (f) => f.id == _selectedFarmId,
              orElse: () => filteredFarms.first,
            );

      return RefreshIndicator(
        onRefresh: _refreshFarms,
        child: Column(
          children: [
            statsBar,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 440,
                    child: Column(
                      children: [
                        searchBar,
                        Expanded(
                          child: filteredFarms.isEmpty
                              ? _buildEmptySearch(theme)
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredFarms.length,
                                  itemBuilder: (context, index) {
                                    final farm = filteredFarms[index];
                                    final isSelected = selectedFarm != null && farm.id == selectedFarm.id;
                                    return _FarmCard(
                                      farm: farm,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() => _selectedFarmId = farm.id);
                                      },
                                      onEdit: RoleUtils.canAddFarm(authState.user?.role)
                                          ? () => context.push('/farms/${farm.id}/edit', extra: farm)
                                          : null,
                                      onDelete: RoleUtils.canAddFarm(authState.user?.role)
                                          ? () => _confirmDeleteFarm(context, farm)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    child: selectedFarm == null
                        ? _buildEmptySearch(theme)
                        : _buildWideFarmPreview(context, selectedFarm, authState),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshFarms,
      child: Column(
        children: [
          statsBar,
          searchBar,
          Expanded(
            child: filteredFarms.isEmpty
                ? _buildEmptySearch(theme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFarms.length,
                    itemBuilder: (context, index) {
                      final farm = filteredFarms[index];
                      return _FarmCard(
                        farm: farm,
                        onTap: () => context.push('/farms/${farm.id}'),
                        onEdit: RoleUtils.canAddFarm(authState.user?.role)
                            ? () => context.push('/farms/${farm.id}/edit', extra: farm)
                            : null,
                        onDelete: RoleUtils.canAddFarm(authState.user?.role)
                            ? () => _confirmDeleteFarm(context, farm)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Center(
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
              l10n.translate('no_farms_registered'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.translate('select_farm_preview'),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideFarmPreview(BuildContext context, FarmModel farm, AuthState authState) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canEdit = RoleUtils.canAddFarm(authState.user?.role);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.headerDark,
                  AppTheme.primaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.agriculture_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.farmName.isNotEmpty ? farm.farmName : 'Farm Plot',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${farm.areaHectares.toStringAsFixed(1)} ha • ${farm.primaryCrop.isNotEmpty ? farm.primaryCrop : 'Mixed Crops'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/farms/${farm.id}'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open Detail'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Specifications Grid
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  theme,
                  icon: Icons.grass_rounded,
                  label: 'Primary Crop',
                  value: farm.primaryCrop.isNotEmpty ? farm.primaryCrop : 'Unspecified',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecTile(
                  theme,
                  icon: Icons.terrain_rounded,
                  label: 'Soil Type',
                  value: farm.soilType ?? 'Vertisol / Mixed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSpecTile(
                  theme,
                  icon: Icons.water_drop_rounded,
                  label: 'Irrigation',
                  value: farm.irrigationType ?? 'Rainfed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location & GIS Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_rounded, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Geospatial & Administrative Bounds',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Location: ${farm.woreda?.name ?? farm.woredaId ?? 'Ethiopia'} • GPS: ${farm.latitude.toStringAsFixed(4)}, ${farm.longitude.toStringAsFixed(4)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS Center: ${farm.latitude.toStringAsFixed(5)}, ${farm.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/farms/${farm.id}/intelligence'),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('Plan & Performance'),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/farms/${farm.id}/edit', extra: farm),
                    icon: const Icon(Icons.edit_location_alt_rounded),
                    label: const Text('Edit Polygon'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile(ThemeData theme, {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.primaryColor),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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
  final FarmModel farm;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _FarmCard({
    required this.farm,
    this.isSelected = false,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSensors = farm.sensors != null && farm.sensors!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.primaryColor.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? theme.primaryColor : Colors.grey.shade200,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isSelected ? 12 : 8,
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on, size: 10, color: Color(0xFF10B981)),
                                        const SizedBox(width: 4),
                                        Text(
                                          farm.woreda?.name ?? (hasSensors ? '${farm.sensors!.length} IoT Active' : 'GIS Polygon'),
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (onEdit != null || onDelete != null) ...[
                                    const SizedBox(width: 4),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade600),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onSelected: (val) {
                                        if (val == 'details') onTap();
                                        if (val == 'edit') onEdit?.call();
                                        if (val == 'delete') onDelete?.call();
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'details',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility_outlined, size: 16),
                                              SizedBox(width: 8),
                                              Text('View Details'),
                                            ],
                                          ),
                                        ),
                                        if (onEdit != null)
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_location_alt_outlined, size: 16, color: Color(0xFF1B5E20)),
                                                SizedBox(width: 8),
                                                Text('Edit GIS Polygon'),
                                              ],
                                            ),
                                          ),
                                        if (onDelete != null)
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 16, color: Color(0xFFDC2626)),
                                                SizedBox(width: 8),
                                                Text('Delete Farm', style: TextStyle(color: Color(0xFFDC2626))),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
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
                              ? '${farm.sensors!.length} IoT Sensor(s) Active'
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
                            DateFormatter.formatRelativeTime(farm.createdAt!),
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

