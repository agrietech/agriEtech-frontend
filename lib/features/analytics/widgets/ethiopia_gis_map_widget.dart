import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../farms/providers/farms_provider.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../risk/models/spatial_risk_model.dart';
import '../../risk/providers/gis_spatial_risk_provider.dart';

export '../../risk/models/spatial_risk_model.dart';

/// Master National GIS Map of Ethiopia for Multi-Hazard Disaster Intelligence
class EthiopiaGisMapWidget extends ConsumerStatefulWidget {
  final double? height;
  final bool isFullScreen;
  final DisasterMapLayer initialLayer;

  const EthiopiaGisMapWidget({
    super.key,
    this.height,
    this.isFullScreen = false,
    this.initialLayer = DisasterMapLayer.allHazards,
  });

  @override
  ConsumerState<EthiopiaGisMapWidget> createState() => _EthiopiaGisMapWidgetState();
}

class _EthiopiaGisMapWidgetState extends ConsumerState<EthiopiaGisMapWidget> {
  final MapController _mapController = MapController();
  late DisasterMapLayer _activeLayer;
  BaseMapType _baseMapType = BaseMapType.voyager;
  bool _showFaultLines = true;
  bool _showVolcanoes = true;
  bool _showRivers = true;
  bool _isLocating = false;
  LatLng? _userLocation;

  // Strict Ethiopian Camera Bounding Box
  static final LatLngBounds _ethiopiaBounds = LatLngBounds(
    const LatLng(3.2, 32.8),
    const LatLng(15.2, 48.2),
  );

  static const List<RegionCameraPreset> _regionPresets = [
    RegionCameraPreset('National Overview', LatLng(9.145, 40.489), 6.2),
    RegionCameraPreset('Central Wonji Rift (Adama)', LatLng(8.54, 39.27), 8.5),
    RegionCameraPreset('Afar Mega-Rift (Semara)', LatLng(11.79, 41.01), 8.0),
    RegionCameraPreset('Highland Escarpment (Debre Berhan)', LatLng(9.68, 39.53), 8.5),
    RegionCameraPreset('Western Acidic Zone (Nekemte)', LatLng(9.08, 36.55), 8.2),
    RegionCameraPreset('Southern Rift (Arba Minch & Gofa)', LatLng(6.03, 37.55), 8.5),
    RegionCameraPreset('Sidama Basin (Hawassa)', LatLng(7.05, 38.48), 8.5),
    RegionCameraPreset('Lake Tana Basin (Bahir Dar)', LatLng(11.59, 37.39), 8.2),
    RegionCameraPreset('Somali Lowlands (Jijiga)', LatLng(9.35, 42.80), 7.8),
    RegionCameraPreset('Southwestern Coffee Belt (Jimma)', LatLng(7.67, 36.83), 8.4),
    RegionCameraPreset('Bale Wheat Plateau (Robe)', LatLng(7.12, 40.00), 8.2),
    RegionCameraPreset('Tigray Basin (Mekelle)', LatLng(13.50, 39.47), 8.2),
    RegionCameraPreset('Eastern Foothills (Dire Dawa)', LatLng(9.60, 41.86), 8.5),
    RegionCameraPreset('Baro Flood Basin (Gambella)', LatLng(8.25, 34.58), 8.0),
    RegionCameraPreset('Western Belt (Asosa)', LatLng(10.06, 34.53), 8.0),
  ];

  // Active Tectonic Fault Lines across the Main Ethiopian Rift & Afar Depression
  static const List<FaultLineProfile> _faultLines = [
    FaultLineProfile(
      name: 'Main Ethiopian Rift (Central Wonji Fault Belt)',
      description: 'Active extensional quaternary fault system with high seismicity potential.',
      color: Color(0xFFDC2626),
      points: [
        LatLng(9.60, 39.90),
        LatLng(9.10, 39.60),
        LatLng(8.54, 39.27),
        LatLng(8.00, 38.80),
        LatLng(7.40, 38.40),
        LatLng(6.80, 37.90),
        LatLng(6.00, 37.50),
      ],
    ),
    FaultLineProfile(
      name: 'Afar Triple Junction Rift Boundary',
      description: 'Red Sea, Gulf of Aden & Main Ethiopian Rift junction zone with magmatic dyking.',
      color: Color(0xFFB91C1C),
      points: [
        LatLng(14.50, 40.30),
        LatLng(13.20, 40.80),
        LatLng(11.79, 41.01),
        LatLng(10.80, 41.60),
        LatLng(11.00, 42.50),
      ],
    ),
    FaultLineProfile(
      name: 'Western Escarpment Boundary Fault',
      description: 'Major normal boundary fault separating the Ethiopian Western Plateau from the Afar Rift.',
      color: Color(0xFFEA580C),
      points: [
        LatLng(13.80, 39.70),
        LatLng(12.20, 39.80),
        LatLng(10.50, 39.90),
        LatLng(9.68, 39.53),
      ],
    ),
  ];

