import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../models/boundary_models.dart';
import '../providers/boundary_provider.dart';
import '../repositories/boundary_local_cache.dart';

class BoundariesScreen extends ConsumerStatefulWidget {
  const BoundariesScreen({super.key});

  @override
  ConsumerState<BoundariesScreen> createState() => _BoundariesScreenState();
}

class _BoundariesScreenState extends ConsumerState<BoundariesScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMap = true;

  static const LatLng _ethiopiaCenter = LatLng(9.1450, 40.4897);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _flyTo(LatLng target, double zoom) {
    try {
      _mapController.move(target, zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(regionsProvider);
    final hierarchy = ref.watch(boundaryHierarchyProvider);
    final hierarchyNotifier = ref.read(boundaryHierarchyProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedRegion = hierarchy.selectedRegion;
    final selectedZone = hierarchy.selectedZone;
    final selectedWoreda = hierarchy.selectedWoreda;

    return Scaffold(
      drawer: const AgriEtechAppDrawer(),
      appBar: AppBar(
        title: const Text('Boundaries', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.map : Icons.map_outlined),
            tooltip: _showMap ? 'Hide Map Header' : 'Show Map Header',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
          if (selectedRegion != null || selectedZone != null || selectedWoreda != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Reset National Hierarchy',
              onPressed: () {
                hierarchyNotifier.reset();
                _flyTo(_ethiopiaCenter, 6.0);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF162518) : Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search any Region, Zone, or Woreda across Ethiopia...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark ? const Color(0xFF1F3522) : const Color(0xFFF1F5F2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),

          // Interactive Map Header
          if (_showMap)
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: selectedWoreda != null
                          ? LatLng(selectedWoreda.centerLat, selectedWoreda.centerLng)
                          : _ethiopiaCenter,
                      initialZoom: selectedWoreda != null ? 10.0 : 5.8,
                      minZoom: 4.5,
                      maxZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                        userAgentPackageName: 'com.agrietech.ewa_app',
                      ),
                      MarkerLayer(
                        markers: _buildMapMarkers(hierarchy),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_fixed, color: AppTheme.telemetryNdvi, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            selectedWoreda != null
                                ? '${selectedWoreda.name} (${selectedWoreda.centerLat.toStringAsFixed(2)}, ${selectedWoreda.centerLng.toStringAsFixed(2)})'
                                : (selectedRegion != null ? selectedRegion.name : 'National Boundary Grid'),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_map',
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      onPressed: () => _flyTo(_ethiopiaCenter, 5.8),
                      child: const Icon(Icons.fit_screen_rounded, size: 18),
                    ),
                  ),
                ],
              ),
            ),

          // Hierarchy Breadcrumbs Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFE8F5E9),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2E5E36) : const Color(0xFFA5D6A7),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      hierarchyNotifier.reset();
                      _flyTo(_ethiopiaCenter, 5.8);
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.public, color: Color(0xFF2E7D32), size: 16),
                        SizedBox(width: 4),
                        Text('Ethiopia', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (selectedRegion != null) ...[
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    InkWell(
                      onTap: () {
                        hierarchyNotifier.selectRegion(selectedRegion);
                      },
                      child: Text(
                        selectedRegion.name,
                        style: TextStyle(
                          color: selectedZone == null && selectedWoreda == null ? Colors.black87 : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (selectedZone != null) ...[
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    InkWell(
                      onTap: () {
                        hierarchyNotifier.selectZone(selectedZone);
                      },
                      child: Text(
                        selectedZone.name,
                        style: TextStyle(
                          color: selectedWoreda == null ? Colors.black87 : const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  if (selectedWoreda != null) ...[
                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    Text(
                      selectedWoreda.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B5E20)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Main Interactive Explorer Body
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(context, ref, _searchQuery)
                : regionsAsync.when(
                    data: (regions) {
                      if (selectedWoreda != null) {
                        return _buildWoredaDetails(context, ref, selectedWoreda);
                      } else if (selectedZone != null) {
                        return _buildWoredasList(context, ref, hierarchy.woredas);
                      } else if (selectedRegion != null) {
                        return _buildZonesAndWoredasHub(context, ref, hierarchy);
                      } else {
                        return _buildRegionsGrid(context, ref, regions);
                      }
                    },
                    loading: () => const SkeletonList(count: 6),
                    error: (err, _) => _buildRegionsGrid(context, ref, BoundaryLocalCache.defaultRegions),
                  ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMapMarkers(BoundaryHierarchy hierarchy) {
    final markers = <Marker>[];

    if (hierarchy.selectedWoreda != null) {
      final w = hierarchy.selectedWoreda!;
      markers.add(
        Marker(
          point: LatLng(w.centerLat, w.centerLng),
          width: 90,
          height: 70,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  w.name,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.location_on_rounded, color: Colors.red, size: 28),
            ],
          ),
        ),
      );
    } else if (hierarchy.woredas.isNotEmpty) {
      for (final w in hierarchy.woredas.take(25)) {
        markers.add(
          Marker(
            point: LatLng(w.centerLat, w.centerLng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                ref.read(boundaryHierarchyProvider.notifier).selectWoreda(w);
                _flyTo(LatLng(w.centerLat, w.centerLng), 10.0);
              },
              child: const Icon(Icons.place_rounded, color: Color(0xFF2E7D32), size: 24),
            ),
          ),
        );
      }
    }

    return markers;
  }

  Widget _buildRegionsGrid(BuildContext context, WidgetRef ref, List<RegionModel> regions) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.public, color: AppTheme.primaryColor, size: 22),
            ),
            title: Text(region.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              'Administrative Region • Code: ${region.code}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              ref.read(boundaryHierarchyProvider.notifier).selectRegion(region);
              _flyTo(_getRegionCenter(region.id), 7.2);
            },
          ),
        );
      },
    );
  }

  Widget _buildZonesAndWoredasHub(BuildContext context, WidgetRef ref, BoundaryHierarchy hierarchy) {
    final zones = hierarchy.zones;
    final woredas = hierarchy.woredas;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppTheme.primaryColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: 'Zones (ዞኖች)', icon: Icon(Icons.map_outlined, size: 18)),
              Tab(text: 'Regional Woredas (ወረዳዎች)', icon: Icon(Icons.holiday_village_outlined, size: 18)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Zones List
                ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: zones.length,
                  itemBuilder: (context, index) {
                    final zone = zones[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                          child: const Icon(Icons.location_city, color: Color(0xFF0284C7), size: 20),
                        ),
                        title: Text(zone.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Administrative Agricultural Zone', style: TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        onTap: () {
                          ref.read(boundaryHierarchyProvider.notifier).selectZone(zone);
                        },
                      ),
                    );
                  },
                ),

                // Regional Woredas List
                ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: woredas.length,
                  itemBuilder: (context, index) {
                    final woreda = woredas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.place_rounded, color: Color(0xFF2E7D32), size: 22),
                        title: Text(woreda.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('Lat: ${woreda.centerLat.toStringAsFixed(3)}, Lng: ${woreda.centerLng.toStringAsFixed(3)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          ref.read(boundaryHierarchyProvider.notifier).selectWoreda(woreda);
                          _flyTo(LatLng(woreda.centerLat, woreda.centerLng), 10.0);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWoredasList(BuildContext context, WidgetRef ref, List<WoredaModel> woredas) {
    if (woredas.isEmpty) {
      return const Center(
        child: Text('No woredas listed for this administrative zone.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: woredas.length,
      itemBuilder: (context, index) {
        final woreda = woredas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              child: const Icon(Icons.holiday_village_rounded, color: Color(0xFF2E7D32), size: 20),
            ),
            title: Text(woreda.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(
              'Centroid: ${woreda.centerLat.toStringAsFixed(4)}, ${woreda.centerLng.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            onTap: () {
              ref.read(boundaryHierarchyProvider.notifier).selectWoreda(woreda);
              _flyTo(LatLng(woreda.centerLat, woreda.centerLng), 10.5);
            },
          ),
        );
      },
    );
  }

  Widget _buildWoredaDetails(BuildContext context, WidgetRef ref, WoredaModel woreda) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.location_on, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        woreda.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Administrative Unit 3 • Woreda Desk',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Centroid Latitude', woreda.centerLat.toStringAsFixed(6), Icons.explore_outlined),
                  const Divider(),
                  _buildDetailRow('Centroid Longitude', woreda.centerLng.toStringAsFixed(6), Icons.explore_outlined),
                  const Divider(),
                  _buildDetailRow('Zone', woreda.zoneId, Icons.map_outlined),
                  const Divider(),
                  _buildDetailRow('Agro-Ecological System', 'Highland / Rift Belt', Icons.eco_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, String query) {
    final hierarchy = ref.watch(boundaryHierarchyProvider);
    final matchingWoredas = <WoredaModel>[];
    final matchingZones = <ZoneModel>[];
    final matchingRegions = <RegionModel>[];

    for (final r in hierarchy.regions) {
      if (r.name.toLowerCase().contains(query) || r.code.toLowerCase().contains(query)) {
        matchingRegions.add(r);
      }
    }

    for (final z in hierarchy.zones) {
      if (z.name.toLowerCase().contains(query)) {
        matchingZones.add(z);
      }
    }

    for (final w in hierarchy.woredas) {
      if (w.name.toLowerCase().contains(query)) {
        matchingWoredas.add(w);
      }
    }

    if (matchingRegions.isEmpty && matchingZones.isEmpty && matchingWoredas.isEmpty) {
      return Center(
        child: Text('No boundary results found for "$query".'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (matchingWoredas.isNotEmpty) ...[
          const Text('Woredas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32))),
          const SizedBox(height: 6),
          ...matchingWoredas.map((w) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, color: Color(0xFF2E7D32), size: 20),
                  title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Lat: ${w.centerLat}, Lng: ${w.centerLng}'),
                  onTap: () {
                    ref.read(boundaryHierarchyProvider.notifier).selectWoreda(w);
                    _flyTo(LatLng(w.centerLat, w.centerLng), 10.5);
                  },
                ),
              )),
          const SizedBox(height: 12),
        ],
        if (matchingZones.isNotEmpty) ...[
          const Text('Zones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0284C7))),
          const SizedBox(height: 6),
          ...matchingZones.map((z) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_city, color: Color(0xFF0284C7), size: 20),
                  title: Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    ref.read(boundaryHierarchyProvider.notifier).selectZone(z);
                  },
                ),
              )),
          const SizedBox(height: 12),
        ],
        if (matchingRegions.isNotEmpty) ...[
          const Text('Regions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20))),
          const SizedBox(height: 6),
          ...matchingRegions.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.public, color: Color(0xFF1B5E20), size: 20),
                  title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    ref.read(boundaryHierarchyProvider.notifier).selectRegion(r);
                    _flyTo(_getRegionCenter(r.id), 7.2);
                  },
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  LatLng _getRegionCenter(String regionId) {
    switch (regionId.toLowerCase()) {
      case 'reg_oromia':
      case 'et04':
        return const LatLng(8.54, 39.27);
      case 'reg_amhara':
      case 'et03':
        return const LatLng(11.59, 37.39);
      case 'reg_tigray':
      case 'et01':
        return const LatLng(13.49, 39.47);
      case 'reg_sidama':
      case 'et10':
        return const LatLng(7.05, 38.49);
      case 'reg_afar':
      case 'et02':
        return const LatLng(11.75, 41.00);
      case 'reg_somali':
      case 'et05':
        return const LatLng(7.50, 44.00);
      default:
        return _ethiopiaCenter;
    }
  }
}
