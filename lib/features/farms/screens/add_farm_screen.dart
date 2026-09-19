import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/farm_model.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/gis_geometry_utils.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../offline_sync/domain/sync_service.dart';
import '../../boundaries/providers/boundary_provider.dart';
import '../../boundaries/models/boundary_models.dart';
import '../providers/farms_provider.dart';

class EthiopianCropOption {
  final String nameEn;
  final String nameAm;
  const EthiopianCropOption(this.nameEn, this.nameAm);
}

class EthiopianCrops {
  static const List<EthiopianCropOption> allCrops = [
    EthiopianCropOption('Teff', 'ጤፍ'),
    EthiopianCropOption('Wheat', 'ስንዴ'),
    EthiopianCropOption('Maize', 'በቆሎ'),
    EthiopianCropOption('Barley', 'ገብስ'),
    EthiopianCropOption('Sorghum', 'ማሽላ'),
    EthiopianCropOption('Coffee', 'ቡና'),
    EthiopianCropOption('Sesame', 'ሰሊጥ'),
    EthiopianCropOption('Chickpeas', 'ሽንብራ'),
    EthiopianCropOption('Lentils', 'ምስር'),
    EthiopianCropOption('Faba Bean', 'ባቄላ'),
    EthiopianCropOption('Enset', 'እንሰት'),
    EthiopianCropOption('Avocado', 'አቮካዶ'),
    EthiopianCropOption('Potato', 'ድንች'),
    EthiopianCropOption('Red Pepper / Berbere', 'ቃሪያ / በርበሬ'),
    EthiopianCropOption('Garlic', 'ነጭ ሽንኩርት'),
    EthiopianCropOption('Other (Custom Crop)', 'የተለየ ሰብል'),
  ];
}

/// Farmer-Exclusive Farm Plot Registration & Editing Screen with Mandatory GIS Polygon Mapping
class AddFarmScreen extends ConsumerStatefulWidget {
  final FarmModel? farmToEdit;
  final String? farmId;

  const AddFarmScreen({
    super.key,
    this.farmToEdit,
    this.farmId,
  });

  bool get isEditing => farmToEdit != null || (farmId != null && farmId!.isNotEmpty);

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController(text: '1.0');
  final _customCropController = TextEditingController();

  final MapController _mapController = MapController();

  // Polygon boundary coordinates
  final List<LatLng> _polygonVertices = [];

  String? _selectedCrop = 'Teff';
  String? _selectedSoil = 'Vertisol (Black Cotton - ጥቁር አፈር)';
  String? _selectedIrrigation = 'Rainfed (የዝናብ እርሻ)';
  String _selectedSlope = 'Flat / Plain (0-2% Slope)';

  DateTime _sowingDate = DateTime.now().subtract(const Duration(days: 14));
  DateTime _expectedHarvestDate = DateTime.now().add(const Duration(days: 90));

  String _selectedRegion = 'Oromia';
  String _selectedWoredaId = 'ET040101';
  String _selectedWoredaName = 'Adama Zuria';