  // Active Volcanic Centers & Geothermal Fields
  static const List<VolcanoProfile> _volcanoes = [
    VolcanoProfile(
      name: 'Erta Ale Shield Volcano',
      region: 'Afar (Danakil)',
      location: LatLng(13.60, 40.67),
      type: 'Basaltic Shield / Persistent Lava Lake',
      alertLevel: 'ORANGE (High Activity)',
      hazardRadiusKm: 25.0,
    ),
    VolcanoProfile(
      name: 'Dabbahu / Manda Hararo Fissure',
      region: 'Afar',
      location: LatLng(12.60, 40.50),
      type: 'Stratovolcano / Active Magma Dykes',
      alertLevel: 'YELLOW (Restless)',
      hazardRadiusKm: 20.0,
    ),
    VolcanoProfile(
      name: 'Mount Fentale Caldera',
      region: 'Oromia / Afar Border',
      location: LatLng(8.97, 39.93),
      type: 'Stratovolcano & Obsidian Lava Fields',
      alertLevel: 'ADVISORY (Geothermal Heat)',
      hazardRadiusKm: 18.0,
    ),
    VolcanoProfile(
      name: 'Alutu Geothermal Complex',
      region: 'Oromia (Lake Ziway)',
      location: LatLng(7.77, 38.78),
      type: 'Silicic Obsidian Dome & Fumaroles',
      alertLevel: 'GREEN (Monitored Geothermal)',
      hazardRadiusKm: 12.0,
    ),
    VolcanoProfile(
      name: 'Corbetti Caldera Complex',
      region: 'Sidama (Hawassa Basin)',
      location: LatLng(7.18, 38.43),
      type: 'Resurgent Caldera & Pumice Cones',
      alertLevel: 'YELLOW (Ground Uplift Detected)',
      hazardRadiusKm: 22.0,
    ),
    VolcanoProfile(
      name: 'Tullu Moye Magmatic Field',
      region: 'Oromia (Arsi)',
      location: LatLng(8.15, 39.13),
      type: 'Rhyolitic Volcanic Complex',
      alertLevel: 'GREEN (Exploratory Active)',
      hazardRadiusKm: 15.0,
    ),
  ];

