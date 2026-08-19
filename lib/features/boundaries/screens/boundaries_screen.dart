import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boundary_models.dart';
import '../providers/boundary_provider.dart';
import 'boundary_map_screen.dart';

class BoundariesScreen extends ConsumerWidget {
  const BoundariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionsAsync = ref.watch(regionsProvider);
    final hierarchy = ref.watch(boundaryHierarchyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrative Boundaries'),
        actions: [
          if (hierarchy.selectedRegion != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Reset Selection',
              onPressed: () {
                ref.read(boundaryHierarchyProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Hierarchy breadcrumb
          if (hierarchy.selectedRegion != null ||
              hierarchy.selectedZone != null ||
              hierarchy.selectedWoreda != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ref.read(boundaryHierarchyProvider.notifier).getHierarchyString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: regionsAsync.when(
              data: (regions) {
                if (hierarchy.selectedWoreda != null) {
                  return _buildWoredaDetails(context, ref, hierarchy.selectedWoreda!);
                } else if (hierarchy.selectedZone != null) {
                  return _buildWoredasList(context, ref, hierarchy.woredas);
                } else if (hierarchy.selectedRegion != null) {
                  return _buildZonesList(context, ref, hierarchy.zones);
                } else {
                  return _buildRegionsList(context, ref, regions);
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load boundaries: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(regionsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsList(
    BuildContext context,
    WidgetRef ref,
    List<RegionModel> regions,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.public, color: Colors.blue),
            title: Text(region.name),
            subtitle: Text('Code: ${region.code}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(boundaryHierarchyProvider.notifier).selectRegion(region);
            },
          ),
        );
      },
    );
  }

  Widget _buildZonesList(
    BuildContext context,
    WidgetRef ref,
    List<ZoneModel> zones,
  ) {
    if (zones.isEmpty) {
      return const Center(
        child: Text('No zones available for this region'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: zones.length,
      itemBuilder: (context, index) {
        final zone = zones[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_city, color: Colors.orange),
            title: Text(zone.name),
            subtitle: zone.region != null ? Text(zone.region!.name) : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(boundaryHierarchyProvider.notifier).selectZone(zone);
            },
          ),
        );
      },
    );
  }

  Widget _buildWoredasList(
    BuildContext context,
    WidgetRef ref,
    List<WoredaModel> woredas,
  ) {
    if (woredas.isEmpty) {
      return const Center(
        child: Text('No woredas available for this zone'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: woredas.length,
      itemBuilder: (context, index) {
        final woreda = woredas[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.place, color: Colors.green),
            title: Text(woreda.name),
            subtitle: woreda.population != null
                ? Text('Population: ${woreda.population!.toStringAsFixed(0)}')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (woreda.geojson != null)
                  IconButton(
                    icon: const Icon(Icons.map),
                    tooltip: 'View on Map',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoundaryMapScreen(woreda: woreda),
                        ),
                      );
                    },
                  ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              ref.read(boundaryHierarchyProvider.notifier).selectWoreda(woreda);
            },
          ),
        );
      },
    );
  }

  Widget _buildWoredaDetails(
    BuildContext context,
    WidgetRef ref,
    WoredaModel woreda,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    woreda.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Center Coordinates',
                    '${woreda.centerLat.toStringAsFixed(4)}, ${woreda.centerLng.toStringAsFixed(4)}',
                    Icons.my_location,
                  ),
                  if (woreda.population != null)
                    _buildInfoRow(
                      'Population',
                      woreda.population!.toStringAsFixed(0),
                      Icons.people,
                    ),
                  if (woreda.zone != null)
                    _buildInfoRow(
                      'Zone',
                      woreda.zone!.name,
                      Icons.location_city,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (woreda.geojson != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoundaryMapScreen(woreda: woreda),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('View Boundary on Map'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