  double _latitude = 8.54000;
  double _longitude = 39.27000;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  Timer? _draftSaveTimer;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _initFromExistingFarm();
    } else {
      _loadDraft();
    }

    _nameController.addListener(_onFormChanged);
    _sizeController.addListener(_onFormChanged);
  }

  void _initFromExistingFarm() {
    final farm = widget.farmToEdit;
    if (farm != null) {
      _populateFromFarm(farm);
    } else if (widget.farmId != null) {
      Future.microtask(() async {
        final existing = ref.read(farmsProvider.notifier).getFarmById(widget.farmId!);
        if (existing != null) {
          if (mounted) setState(() => _populateFromFarm(existing));
        } else {
          try {
            final fetched = await ref.read(farmProvider(widget.farmId!).future);
            if (mounted) setState(() => _populateFromFarm(fetched));
          } catch (_) {}
        }
      });
    }
  }

  void _populateFromFarm(FarmModel farm) {
    _nameController.text = farm.farmName;
    _latitude = farm.latitude;
    _longitude = farm.longitude;

    // Crop matching
    final isKnownCrop = EthiopianCrops.allCrops.any((c) => c.nameEn == farm.primaryCrop);
    if (isKnownCrop) {
      _selectedCrop = farm.primaryCrop;
    } else {
      _selectedCrop = 'Other (Custom Crop)';
      _customCropController.text = farm.primaryCrop;
    }

    if (farm.soilType != null && farm.soilType!.isNotEmpty) {
      _selectedSoil = farm.soilType;
    }
    if (farm.irrigationType != null && farm.irrigationType!.isNotEmpty) {
      _selectedIrrigation = farm.irrigationType;
    }
    if (farm.woredaId != null && farm.woredaId!.isNotEmpty) {
      _selectedWoredaId = farm.woredaId!;
    }
    if (farm.woreda?.name != null) {
      _selectedWoredaName = farm.woreda!.name;
    }

    // Parse Polygon vertices from geoJsonBoundary
    _polygonVertices.clear();
    final geo = farm.geoJsonBoundary;
    if (geo != null && geo['coordinates'] is List) {
      final coordsList = geo['coordinates'] as List;
      if (coordsList.isNotEmpty) {
        final ring = coordsList[0] is List ? coordsList[0] as List : coordsList;
        for (final pt in ring) {
          if (pt is List && pt.length >= 2) {
            final lng = (pt[0] as num).toDouble();
            final lat = (pt[1] as num).toDouble();
            // Ignore closing coordinate if identical to first
            if (_polygonVertices.isNotEmpty &&
                (_polygonVertices.first.latitude - lat).abs() < 0.000001 &&
                (_polygonVertices.first.longitude - lng).abs() < 0.000001) {
              continue;
            }
            _polygonVertices.add(LatLng(lat, lng));
          }
        }
      }
    }

    if (_polygonVertices.isNotEmpty) {
      final area = _calculatePolygonAreaHectares(_polygonVertices);
      _sizeController.text = area > 0 ? area.toStringAsFixed(2) : farm.areaHectares.toStringAsFixed(2);
      final center = _calculateCentroid(_polygonVertices);
      _latitude = center.latitude;
      _longitude = center.longitude;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(center, 15.0);
        } catch (_) {}
      });
    } else {
      _sizeController.text = farm.areaHectares.toStringAsFixed(2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(LatLng(farm.latitude, farm.longitude), 14.0);
        } catch (_) {}
      });
    }
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  /// Calculates geodesic polygon surface area in Hectares using spherical excess
  double _calculatePolygonAreaHectares(List<LatLng> points) {
    final km2 = GisGeometryUtils.calculateSphericalPolygonAreaKm2(points);
    return GisGeometryUtils.km2ToHectares(km2);
  }

  /// Calculates geometric centroid of the polygon vertices
  LatLng _calculateCentroid(List<LatLng> points) =>
      GisGeometryUtils.calculateCentroid(points,
          fallback: LatLng(_latitude, _longitude));

  /// Constructs standard GeoJSON Polygon format
  Map<String, dynamic> _getPolygonGeoJson() {
    if (_polygonVertices.length < 3) return {};
    final List<List<double>> ring = _polygonVertices
        .map((p) => [double.parse(p.longitude.toStringAsFixed(6)), double.parse(p.latitude.toStringAsFixed(6))])
        .toList();

    // Ensure linear ring is closed (first point == last point)
    if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
      ring.add([ring.first[0], ring.first[1]]);
    }

    return {
      'type': 'Polygon',
      'coordinates': [ring],
    };
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'farmName': _nameController.text.trim(),
        'crop': _selectedCrop,
        'soil': _selectedSoil,
        'irrigation': _selectedIrrigation,
        'slope': _selectedSlope,
        'region': _selectedRegion,
        'woredaId': _selectedWoredaId,
        'woredaName': _selectedWoredaName,
        'polygonVertices': _polygonVertices.map((p) => [p.latitude, p.longitude]).toList(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('agrietech_farmer_farm_polygon_draft', jsonEncode(draft));
    } catch (_) {}
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('agrietech_farmer_farm_polygon_draft');
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> draft = jsonDecode(raw);
        if (mounted) {
          setState(() {
            if (draft['farmName'] != null && (draft['farmName'] as String).isNotEmpty) {
              _nameController.text = draft['farmName'];
            }
            if (draft['crop'] != null) _selectedCrop = draft['crop'];
            if (draft['soil'] != null) _selectedSoil = draft['soil'];
            if (draft['irrigation'] != null) _selectedIrrigation = draft['irrigation'];
            if (draft['slope'] != null) _selectedSlope = draft['slope'];
            if (draft['region'] != null) _selectedRegion = draft['region'];
            if (draft['woredaId'] != null) _selectedWoredaId = draft['woredaId'];
            if (draft['woredaName'] != null) _selectedWoredaName = draft['woredaName'];
            if (draft['polygonVertices'] != null && draft['polygonVertices'] is List) {
              _polygonVertices.clear();
              for (final pt in draft['polygonVertices']) {
                if (pt is List && pt.length >= 2) {
                  _polygonVertices.add(LatLng((pt[0] as num).toDouble(), (pt[1] as num).toDouble()));
                }
              }
              if (_polygonVertices.length >= 3) {
                final area = _calculatePolygonAreaHectares(_polygonVertices);
                _sizeController.text = area.toStringAsFixed(2);
                final center = _calculateCentroid(_polygonVertices);
                _latitude = center.latitude;
                _longitude = center.longitude;
              }
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agrietech_farmer_farm_polygon_draft');
    } catch (_) {}
  }

  @override
  void dispose() {
    _draftSaveTimer?.cancel();
    _nameController.removeListener(_onFormChanged);
    _sizeController.removeListener(_onFormChanged);

    _nameController.dispose();
    _sizeController.dispose();
    _customCropController.dispose();
    super.dispose();
  }

  void _onWoredaSelected(WoredaModel woreda) {
    setState(() {
      _selectedWoredaName = woreda.name;
      _selectedWoredaId = woreda.id;
      _selectedRegion = woreda.zone?.region?.name ?? 'National Scope';
      _latitude = woreda.centerLat;
      _longitude = woreda.centerLng;
    });
    _mapController.move(LatLng(woreda.centerLat, woreda.centerLng), 13.0);
    _onFormChanged();
  }

  void _onMapTapped(TapPosition tapPosition, LatLng point) {
    if (!Validators.isWithinEthiopia(point.latitude, point.longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Selected point (${point.latitude.toStringAsFixed(3)}°N, ${point.longitude.toStringAsFixed(3)}°E) is outside Ethiopian borders.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
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

      if (_polygonVertices.length >= 3) {
        final computedArea = _calculatePolygonAreaHectares(_polygonVertices);
        _sizeController.text = computedArea > 0 ? computedArea.toStringAsFixed(2) : '1.0';
      }

      final woredas = ref.read(allWoredasProvider).asData?.value ?? [];
      WoredaModel? closestWoreda;
      double minDistance = double.infinity;

      for (final woreda in woredas) {
        final dLat = woreda.centerLat - center.latitude;
        final dLng = woreda.centerLng - center.longitude;
        final dist = (dLat * dLat) + (dLng * dLng);
        if (dist < minDistance) {
          minDistance = dist;
          closestWoreda = woreda;
        }
      }

      if (closestWoreda != null) {
        _selectedWoredaName = closestWoreda.name;
        _selectedWoredaId = closestWoreda.id;
        _selectedRegion = closestWoreda.zone?.region?.name ?? 'National Scope';
      }
    });
    _onFormChanged();
  }

  void _undoLastVertex() {
    if (_polygonVertices.isNotEmpty) {
      setState(() {
        _polygonVertices.removeLast();
        if (_polygonVertices.length >= 3) {
          final computedArea = _calculatePolygonAreaHectares(_polygonVertices);
          _sizeController.text = computedArea.toStringAsFixed(2);
        } else {
          _sizeController.text = '1.0';
        }
        if (_polygonVertices.isNotEmpty) {
          final center = _calculateCentroid(_polygonVertices);
          _latitude = center.latitude;
          _longitude = center.longitude;
        }
      });
      _onFormChanged();
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonVertices.clear();
      _sizeController.text = '1.0';
    });
    _onFormChanged();
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_polygonVertices.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('GIS Polygon Required: Please tap at least 3 corner boundary points on the map to define your parcel perimeter.'),
              ),
            ],
          ),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final polygonGeojson = _getPolygonGeoJson();
    final center = _calculateCentroid(_polygonVertices);
    final calculatedArea = _calculatePolygonAreaHectares(_polygonVertices);
    final effectiveArea = calculatedArea > 0 ? calculatedArea : (double.tryParse(_sizeController.text.trim()) ?? 1.0);

    final effectiveCrop = (_selectedCrop == 'Other (Custom Crop)')
        ? (_customCropController.text.trim().isNotEmpty ? _customCropController.text.trim() : 'Custom Crop')
        : (_selectedCrop ?? 'Teff');

    setState(() => _isLoading = true);

    final farmPayload = {
      'farmName': _nameController.text.trim(),
      'areaHectares': effectiveArea,
      'primaryCrop': effectiveCrop,
      'soilType': _selectedSoil ?? 'Vertisol (Black Cotton - ጥቁር አፈር)',
      'irrigationType': _selectedIrrigation ?? 'Rainfed (የዝናብ እርሻ)',
      'latitude': center.latitude,
      'longitude': center.longitude,
      'woredaId': _selectedWoredaId,
      'polygonGeojson': polygonGeojson,
    };

    try {
      if (widget.isEditing) {
        final targetId = widget.farmToEdit?.id ?? widget.farmId!;
        await ref.read(farmsProvider.notifier).updateFarm(
              targetId,
              UpdateFarmRequest(
                farmName: _nameController.text.trim(),
                areaHectares: effectiveArea,
                primaryCrop: effectiveCrop,
                soilType: _selectedSoil ?? 'Vertisol (Black Cotton - ጥቁር አፈር)',
                irrigationType: _selectedIrrigation ?? 'Rainfed (የዝናብ እርሻ)',
                latitude: center.latitude,
                longitude: center.longitude,
                woredaId: _selectedWoredaId,
                geoJsonBoundary: polygonGeojson,
              ),
            );

        ref.invalidate(farmProvider(targetId));
        _hasUnsavedChanges = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Farm plot updated successfully with GIS polygon! (${effectiveArea.toStringAsFixed(2)} ha)'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } else {
        await ref.read(farmsProvider.notifier).createFarm(
              CreateFarmRequest(
                farmName: _nameController.text.trim(),
                areaHectares: effectiveArea,
                primaryCrop: effectiveCrop,
                soilType: _selectedSoil ?? 'Vertisol (Black Cotton - ጥቁር አፈር)',
                irrigationType: _selectedIrrigation ?? 'Rainfed (የዝናብ እርሻ)',
                latitude: center.latitude,
                longitude: center.longitude,
                woredaId: _selectedWoredaId,
                geoJsonBoundary: polygonGeojson,
              ),
            );

        await _clearDraft();
        _hasUnsavedChanges = false;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Farm plot registered with GIS polygon! (${effectiveArea.toStringAsFixed(2)} ha)'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      final method = widget.isEditing ? 'PUT' : 'POST';
      final path = widget.isEditing
          ? ApiConstants.farmById(widget.farmToEdit?.id ?? widget.farmId!)
          : ApiConstants.farms;
      await SyncService.enqueue(path, method, farmPayload);
      if (!widget.isEditing) await _clearDraft();
      _hasUnsavedChanges = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Offline: Farm polygon saved locally. Will sync automatically when connected.'),
                ),
              ],
            ),
            backgroundColor: Color(0xFFE65100),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Unsaved Changes?'),
        content: const Text('Your draft has been auto-saved locally and will be available when you return.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard & Exit'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Strict Role Enforcement: Add Farm is strictly for Farmers
    if (!RoleUtils.canAddFarm(authState.user?.role)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register Farm Plot')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gpp_bad_rounded, size: 64, color: Color(0xFFDC2626)),
                const SizedBox(height: 16),
                const Text(
                  'Farmer Role Required',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Adding and registering smallholder farm plots is restricted exclusively to Farmers.\n\nYour current account role is ${RoleUtils.getRoleDisplayName(authState.user?.role)}.',
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
    final woredasAsync = ref.watch(allWoredasProvider);
    final calculatedArea = _calculatePolygonAreaHectares(_polygonVertices);
    final timadValue = (calculatedArea * 4.0).toStringAsFixed(1);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _onWillPop();
          if (shouldExit && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Farm Plot (GIS Polygon)' : 'Register Farm Plot (GIS Polygon)'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. General Info Card
              _buildFormCard(
                title: 'General Farm Information',
                icon: Icons.agriculture,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Farm Plot Name'),
                            Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        hintText: 'e.g., Haro Teff Parcel Alpha',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Farm name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Automatic Acreage Display from Polygon
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.straighten, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Polygon Parcel Area (Computed from GIS)',
                                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _polygonVertices.length >= 3
                                      ? '${calculatedArea.toStringAsFixed(2)} Hectares (~$timadValue Timad)'
                                      : '0.00 ha (Draw polygon below)',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Agronomy Profile Card
              _buildFormCard(
                title: 'Agronomic Characteristics',
                icon: Icons.eco,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedCrop,
                      decoration: InputDecoration(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Primary Crop'),
                            Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        prefixIcon: const Icon(Icons.grass),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                      ),
                      items: EthiopianCrops.allCrops.map((crop) {
                        return DropdownMenuItem(
                          value: crop.nameEn,
                          child: Text(
                            '${crop.nameEn} (${crop.nameAm})',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : (v) => setState(() => _selectedCrop = v),
                    ),

                    if (_selectedCrop == 'Other (Custom Crop)') ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _customCropController,
                        decoration: InputDecoration(
                          labelText: 'Specify Custom Crop Name',
                          prefixIcon: const Icon(Icons.edit),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                        ),
                        validator: (v) => (_selectedCrop == 'Other (Custom Crop)' && (v == null || v.trim().isEmpty))
                            ? 'Please specify the crop name'
                            : null,
                      ),
                    ],

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSoil,
                      decoration: InputDecoration(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Dominant Soil Classification'),
                            Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        prefixIcon: const Icon(Icons.terrain),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Vertisol (Black Cotton - ጥቁር አፈር)',
                          child: Text('Vertisol (Black Cotton - ጥቁር አፈር)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Nitisol (Red Clay / Volcanic - ቀይ አፈር)',
                          child: Text('Nitisol (Red Clay / Volcanic - ቀይ አፈር)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Fluvisol (River Basin Alluvial - ደለል አፈር)',
                          child: Text('Fluvisol (River Basin Alluvial - ደለል አፈር)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Cambisol (Brown Loam - ቡናማ አፈር)',
                          child: Text('Cambisol (Brown Loam - ቡናማ አፈር)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Arenosol (Sandy Arid - አሸዋማ አፈር)',
                          child: Text('Arenosol (Sandy Arid - አሸዋማ አፈር)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                      ],
                      onChanged: _isLoading ? null : (v) => setState(() => _selectedSoil = v),
                    ),

                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedIrrigation,
                      decoration: InputDecoration(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Water Source / Irrigation Mode'),
                            Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        prefixIcon: const Icon(Icons.water_drop),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Rainfed (የዝናብ እርሻ)',
                          child: Text('Rainfed (የዝናብ እርሻ)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Furrow Irrigation (የቦይ መስኖ)',
                          child: Text('Furrow Irrigation (የቦይ መስኖ)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Drip Irrigation (የጠብታ መስኖ)',
                          child: Text('Drip Irrigation (የጠብታ መስኖ)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        DropdownMenuItem(
                          value: 'Groundwater / Solar Pump (የከርሰ ምድር ውሀ)',
                          child: Text('Groundwater / Solar Pump (የከርሰ ምድር ውሀ)', overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                      ],
                      onChanged: _isLoading ? null : (v) => setState(() => _selectedIrrigation = v),
                    ),

                    const SizedBox(height: 14),

                    // Sowing and Harvest Dates
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _sowingDate,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) setState(() => _sowingDate = picked);
                                  },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text('Sown: ${_sowingDate.day}/${_sowingDate.month}/${_sowingDate.year}', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _expectedHarvestDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) setState(() => _expectedHarvestDate = picked);
                                  },
                            icon: const Icon(Icons.event_available, size: 16),
                            label: Text('Harvest: ${_expectedHarvestDate.day}/${_expectedHarvestDate.month}/${_expectedHarvestDate.year}', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. GIS Plot Polygon Boundary Drawing Card (MANDATORY POLYGON ONLY)
              _buildFormCard(
                title: 'GIS Plot Boundary (Polygon Only - No Pins Allowed)',
                icon: Icons.polyline_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 18, color: Color(0xFF0284C7)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Strict GIS Cadastral Policy: Standalone GPS pin drops and coordinate typing are disallowed. Every farm plot must be mapped with an enclosed polygon boundary (minimum 3 perimeter points).',
                              style: TextStyle(fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge & Controls Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _polygonVertices.length >= 3
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                            : Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _polygonVertices.length >= 3
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                              : Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _polygonVertices.length >= 3 ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                            color: _polygonVertices.length >= 3 ? const Color(0xFF1B5E20) : Colors.amber.shade900,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _polygonVertices.length >= 3
                                  ? 'Polygon Closed: ${_polygonVertices.length} corners • ${calculatedArea.toStringAsFixed(2)} ha'
                                  : 'Tap map to mark parcel corners: ${_polygonVertices.length}/3 min points',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: _polygonVertices.length >= 3 ? const Color(0xFF1B5E20) : Colors.amber.shade900,
                              ),
                            ),
                          ),
                          if (_polygonVertices.isNotEmpty) ...[
                            IconButton(
                              icon: const Icon(Icons.undo, size: 18),
                              tooltip: 'Undo last corner',
                              visualDensity: VisualDensity.compact,
                              onPressed: _undoLastVertex,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.red),
                              tooltip: 'Clear polygon',
                              visualDensity: VisualDensity.compact,
                              onPressed: _clearPolygon,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Interactive GIS Polygon Mapping Canvas
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _polygonVertices.length >= 3
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2E7D32).withValues(alpha: 0.3),
                          width: _polygonVertices.length >= 3 ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: LatLng(
                              (_latitude >= 3.2 && _latitude <= 15.2) ? _latitude : 8.54,
                              (_longitude >= 32.8 && _longitude <= 48.2) ? _longitude : 39.27,
                            ),
                            initialZoom: 13.0,
                            minZoom: 6.0,
                            maxZoom: 19.0,
                            onTap: _onMapTapped,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              fallbackUrl: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
                              userAgentPackageName: 'com.ethiofarm.app',
                              maxZoom: 19,
                            ),
                            // Shaded Polygon Boundary Layer
                            if (_polygonVertices.length >= 3)
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _polygonVertices,
                                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                    borderColor: const Color(0xFF1B5E20),
                                    borderStrokeWidth: 3.0,
                                    isFilled: true,
                                  ),
                                ],
                              ),
                            // Polyline layer connecting vertices while plotting
                            if (_polygonVertices.length >= 2)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      ..._polygonVertices,
                                      if (_polygonVertices.length >= 3) _polygonVertices.first,
                                    ],
                                    color: const Color(0xFF1B5E20),
                                    strokeWidth: 2.5,
                                  ),
                                ],
                              ),
                            // Vertex Marker Points
                            MarkerLayer(
                              markers: [
                                ..._polygonVertices.asMap().entries.map((entry) {
                                  return Marker(
                                    point: entry.value,
                                    width: 26,
                                    height: 26,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1B5E20),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black38, blurRadius: 4),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                    child: const Icon(Icons.star, color: Colors.amber, size: 28),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Instructions: Tap sequentially around the corners of your plot boundary. You must mark at least 3 points. The parcel area (hectares) and centroid are computed automatically.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    const SizedBox(height: 14),

                    // Administrative Woreda Selector (Centers map on district)
                    woredasAsync.when(
                      data: (woredas) {
                        final validWoredaId = woredas.any((w) => w.id == _selectedWoredaId)
                            ? _selectedWoredaId
                            : (woredas.isNotEmpty ? woredas.first.id : null);
                        return DropdownButtonFormField<String>(
                          key: ValueKey('woreda_select_$validWoredaId'),
                          isExpanded: true,
                          initialValue: validWoredaId,
                          decoration: InputDecoration(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Woreda Jurisdiction'),
                                Text(' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                              ],
                            ),
                            prefixIcon: const Icon(Icons.location_city),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                          ),
                          items: woredas.map((w) {
                            final regionName = w.zone?.region?.name ?? '';
                            final subtitle = regionName.isNotEmpty ? ' ($regionName)' : '';
                            return DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                '${w.name}$subtitle',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: _isLoading
                              ? null
                              : (v) {
                                  if (v != null) {
                                    final matched = woredas.firstWhere((w) => w.id == v);
                                    _onWoredaSelected(matched);
                                  }
                                },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      ),
                      error: (_, __) => Text('Woreda: $_selectedWoredaName'),
                    ),
                    const SizedBox(height: 10),

                    // Centroid Confirmation Badge
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Polygon Centroid: ${_latitude.toStringAsFixed(5)}°N, ${_longitude.toStringAsFixed(5)}°E ($_selectedWoredaName, $_selectedRegion)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1B5E20)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: _isLoading ? null : _saveFarm,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isLoading
                        ? (widget.isEditing ? 'Updating Farm Polygon...' : 'Registering Farm Polygon...')
                        : (widget.isEditing ? 'Update Farm Plot' : 'Register Farm Plot'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162518) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF263E26) : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}