  // Major Ethiopian River Basins & Flood Flow Paths
  static const List<RiverCorridorProfile> _riverCorridors = [
    RiverCorridorProfile(
      name: 'Awash River Basin',
      currentFlowM3s: 340.0,
      floodThresholdM3s: 450.0,
      path: [
        LatLng(9.00, 38.10),
        LatLng(8.60, 38.60),
        LatLng(8.40, 39.30),
        LatLng(8.90, 40.00),
        LatLng(9.70, 40.60),
        LatLng(11.00, 41.20),
        LatLng(11.70, 41.70),
      ],
    ),
    RiverCorridorProfile(
      name: 'Abbay / Blue Nile Basin',
      currentFlowM3s: 780.0,
      floodThresholdM3s: 1100.0,
      path: [
        LatLng(11.60, 37.40),
        LatLng(11.20, 37.80),
        LatLng(10.00, 38.20),
        LatLng(9.80, 36.80),
        LatLng(10.80, 35.20),
        LatLng(11.20, 35.00),
      ],
    ),
    RiverCorridorProfile(
      name: 'Baro-Akobo Basin (Gambella)',
      currentFlowM3s: 410.0,
      floodThresholdM3s: 500.0,
      path: [
        LatLng(7.80, 36.20),
        LatLng(8.10, 35.30),
        LatLng(8.25, 34.58),
        LatLng(8.30, 33.80),
      ],
    ),
    RiverCorridorProfile(
      name: 'Omo-Gibe Basin',
      currentFlowM3s: 310.0,
      floodThresholdM3s: 480.0,
      path: [
        LatLng(8.30, 37.50),
        LatLng(7.20, 37.20),
        LatLng(6.10, 36.70),
        LatLng(4.80, 36.10),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _activeLayer = widget.initialLayer;
  }

  String _getBaseMapUrl() {
    switch (_baseMapType) {
      case BaseMapType.voyager:
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
      case BaseMapType.topographic:
        return 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
      case BaseMapType.osm:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case BaseMapType.dark:
        return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
    }
  }

  Color _getPolygonColorForWoreda(WoredaSpatialProfile woreda) {
    switch (_activeLayer) {
      case DisasterMapLayer.seismology:
        return woreda.pgaG > 0.15
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.pgaG > 0.10 ? Colors.deepOrange.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.35));
      case DisasterMapLayer.soilDegradation:
        return woreda.soilLossTonsPerHa > 25.0
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.soilLossTonsPerHa > 12.0 ? const Color(0xFF854D0E).withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.35));
      case DisasterMapLayer.landslides:
        return woreda.slopePercent > 18.0
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.slopePercent > 10.0 ? Colors.orange.withValues(alpha: 0.5) : Colors.blueGrey.withValues(alpha: 0.35));
      case DisasterMapLayer.drought:
        return woreda.spi3 < -1.2
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.spi3 < -0.5 ? Colors.amber.shade900.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.35));
      case DisasterMapLayer.floods:
        return woreda.riverDischargeM3s > 250.0
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.riverDischargeM3s > 150.0 ? Colors.blue.shade800.withValues(alpha: 0.5) : Colors.teal.withValues(alpha: 0.35));
      case DisasterMapLayer.volcanoes:
        return woreda.nearestVolcanoDistKm < 40.0
            ? Colors.red.withValues(alpha: 0.55)
            : (woreda.nearestVolcanoDistKm < 80.0 ? Colors.brown.shade800.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.35));
      case DisasterMapLayer.allHazards:
      default:
        switch (woreda.riskLevel) {
          case 'CRITICAL':
            return const Color(0xFFDC2626).withValues(alpha: 0.55);
          case 'HIGH':
            return const Color(0xFFEA580C).withValues(alpha: 0.50);
          case 'MODERATE':
            return const Color(0xFFF59E0B).withValues(alpha: 0.45);
          case 'LOW':
          default:
            return const Color(0xFF10B981).withValues(alpha: 0.35);
        }
    }
  }

  Color _getPolygonBorderColorForWoreda(WoredaSpatialProfile woreda) {
    switch (woreda.riskLevel) {
      case 'CRITICAL':
        return Colors.red.shade900;
      case 'HIGH':
        return Colors.deepOrange.shade900;
      case 'MODERATE':
        return Colors.amber.shade900;
      case 'LOW':
      default:
        return Colors.green.shade800;
    }
  }

  Future<void> _locateUser() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        final loc = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _userLocation = loc;
          _isLocating = false;
        });
        _mapController.move(loc, 9.0);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Position locked: ${pos.latitude.toStringAsFixed(3)}°N, ${pos.longitude.toStringAsFixed(3)}°E'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _isLocating = false);
      }
    } catch (_) {
      setState(() => _isLocating = false);
    }
  }

  void _showWoredaInspectorSheet(WoredaSpatialProfile woreda) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132213) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Ribbon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          woreda.woredaName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${woreda.region} • ${woreda.aez} • Elev: ${woreda.elevation}m',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPolygonBorderColorForWoreda(woreda).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getPolygonBorderColorForWoreda(woreda)),
                    ),
                    child: Text(
                      '${(woreda.compositeRisk * 100).toStringAsFixed(0)}% Risk',
                      style: TextStyle(
                        color: _getPolygonBorderColorForWoreda(woreda),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4 Core Live Telemetry KPI Tiles
              Row(
                children: [
                  Expanded(child: _buildInspectorTile('PGA Shaking', '${woreda.pgaG}g', Colors.deepOrange, Icons.vibration_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInspectorTile('RUSLE Loss', '${woreda.soilLossTonsPerHa} t/ha', const Color(0xFF854D0E), Icons.terrain_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInspectorTile('SPI-3 Drought', woreda.spi3.toStringAsFixed(2), Colors.amber.shade900, Icons.wb_sunny_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInspectorTile('River Flow', '${woreda.riverDischargeM3s.toStringAsFixed(0)} m³/s', Colors.blue.shade800, Icons.flood_rounded)),
                ],
              ),
              const SizedBox(height: 16),

              // Actionable Multi-language Advisory Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppTheme.primaryColor, size: 18),
                        SizedBox(width: 6),
                        Text('Actionable Agronomic & Disaster Protocol:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('አማርኛ፡ ${woreda.amharicAdvisory}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Afaan Oromoo: ${woreda.oromoAdvisory}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Direct 1-Tap Navigation Buttons to Dedicated Screens
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.vibration, size: 16),
                      label: const Text('Seismology', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/seismology');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.terrain, size: 16),
                      label: const Text('Soil Loss', style: TextStyle(fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/soil-degradation');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      icon: const Icon(Icons.crisis_alert, size: 16, color: Colors.white),
                      label: const Text('Full Intel', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/disasters');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVolcanoDetails(VolcanoProfile volcano) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 24),
            const SizedBox(width: 8),
            Expanded(child: Text(volcano.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Region: ${volcano.region}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Text('Volcanic Morphology: ${volcano.type}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text('Aviation/Civic Alert: ${volcano.alertLevel}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Text('Hazard Exclusion Zone: ${volcano.hazardRadiusKm} km radius', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/volcanic-hazard');
            },
            child: const Text('Volcano Intel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSearchWoredaPicker(List<WoredaSpatialProfile> woredas) {
    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = woredas.where((w) {
              final q = query.toLowerCase();
              return w.woredaName.toLowerCase().contains(q) || w.region.toLowerCase().contains(q);
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.travel_explore, color: AppTheme.primaryColor),
                  SizedBox(width: 10),
                  Text('Fly to Woreda on Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search woreda or region...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (val) => setDialogState(() => query = val),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.location_on, color: _getPolygonBorderColorForWoreda(item), size: 20),
                            title: Text(item.woredaName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('${item.region} • ${(item.compositeRisk * 100).toStringAsFixed(0)}% Risk'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              Navigator.pop(ctx);
                              _mapController.move(item.centroid, 8.8);
                              _showWoredaInspectorSheet(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
              ],
            );
          },
        );
      },
    );
  }

  void _showLayersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GIS Map Layers & Basemap Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              const Text('Cartographic Basemap:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Voyager (Clean GIS)'),
                    selected: _baseMapType == BaseMapType.voyager,
                    onSelected: (_) {
                      setState(() => _baseMapType = BaseMapType.voyager);
                      setSheetState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Topographic (Relief)'),
                    selected: _baseMapType == BaseMapType.topographic,
                    onSelected: (_) {
                      setState(() => _baseMapType = BaseMapType.topographic);
                      setSheetState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('OpenStreetMap'),
                    selected: _baseMapType == BaseMapType.osm,
                    onSelected: (_) {
                      setState(() => _baseMapType = BaseMapType.osm);
                      setSheetState(() {});
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Dark Matter'),
                    selected: _baseMapType == BaseMapType.dark,
                    onSelected: (_) {
                      setState(() => _baseMapType = BaseMapType.dark);
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Tectonic Fault Lines (Wonji Rift & Afar)'),
                value: _showFaultLines,
                onChanged: (val) {
                  setState(() => _showFaultLines = val);
                  setSheetState(() {});
                },
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Volcanic Centers & Calderas'),
                value: _showVolcanoes,
                onChanged: (val) {
                  setState(() => _showVolcanoes = val);
                  setSheetState(() {});
                },
              ),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Major River Flood Corridors (Awash, Abbay, Baro)'),
                value: _showRivers,
                onChanged: (val) {
                  setState(() => _showRivers = val);
                  setSheetState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInspectorTile(String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center),
          Text(title, style: TextStyle(fontSize: 8, color: Colors.grey.shade700), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);
    final alertsState = ref.watch(alertsProvider);
    final liveWoredasAsync = ref.watch(liveSpatialRiskProfilesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final registeredFarms = farmsState.farms;

    // Use live updated profiles when ready, otherwise baseline default profiles
    final List<WoredaSpatialProfile> woredas = liveWoredasAsync.asData?.value ?? defaultWoredaSpatialProfiles;
    final isLiveSyncing = liveWoredasAsync.isLoading;
    final activeAlerts = alertsState.asData?.value ?? [];

    final mapWidget = FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(9.145, 40.489),
        initialZoom: 6.2,
        minZoom: 5.0,
        maxZoom: 14.0,
        cameraConstraint: CameraConstraint.containCenter(bounds: _ethiopiaBounds),
        onTap: (_, point) {
          // Find closest woreda within radius
          for (final woreda in woredas) {
            final dist = const Distance().as(LengthUnit.Kilometer, point, woreda.centroid);
            if (dist < 40.0) {
              _showWoredaInspectorSheet(woreda);
              return;
            }
          }
        },
      ),
      children: [
        // 1. Base Cartographic Tile Layer
        TileLayer(
          urlTemplate: _getBaseMapUrl(),
          userAgentPackageName: 'com.agrietech.app',
          errorTileCallback: (tile, error, stackTrace) {
            // Graceful offline / network tile recovery
          },
        ),

        // 2. Tectonic Rift Fault Lines (Polyline Layer)
        if (_showFaultLines)
          PolylineLayer(
            polylines: _faultLines.map((f) {
              return Polyline(
                points: f.points,
                color: f.color.withValues(alpha: 0.8),
                strokeWidth: 3.5,
                isDotted: true,
              );
            }).toList(),
          ),

        // 3. River Flow Flood Corridors (Polyline Layer)
        if (_showRivers)
          PolylineLayer(
            polylines: _riverCorridors.map((r) {
              final isFlooding = r.currentFlowM3s >= r.floodThresholdM3s;
              return Polyline(
                points: r.path,
                color: isFlooding ? Colors.red.withValues(alpha: 0.9) : Colors.blue.withValues(alpha: 0.75),
                strokeWidth: 3.0,
              );
            }).toList(),
          ),

        // 4. Ethiopian Administrative Woreda Choropleth Polygons Layer (Live Shaded)
        PolygonLayer(
          polygons: woredas.map((w) {
            return Polygon(
              points: w.polygon,
              color: _getPolygonColorForWoreda(w),
              borderColor: _getPolygonBorderColorForWoreda(w),
              borderStrokeWidth: 2.0,
              isFilled: true,
            );
          }).toList(),
        ),

        // 5. Volcanic Hazard Buffer Zones (Circle Layer)
        if (_showVolcanoes)
          CircleLayer(
            circles: _volcanoes.map((v) {
              return CircleMarker(
                point: v.location,
                radius: v.hazardRadiusKm * 1000, // in meters
                useRadiusInMeter: true,
                color: Colors.deepOrange.withValues(alpha: 0.15),
                borderColor: Colors.deepOrange.shade800,
                borderStrokeWidth: 1.5,
              );
            }).toList(),
          ),

        // 6. Volcanic Caldera Interactive Markers
        if (_showVolcanoes)
          MarkerLayer(
            markers: _volcanoes.map((v) {
              return Marker(
                point: v.location,
                width: 38,
                height: 38,
                child: GestureDetector(
                  onTap: () => _showVolcanoDetails(v),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepOrange, width: 2),
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
                  ),
                ),
              );
            }).toList(),
          ),

        // 7. Woreda Centroid Markers & Live Risk Badges
        MarkerLayer(
          markers: woredas.map((w) {
            final hasAlert = activeAlerts.any((a) => a.woredaId == w.id || (a.woreda?.name != null && a.woreda!.name.toLowerCase() == w.woredaName.toLowerCase()));
            return Marker(
              point: w.centroid,
              width: 96,
              height: 52,
              child: GestureDetector(
                onTap: () => _showWoredaInspectorSheet(w),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPolygonBorderColorForWoreda(w),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasAlert) ...[
                            const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            w.woredaName.split(' ')[0],
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      hasAlert ? Icons.fmd_bad : Icons.location_on,
                      color: _getPolygonBorderColorForWoreda(w),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // 8. Farm Plots Layer (if enabled)
        if (_activeLayer == DisasterMapLayer.farmPlots)
          MarkerLayer(
            markers: registeredFarms.map((farm) {
              final lat = (farm.latitude as num?)?.toDouble() ?? 9.0;
              final lng = (farm.longitude as num?)?.toDouble() ?? 39.0;
              return Marker(
                point: LatLng(lat, lng),
                width: 36,
                height: 36,
                child: const Icon(Icons.agriculture_rounded, color: Colors.blue, size: 28),
              );
            }).toList(),
          ),

        // 9. User GPS Position Marker
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
                width: 44,
                height: 44,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.my_location, color: Colors.blue, size: 26),
                  ),
                ),
              ),
            ],
          ),
      ],
    );

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132213) : Colors.white,
        borderRadius: widget.isFullScreen ? BorderRadius.zero : BorderRadius.circular(20),
        boxShadow: widget.isFullScreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Control Header Ribbon with Live Sync Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            color: isDark ? const Color(0xFF192C1A) : const Color(0xFFF7FAF7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.public, color: AppTheme.primaryColor, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Ethiopia Spatial GIS Command',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Live Sync status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLiveSyncing
                            ? Colors.amber.withValues(alpha: 0.15)
                            : const Color(0xFF2E7D32).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLiveSyncing ? Colors.amber.shade800 : const Color(0xFF2E7D32),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isLiveSyncing ? Colors.amber.shade800 : const Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLiveSyncing ? 'Syncing...' : 'Live Telemetry',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isLiveSyncing ? Colors.amber.shade900 : const Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, size: 18, color: AppTheme.primaryColor),
                      tooltip: 'Search Woreda',
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      onPressed: () => _showSearchWoredaPicker(woredas),
                    ),
                    IconButton(
                      icon: const Icon(Icons.layers_outlined, size: 18, color: AppTheme.primaryColor),
                      tooltip: 'Map Layers & Basemap',
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      onPressed: _showLayersBottomSheet,
                    ),
                    PopupMenuButton<RegionCameraPreset>(
                      icon: const Icon(Icons.travel_explore_rounded, size: 18, color: AppTheme.primaryColor),
                      tooltip: 'Jump to Region',
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      onSelected: (preset) {
                        _mapController.move(preset.center, preset.zoom);
                      },
                      itemBuilder: (context) => _regionPresets.map((preset) {
                        return PopupMenuItem(
                          value: preset,
                          child: Text(preset.name, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Disaster Mode Switcher Ribbon
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDisasterChip('🚨 All Hazards', DisasterMapLayer.allHazards, Colors.red),
                      const SizedBox(width: 6),
                      _buildDisasterChip('🌋 Seismology & Faults', DisasterMapLayer.seismology, Colors.deepOrange),
                      const SizedBox(width: 6),
                      _buildDisasterChip('🌱 Soil Loss & RUSLE', DisasterMapLayer.soilDegradation, const Color(0xFF854D0E)),
                      const SizedBox(width: 6),
                      _buildDisasterChip('⛰️ Landslides', DisasterMapLayer.landslides, Colors.blueGrey),
                      const SizedBox(width: 6),
                      _buildDisasterChip('☀️ Drought (SPI-3)', DisasterMapLayer.drought, Colors.amber.shade900),
                      const SizedBox(width: 6),
                      _buildDisasterChip('🌊 Floods (GloFAS)', DisasterMapLayer.floods, Colors.blue.shade800),
                      const SizedBox(width: 6),
                      _buildDisasterChip('🔥 Volcanoes', DisasterMapLayer.volcanoes, Colors.brown.shade800),
                      const SizedBox(width: 6),
                      _buildDisasterChip('📍 Farm Plots (${registeredFarms.length})', DisasterMapLayer.farmPlots, Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map Viewport with HUD Overlay
          Expanded(
            child: ClipRRect(
              borderRadius: widget.isFullScreen ? BorderRadius.zero : const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Stack(
                children: [
                  mapWidget,

                  // Floating Right GIS Toolbar
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            tooltip: 'Zoom In',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom + 1);
                            },
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            tooltip: 'Zoom Out',
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom - 1);
                            },
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: _isLocating
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.my_location, size: 20, color: AppTheme.primaryColor),
                            tooltip: 'Locate Me',
                            onPressed: _isLocating ? null : _locateUser,
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20, color: AppTheme.primaryColor),
                            tooltip: 'Refresh Live Telemetry',
                            onPressed: () => ref.invalidate(liveSpatialRiskProfilesProvider),
                          ),
                          const Divider(height: 1),
                          IconButton(
                            icon: const Icon(Icons.center_focus_strong, size: 20, color: Colors.blueGrey),
                            tooltip: 'Reset National View',
                            onPressed: () {
                              _mapController.move(const LatLng(9.145, 40.489), 6.2);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map Legend Pill Overlay
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegendDot(const Color(0xFFDC2626), 'Critical'),
                          const SizedBox(width: 8),
                          _buildLegendDot(const Color(0xFFEA580C), 'High'),
                          const SizedBox(width: 8),
                          _buildLegendDot(const Color(0xFFF59E0B), 'Moderate'),
                          const SizedBox(width: 8),
                          _buildLegendDot(const Color(0xFF10B981), 'Safe'),
                        ],
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

  Widget _buildDisasterChip(String label, DisasterMapLayer layer, Color color) {
    final isSelected = _activeLayer == layer;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.2),
      onSelected: (_) => setState(() => _activeLayer = layer),
      side: BorderSide(color: isSelected ? color : Colors.grey.shade300),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildLegendDot(Color c, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
