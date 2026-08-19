import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Farm Polygon Geofence Preview Map Widget
class FarmPolygonMap extends StatelessWidget {
  final List<LatLng>? polygonPoints;
  final LatLng? centroid;
  final double areaHectares;
  final double height;

  const FarmPolygonMap({
    super.key,
    this.polygonPoints,
    this.centroid,
    this.areaHectares = 2.5,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final center = centroid ??
        (polygonPoints != null && polygonPoints!.isNotEmpty
            ? polygonPoints!.first
            : const LatLng(9.4167, 42.0167)); // Haramaya coordinates

    final points = polygonPoints ?? _samplePolygon;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.agrietech.ewa_app',
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: points,
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    borderColor: const Color(0xFF2E7D32),
                    borderStrokeWidth: 2.5,
                    isFilled: true,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Area: ${areaHectares.toStringAsFixed(2)} ha',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const List<LatLng> _samplePolygon = [
    LatLng(9.4180, 42.0150),
    LatLng(9.4195, 42.0180),
    LatLng(9.4170, 42.0195),
    LatLng(9.4155, 42.0165),
  ];
}
