import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/boundary_models.dart';

class BoundaryMapScreen extends StatelessWidget {
  final WoredaModel woreda;

  const BoundaryMapScreen({
    super.key,
    required this.woreda,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(woreda.centerLat, woreda.centerLng);

    return Scaffold(
      appBar: AppBar(
        title: Text(woreda.name),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 10.0,
          minZoom: 5.0,
          maxZoom: 18.0,
        ),
        children: [
          // Tile Layer (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agrietech.ewa_app',
            tileProvider: NetworkTileProvider(),
          ),

          // Polygon Layer (if GeoJSON is available)
          if (woreda.geojson != null) _buildPolygonLayer(),

          // Marker Layer (Center point)
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        woreda.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Attribution
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // In a real app, this would recenter the map
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Centered on woreda')),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildPolygonLayer() {
    // Simplified polygon rendering
    // In production, you would parse GeoJSON and create proper polygons
    return PolygonLayer(
      polygons: [
        Polygon(
          points: [
            LatLng(woreda.centerLat + 0.1, woreda.centerLng - 0.1),
            LatLng(woreda.centerLat + 0.1, woreda.centerLng + 0.1),
            LatLng(woreda.centerLat - 0.1, woreda.centerLng + 0.1),
            LatLng(woreda.centerLat - 0.1, woreda.centerLng - 0.1),
          ],
          color: Colors.blue.withValues(alpha: 0.3),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
          isFilled: true,
        ),
      ],
    );
  }
}
