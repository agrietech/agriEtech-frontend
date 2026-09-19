import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/gis_geometry_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/boundary_provider.dart';

/// Interactive GIS Polygon Boundary Editor for Development Agents (DA) & Admins
/// Allows DA extension officers to map and update the official administrative boundary of their Kebele
class KebeleBoundaryEditorScreen extends ConsumerStatefulWidget {
  final String? kebeleId;
  final String? kebeleName;

  const KebeleBoundaryEditorScreen({
    super.key,
    this.kebeleId,
    this.kebeleName,
  });

  @override
  ConsumerState<KebeleBoundaryEditorScreen> createState() =>
      _KebeleBoundaryEditorScreenState();
}

class _KebeleBoundaryEditorScreenState
    extends ConsumerState<KebeleBoundaryEditorScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _polygonVertices = [];

  double _latitude = 8.54000;
  double _longitude = 39.27000;
  bool _isSaving = false;

  late String _effectiveKebeleId;
  late String _effectiveKebeleName;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _effectiveKebeleId =
        widget.kebeleId ?? user?.kebeleId ?? 'keb_adama_rural_01';
    _effectiveKebeleName =
        widget.kebeleName ?? user?.kebeleName ?? 'Assigned Kebele Extension';
  }

  double _calculatePolygonAreaKm2(List<LatLng> points) =>
      GisGeometryUtils.calculateSphericalPolygonAreaKm2(points);

  LatLng _calculateCentroid(List<LatLng> points) =>
      GisGeometryUtils.calculateCentroid(points,
          fallback: LatLng(_latitude, _longitude));

  Map<String, dynamic> _getPolygonGeoJson() {
    if (_polygonVertices.length < 3) return {};
    final List<List<double>> ring = _polygonVertices
        .map((p) => [
              double.parse(p.longitude.toStringAsFixed(6)),
              double.parse(p.latitude.toStringAsFixed(6))
            ])
        .toList();

    if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
      ring.add([ring.first[0], ring.first[1]]);
    }

    return {
      'type': 'Polygon',
      'coordinates': [ring],
    };
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    if (!Validators.isWithinEthiopia(point.latitude, point.longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected point falls outside Ethiopia'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _polygonVertices.add(point);
      final center = _calculateCentroid(_polygonVertices);
      _latitude = center.latitude;
      _longitude = center.longitude;
    });
  }

  void _undoLastVertex() {
    if (_polygonVertices.isNotEmpty) {
      setState(() {
        _polygonVertices.removeLast();
        if (_polygonVertices.isNotEmpty) {
          final center = _calculateCentroid(_polygonVertices);
          _latitude = center.latitude;
          _longitude = center.longitude;
        }
      });
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonVertices.clear();
    });
  }

  Future<void> _saveKebeleBoundary() async {
    if (_polygonVertices.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please mark at least 3 perimeter vertices to define your Kebele boundary.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final geojson = _getPolygonGeoJson();

    try {
      final repository = ref.read(boundaryRepositoryProvider);
      await repository.updateKebelePolygon(_effectiveKebeleId, geojson);

      if (mounted) {
        final areaKm2 = _calculatePolygonAreaKm2(_polygonVertices);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      'Kebele boundary updated successfully! ($areaKm2 km²)'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update Kebele boundary: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Permission guard: strictly for Development Agents & Admins
    if (!RoleUtils.canEditKebeleBoundary(authState.user?.role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kebele Boundary Editor')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded,
                    size: 64, color: Color(0xFFDC2626)),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Defining and updating official Kebele boundaries in GIS is reserved for Development Agents and System Administrators.\n\nYour current role is ${RoleUtils.getRoleDisplayName(authState.user?.role)}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final areaKm2 = _calculatePolygonAreaKm2(_polygonVertices);
    final areaHectares = (areaKm2 * 100.0).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kebele GIS Boundary: $_effectiveKebeleName',
            style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Polygon',
            onPressed: _polygonVertices.isNotEmpty ? _clearPolygon : null,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFE8F5E9),
            child: Row(
              children: [
                const Icon(Icons.account_balance,
                    color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Development Agent Scope • Kebele Jurisdiction',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade300
                              : const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _polygonVertices.length >= 3
                            ? 'Coverage: $areaKm2 km² (~$areaHectares ha) • ${_polygonVertices.length} Vertices'
                            : 'Tap points on the map to define the outer perimeter of your Kebele',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _polygonVertices.length >= 3
                              ? const Color(0xFF2E7D32)
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_polygonVertices.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.undo, size: 20),
                    tooltip: 'Undo Vertex',
                    onPressed: _undoLastVertex,
                  ),
              ],
            ),
          ),

          // Interactive GIS Map Canvas
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_latitude, _longitude),
                initialZoom: 12.0,
                minZoom: 6.0,
                maxZoom: 18.0,
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(
                    const LatLng(3.2, 32.8),
                    const LatLng(15.2, 48.2),
                  ),
                ),
                onTap: _onMapTapped,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  fallbackUrl:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.ethiofarm.app',
                  maxZoom: 19,
                ),
                if (_polygonVertices.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _polygonVertices,
                        color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                        borderColor: const Color(0xFF0369A1),
                        borderStrokeWidth: 3.0,
                        isFilled: true,
                      ),
                    ],
                  ),
                if (_polygonVertices.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          ..._polygonVertices,
                          if (_polygonVertices.length >= 3)
                            _polygonVertices.first,
                        ],
                        color: const Color(0xFF0369A1),
                        strokeWidth: 2.5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    ..._polygonVertices.asMap().entries.map((entry) {
                      return Marker(
                        point: entry.value,
                        width: 28,
                        height: 28,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0369A1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 4)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_polygonVertices.length >= 3)
                      Marker(
                        point: LatLng(_latitude, _longitude),
                        width: 32,
                        height: 32,
                        child: const Icon(Icons.location_city,
                            color: Colors.indigo, size: 28),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162518) : Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        _polygonVertices.isNotEmpty ? _undoLastVertex : null,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: (_isSaving || _polygonVertices.length < 3)
                          ? null
                          : _saveKebeleBoundary,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        _isSaving
                            ? 'Saving Boundary...'
                            : 'Save Kebele Boundary',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
