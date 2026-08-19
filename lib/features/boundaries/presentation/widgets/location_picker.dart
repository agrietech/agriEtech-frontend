import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Interactive Location and Coordinate Picker Widget
class LocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LatLng>? onLocationChanged;
  final String title;

  const LocationPicker({
    super.key,
    this.initialLocation,
    this.onLocationChanged,
    this.title = 'Select Farm GPS Centroid',
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ?? const LatLng(9.4167, 42.0167); // Haramaya
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
                onPressed: () {
                  const ethiopiaCenter = LatLng(9.145, 40.4896);
                  setState(() => _currentLocation = ethiopiaCenter);
                  _mapController.move(ethiopiaCenter, 13.0);
                  widget.onLocationChanged?.call(ethiopiaCenter);
                },
                tooltip: 'Center Location',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 12.0,
                onTap: (tapPosition, point) {
                  setState(() => _currentLocation = point);
                  widget.onLocationChanged?.call(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.agrietech.ewa_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFFDC2626),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lat: ${_currentLocation.latitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
              ),
              Text(
                'Lng: ${_currentLocation.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
              ),
              const Text(
                'Tap map to set pin',
                style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
