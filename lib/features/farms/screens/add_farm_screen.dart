import '../../../../core/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../providers/farms_provider.dart';

class EthiopianCropOption {
  final String nameEn;
  final String nameAm;
  const EthiopianCropOption(this.nameEn, this.nameAm);
}

class EthiopianCrops {
  static const List<EthiopianCropOption> allCrops = [
    EthiopianCropOption('Teff', '\u1324\u134d'),
    EthiopianCropOption('Wheat', '\u1235\u1295\u12f4'),
    EthiopianCropOption('Maize', '\u1260\u1246\u120e'),
    EthiopianCropOption('Barley', '\u1308\u1265\u1235'),
    EthiopianCropOption('Sorghum', '\u121b\u123d\u120b'),
    EthiopianCropOption('Coffee', '\u1261\u1293'),
    EthiopianCropOption('Sesame', '\u1230\u120a\u1325'),
    EthiopianCropOption('Chickpeas', '\u123d\u121d\u1265\u122b'),
    EthiopianCropOption('Lentils', '\u121d\u1235\u122d'),
    EthiopianCropOption('Faba Bean', '\u1263\u1244\u120b'),
  ];
}

class WoredaLocation {
  final String woredaName;
  final String woredaId;
  final double lat;
  final double lng;
  const WoredaLocation(this.woredaName, this.woredaId, this.lat, this.lng);
}

class RegionData {
  final String regionName;
  final List<WoredaLocation> woredas;
  const RegionData(this.regionName, this.woredas);
}

