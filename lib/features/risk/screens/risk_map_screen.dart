import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../analytics/widgets/ethiopia_gis_map_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/agrietech_app_drawer.dart';

class RiskMapScreen extends ConsumerWidget {
  const RiskMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AgriEtechAppDrawer(),
      appBar: AppBar(
        title: const Text('Ethiopia Spatial Risk GIS Hub'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.crisis_alert_rounded),
            tooltip: 'Multi-Hazard Intelligence',
            onPressed: () => context.push('/disasters'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'GIS Legend & Sensor Sources',
            onPressed: () => _showMapInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Telemetry Summary Strip (Obsidian Glassmorphism)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.glassDark : AppTheme.glassLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight,
                ),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLiveTelemetryItem('🌋 MER Faults', 'Active Wonji', Colors.deepOrange),
                  const SizedBox(width: 16),
                  _buildLiveTelemetryItem('☀️ SPI-3 Drought', '2 Critical', AppTheme.telemetryDrought),
                  const SizedBox(width: 16),
                  _buildLiveTelemetryItem('🌊 Basin Flow', '3 High Flow', AppTheme.telemetryFlood),
                  const SizedBox(width: 16),
                  _buildLiveTelemetryItem('🌱 RUSLE Loss', '16 Belts', const Color(0xFF854D0E)),
                  const SizedBox(width: 16),
                  _buildLiveTelemetryItem('🛰️ Sentinel-2', 'Live Ingest', AppTheme.telemetryNdvi),
                ],
              ),
            ),
          ),


          // National Ethiopian GIS Map Viewport (Full Screen interactive)
          const Expanded(
            child: EthiopiaGisMapWidget(
              isFullScreen: true,
              initialLayer: DisasterMapLayer.allHazards,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTelemetryItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  void _showMapInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.public, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Ethiopian GIS Satellite Layers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This GIS platform is constrained to the sovereign territory of Ethiopia (3.2°N - 15.2°N, 32.8°E - 48.2°E) and provides real-time multi-hazard spatial shading based on:',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 12),
              Text('• USGS Earthquake API: Live seismic catalogue & Wonji Rift fault belt buffers.', style: TextStyle(fontSize: 11)),
              SizedBox(height: 6),
              Text('• RUSLE Model: Annual soil loss (t/ha/yr) from SRTM 30m DEM & Sentinel-2.', style: TextStyle(fontSize: 11)),
              SizedBox(height: 6),
              Text('• Geotechnical Landslides: Factor of Safety (FS) & SAR microwave moisture.', style: TextStyle(fontSize: 11)),
              SizedBox(height: 6),
              Text('• CHIRPS & GEE: Standardized Precipitation Index (SPI-3) drought metrics.', style: TextStyle(fontSize: 11)),
              SizedBox(height: 6),
              Text('• GloFAS Hydrology: Awash, Baro-Akobo & Blue Nile flood basin discharge.', style: TextStyle(fontSize: 11)),
              SizedBox(height: 6),
              Text('• MODIS FIRMS: Active volcanic calderas & thermal radiative power (FRP).', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