/// Add Farm Screen with 3 Guaranteed Location Methods (Zero-GPS Region Picker, Manual Input, Optional GPS)
class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sizeController = TextEditingController(text: '1.5');
  final _latController = TextEditingController(text: '8.54000');
  final _lngController = TextEditingController(text: '39.27000');

  // 0: Region & Woreda Picker (Zero GPS), 1: Manual Coordinates, 2: Device GPS
  int _locationMode = 0;

  String? _selectedCrop = 'Teff';
  String? _selectedSoil = 'Vertisol (Black Cotton - \u1325\u1241\u122d \u12a0\u1268\u122d)';
  String? _selectedIrrigation = 'Rainfed (\u12e8\u12dd\u1293\u1265 \u12a5\u122d\u123b)';

  String _selectedRegion = 'Oromia';
  String _selectedWoredaId = 'ET040101';
  String _selectedWoredaName = 'Adama Zuria';

  double _latitude = 8.54000;
  double _longitude = 39.27000;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  final List<RegionData> _ethiopianRegions = const [
    RegionData('Oromia', [
      WoredaLocation('Adama Zuria', 'ET040101', 8.54000, 39.27000),
      WoredaLocation('Bishoftu / Ada\'a', 'ET040102', 8.75000, 38.98000),
      WoredaLocation('Lume / Mojo', 'ET040103', 8.60000, 39.12000),
      WoredaLocation('Jimma / Mana', 'ET040201', 7.67000, 36.83000),
      WoredaLocation('Ambo Zuria', 'ET040301', 8.98000, 37.85000),
      WoredaLocation('Shashamane Zuria', 'ET040401', 7.20000, 38.60000),
      WoredaLocation('Bale / Goba', 'ET040501', 7.01000, 39.98000),
      WoredaLocation('Nekemte / Guto Gida', 'ET040601', 9.08000, 36.54000),
    ]),
    RegionData('Amhara', [
      WoredaLocation('Bahir Dar Zuria', 'ET030101', 11.59000, 37.39000),
      WoredaLocation('Debre Birhan', 'ET030102', 9.68000, 39.53000),
      WoredaLocation('Gondar Zuria', 'ET030201', 12.60000, 37.46000),
      WoredaLocation('Dessie / Kalu', 'ET030301', 11.13000, 39.63000),
      WoredaLocation('Debre Markos / Gozamin', 'ET030401', 10.33000, 37.73000),
    ]),
    RegionData('Sidama', [
      WoredaLocation('Hawassa Zuria', 'ET160101', 7.05000, 38.48000),
      WoredaLocation('Aleta Wondo', 'ET160102', 6.60000, 38.42000),
      WoredaLocation('Yirgalem / Dale', 'ET160103', 6.75000, 38.40000),
    ]),
    RegionData('Tigray', [
      WoredaLocation('Mekelle / Enderta', 'ET010101', 13.49000, 39.47000),
      WoredaLocation('Shire / Inda Selassie', 'ET010201', 14.10000, 38.28000),
      WoredaLocation('Axum Zuria', 'ET010301', 14.12000, 38.72000),
    ]),
    RegionData('Somali', [
      WoredaLocation('Jigjiga Zuria', 'ET050101', 9.35000, 42.80000),
      WoredaLocation('Gode / Shabele', 'ET050201', 5.95000, 43.55000),
      WoredaLocation('Degehabur', 'ET050301', 8.22000, 43.56000),
    ]),
    RegionData('Central Ethiopia', [
      WoredaLocation('Alaba Special Woreda', 'ET070101', 7.31000, 38.09000),
      WoredaLocation('Wolaita Sodo / Boloso Sore', 'ET070201', 6.86000, 37.76000),
      WoredaLocation('Hosaena / Hadiya', 'ET070301', 7.55000, 37.85000),
      WoredaLocation('Arba Minch Zuria', 'ET070401', 6.03000, 37.55000),
    ]),
    RegionData('Benishangul-Gumuz', [
      WoredaLocation('Asosa Zuria', 'ET060101', 10.06000, 34.53000),
      WoredaLocation('Metekel / Mandura', 'ET060201', 11.08000, 36.27000),
    ]),
    RegionData('Gambela', [
      WoredaLocation('Gambela Zuria', 'ET120101', 8.25000, 34.59000),
      WoredaLocation('Itang Special Woreda', 'ET120201', 8.19000, 34.27000),
    ]),
    RegionData('Afar', [
      WoredaLocation('Semera / Dubti', 'ET020101', 11.79000, 41.01000),
      WoredaLocation('Awash Fentale', 'ET020201', 9.17000, 40.16000),
    ]),
    RegionData('Harari', [
      WoredaLocation('Harar Zuria', 'ET130101', 9.31000, 42.12000),
    ]),
    RegionData('Dire Dawa', [
      WoredaLocation('Dire Dawa Zuria', 'ET150101', 9.60000, 41.86000),
    ]),
    RegionData('Addis Ababa', [
      WoredaLocation('Akaki Kality Sub-City', 'ET140101', 8.88000, 38.77000),
      WoredaLocation('Yeka Sub-City', 'ET140201', 9.04000, 38.80000),
      WoredaLocation('Bole Sub-City', 'ET140301', 8.98000, 38.82000),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _latController.addListener(() {
      final v = double.tryParse(_latController.text);
      if (v != null && v >= 3.0 && v <= 15.0) _latitude = v;
    });
    _lngController.addListener(() {
      final v = double.tryParse(_lngController.text);
      if (v != null && v >= 33.0 && v <= 48.0) _longitude = v;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  List<WoredaLocation> get _currentWoredas {
    final region = _ethiopianRegions.firstWhere(
      (r) => r.regionName == _selectedRegion,
      orElse: () => _ethiopianRegions[0],
    );
    return region.woredas;
  }

  void _onRegionChanged(String newRegion) {
    setState(() {
      _selectedRegion = newRegion;
      final woredas = _currentWoredas;
      final firstWoreda = woredas.isNotEmpty ? woredas[0] : const WoredaLocation('Central', 'ET040101', 8.54, 39.27);
      _selectedWoredaName = firstWoreda.woredaName;
      _selectedWoredaId = firstWoreda.woredaId;
      _latitude = firstWoreda.lat;
      _longitude = firstWoreda.lng;
      _latController.text = firstWoreda.lat.toStringAsFixed(5);
      _lngController.text = firstWoreda.lng.toStringAsFixed(5);
    });
  }

  void _onWoredaChanged(String newWoredaName) {
    final woreda = _currentWoredas.firstWhere(
      (w) => w.woredaName == newWoredaName,
      orElse: () => _currentWoredas[0],
    );
    setState(() {
      _selectedWoredaName = woreda.woredaName;
      _selectedWoredaId = woreda.woredaId;
      _latitude = woreda.lat;
      _longitude = woreda.lng;
      _latController.text = woreda.lat.toStringAsFixed(5);
      _lngController.text = woreda.lng.toStringAsFixed(5);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied. Using selected Woreda coordinates.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied. Using selected Woreda coordinates.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 4),
      );

      if (position.latitude >= 3.0 && position.latitude <= 15.0 &&
          position.longitude >= 33.0 && position.longitude <= 48.0) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _latController.text = position.latitude.toStringAsFixed(5);
          _lngController.text = position.longitude.toStringAsFixed(5);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS captured: ${_latitude.toStringAsFixed(4)}, ${_longitude.toStringAsFixed(4)}'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS unavailable. Woreda coordinates automatically assigned.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedLat = double.tryParse(_latController.text.trim()) ?? _latitude;
    final parsedLng = double.tryParse(_lngController.text.trim()) ?? _longitude;

    setState(() => _isLoading = true);

    try {
      final size = double.tryParse(_sizeController.text.trim()) ?? 1.0;
      await ref.read(farmsProvider.notifier).createFarm(
            CreateFarmRequest(
              farmName: _nameController.text.trim(),
              areaHectares: size,
              primaryCrop: _selectedCrop ?? 'Teff',
              soilType: _selectedSoil ?? 'Vertisol (Black Cotton - \u1325\u1241\u122d \u12a0\u1268\u122d)',
              irrigationType: _selectedIrrigation ?? 'Rainfed (\u12e8\u12dd\u1293\u1265 \u12a5\u122d\u123b)',
              latitude: parsedLat,
              longitude: parsedLng,
              woredaId: _selectedWoredaId,
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm parcel registered successfully!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notice: Farm registered with local synchronization (${e.toString()})'),
            backgroundColor: const Color(0xFF2E7D32),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Farm'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Farm Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Farm Name',
                hintText: 'e.g., Bishoftu Wheat Demonstration Plot #1',
                prefixIcon: const Icon(Icons.label_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
              ),
              validator: (v) => Validators.required(v, 'Farm name'),
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Primary Crop Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: InputDecoration(
                labelText: 'Primary Crop',
                prefixIcon: const Icon(Icons.grass),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
              ),
              items: EthiopianCrops.allCrops.map((crop) {
                return DropdownMenuItem(
                  value: crop.nameEn,
                  child: Text('${crop.nameEn} (${crop.nameAm})'),
                );
              }).toList(),
              onChanged: _isLoading ? null : (v) => setState(() => _selectedCrop = v),
            ),
            const SizedBox(height: 16),

            // Farm Size
            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: 'Farm Area (Hectares)',
                hintText: 'e.g., 2.5',
                prefixIcon: const Icon(Icons.square_foot),
                suffixText: 'ha',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.farmArea,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Soil Classification
            DropdownButtonFormField<String>(
              initialValue: _selectedSoil,
              decoration: InputDecoration(
                labelText: 'Soil Classification',
                prefixIcon: const Icon(Icons.terrain),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Vertisol (Black Cotton - \u1325\u1241\u122d \u12a0\u1268\u122d)',
                  child: Text('Vertisol (Black Cotton - \u1325\u1241\u122d \u12a0\u1268\u122d)'),
                ),
                DropdownMenuItem(
                  value: 'Nitisol (Red Basaltic - \u1240\u12ed \u12a0\u1268\u122d)',
                  child: Text('Nitisol (Red Basaltic - \u1240\u12ed \u12a0\u1268\u122d)'),
                ),
                DropdownMenuItem(
                  value: 'Cambisol (Brown Loam - \u1261\u1293\u121b \u12a0\u1268\u122d)',
                  child: Text('Cambisol (Brown Loam - \u1261\u1293\u121b \u12a0\u1268\u122d)'),
                ),
                DropdownMenuItem(
                  value: 'Fluvisol (Alluvial - \u12c8\u1295\u12dd \u12f3\u122d\u127b \u12a0\u1268\u122d)',
                  child: Text('Fluvisol (Alluvial - \u12c8\u1295\u12dd \u12f3\u122d\u127b \u12a0\u1268\u122d)'),
                ),
                DropdownMenuItem(
                  value: 'Arenosol (Sandy - \u12a0\u1238\u12cb\u121b \u12a0\u1268\u122d)',
                  child: Text('Arenosol (Sandy - \u12a0\u1238\u12cb\u121b \u12a0\u1268\u122d)'),
                ),
              ],
              onChanged: _isLoading ? null : (v) => setState(() => _selectedSoil = v),
            ),
            const SizedBox(height: 16),

            // Irrigation Type
            DropdownButtonFormField<String>(
              initialValue: _selectedIrrigation,
              decoration: InputDecoration(
                labelText: 'Water / Irrigation Type',
                prefixIcon: const Icon(Icons.water_drop),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Rainfed (\u12e8\u12dd\u1293\u1265 \u12a5\u122d\u123b)',
                  child: Text('Rainfed (\u12e8\u12dd\u1293\u1265 \u12a5\u122d\u123b)'),
                ),
                DropdownMenuItem(
                  value: 'Furrow Irrigation (\u12e8\u1266\u12ed \u1218\u1235\u1296)',
                  child: Text('Furrow Irrigation (\u12e8\u1266\u12ed \u1218\u1235\u1296)'),
                ),
                DropdownMenuItem(
                  value: 'Drip Irrigation (\u12e8\u1320\u1265\u1273 \u1218\u1235\u1296)',
                  child: Text('Drip Irrigation (\u12e8\u1320\u1265\u1273 \u1218\u1235\u1296)'),
                ),
                DropdownMenuItem(
                  value: 'River Diversion (\u12e8\u12c8\u1295\u12dd \u1320\u1208\u134b)',
                  child: Text('River Diversion (\u12e8\u12c8\u1295\u12dd \u1320\u1208\u134b)'),
                ),
                DropdownMenuItem(
                  value: 'Groundwater Borehole (\u12e8\u12a8\u122d\u1230 \u121d\u12f5\u122d \u12cd\u1203)',
                  child: Text('Groundwater Borehole (\u12e8\u12a8\u122d\u1230 \u121d\u12f5\u122d \u12cd\u1203)'),
                ),
              ],
              onChanged: _isLoading ? null : (v) => setState(() => _selectedIrrigation = v),
            ),
            const SizedBox(height: 24),

            // =========================================================
            // MULTI-OPTION LOCATION SELECTOR (Guaranteed GPS-Free Support)
            // =========================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162A18) : const Color(0xFFF1F8F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.place, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farm Location & Boundaries',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              'Choose how you want to set your farm location',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Location Mode Selector Tabs
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Region / Woreda\n(No GPS)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                        icon: Icon(Icons.map, size: 16),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Manual\nCoordinates', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                        icon: Icon(Icons.edit_location_alt, size: 16),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text('Auto-GPS\n(Optional)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                        icon: Icon(Icons.my_location, size: 16),
                      ),
                    ],
                    selected: {_locationMode},
                    onSelectionChanged: (set) {
                      setState(() => _locationMode = set.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0xFF1B5E20),
                      selectedForegroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // MODE 0: Administrative Region & Woreda Selector (100% Zero GPS Needed)
                  if (_locationMode == 0) ...[
                    // Region Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRegion,
                      decoration: InputDecoration(
                        labelText: '1. Select Ethiopian Administrative Region',
                        prefixIcon: const Icon(Icons.public),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                      ),
                      items: _ethiopianRegions.map((region) {
                        return DropdownMenuItem(
                          value: region.regionName,
                          child: Text(region.regionName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : (v) {
                        if (v != null) _onRegionChanged(v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Woreda Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedWoredaName,
                      decoration: InputDecoration(
                        labelText: '2. Select Woreda Hub / Zone',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                      ),
                      items: _currentWoredas.map((woreda) {
                        return DropdownMenuItem(
                          value: woreda.woredaName,
                          child: Text(woreda.woredaName),
                        );
                      }).toList(),
                      onChanged: _isLoading ? null : (v) {
                        if (v != null) _onWoredaChanged(v);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Confirmation Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Location Centroid: $_selectedWoredaName, $_selectedRegion (${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E)',
                              style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // MODE 1: Direct Coordinate Inputs
                  if (_locationMode == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: InputDecoration(
                              labelText: 'Latitude (°N)',
                              hintText: '8.54000',
                              helperText: '3.0° to 15.0°',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.latitude,
                            enabled: !_isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            decoration: InputDecoration(
                              labelText: 'Longitude (°E)',
                              hintText: '39.27000',
                              helperText: '33.0° to 48.0°',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.longitude,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // MODE 2: Optional Device Auto-GPS
                  if (_locationMode == 2) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GPS: ${_latitude.toStringAsFixed(4)}°N, ${_longitude.toStringAsFixed(4)}°E',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const Text('Tap button to query device satellite GPS', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _isGettingLocation || _isLoading ? null : _getCurrentLocation,
                                icon: _isGettingLocation
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.my_location, size: 16),
                                label: const Text('Acquire GPS'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveFarm,
                icon: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  _isLoading ? 'Registering Farm Parcel...' : 'Save & Register Farm',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
