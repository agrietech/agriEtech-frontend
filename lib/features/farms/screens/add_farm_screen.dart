import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/api_constants.dart';
import '../../offline_sync/domain/sync_service.dart';
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

/// World-Class Enterprise Farm & GIS Plot Registration Screen
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
  final _customCropController = TextEditingController();
  final _kebeleController = TextEditingController();
  final _ftcController = TextEditingController();

  final MapController _miniMapController = MapController();

  // 0: Tap on GIS Map, 1: Region / Woreda Picker, 2: Direct Coordinates, 3: Auto GPS
  int _locationMode = 0;

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
      WoredaLocation('Hosaena / Lemo', 'ET070301', 7.55000, 37.85000),
      WoredaLocation('Butajira / Meskan', 'ET070401', 8.12000, 38.37000),
    ]),
    RegionData('South Ethiopia', [
      WoredaLocation('Arba Minch Zuria', 'ET080101', 6.03000, 37.55000),
      WoredaLocation('Jinka / Bako Gazer', 'ET080201', 5.78000, 36.56000),
      WoredaLocation('Dilla Zuria', 'ET080301', 6.41000, 38.31000),
    ]),
    RegionData('Benishangul-Gumuz', [
      WoredaLocation('Ascosa / Assosa', 'ET060101', 10.06000, 34.53000),
      WoredaLocation('Metekel / Mandura', 'ET060201', 10.95000, 36.33000),
    ]),
    RegionData('Gambella', [
      WoredaLocation('Gambella Zuria', 'ET120101', 8.25000, 34.59000),
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

  bool _hasUnsavedChanges = false;
  Timer? _draftSaveTimer;

  @override
  void initState() {
    super.initState();
    _loadDraft();

    _nameController.addListener(_onFormChanged);
    _sizeController.addListener(_onFormChanged);
    _kebeleController.addListener(_onFormChanged);
    _ftcController.addListener(_onFormChanged);

    _latController.addListener(() {
      final v = double.tryParse(_latController.text);
      if (v != null && Validators.isWithinEthiopia(v, _longitude)) {
        _latitude = v;
      }
      _onFormChanged();
    });
    _lngController.addListener(() {
      final v = double.tryParse(_lngController.text);
      if (v != null && Validators.isWithinEthiopia(_latitude, v)) {
        _longitude = v;
      }
      _onFormChanged();
    });
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draft = {
        'farmName': _nameController.text.trim(),
        'size': _sizeController.text.trim(),
        'crop': _selectedCrop,
        'soil': _selectedSoil,
        'irrigation': _selectedIrrigation,
        'latitude': _latitude,
        'longitude': _longitude,
        'region': _selectedRegion,
        'woredaId': _selectedWoredaId,
        'woredaName': _selectedWoredaName,
        'kebele': _kebeleController.text.trim(),
        'ftc': _ftcController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString('agrietech_farm_registration_draft', jsonEncode(draft));
    } catch (_) {}
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('agrietech_farm_registration_draft');
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> draft = jsonDecode(raw);
        if (mounted) {
          setState(() {
            if (draft['farmName'] != null && (draft['farmName'] as String).isNotEmpty) {
              _nameController.text = draft['farmName'];
            }
            if (draft['size'] != null && (draft['size'] as String).isNotEmpty) {
              _sizeController.text = draft['size'];
            }
            if (draft['crop'] != null) _selectedCrop = draft['crop'];
            if (draft['soil'] != null) _selectedSoil = draft['soil'];
            if (draft['irrigation'] != null) _selectedIrrigation = draft['irrigation'];
            if (draft['latitude'] != null) {
              _latitude = (draft['latitude'] as num).toDouble();
              _latController.text = _latitude.toStringAsFixed(5);
            }
            if (draft['longitude'] != null) {
              _longitude = (draft['longitude'] as num).toDouble();
              _lngController.text = _longitude.toStringAsFixed(5);
            }
            if (draft['region'] != null) _selectedRegion = draft['region'];
            if (draft['woredaId'] != null) _selectedWoredaId = draft['woredaId'];
            if (draft['woredaName'] != null) _selectedWoredaName = draft['woredaName'];
            if (draft['kebele'] != null) _kebeleController.text = draft['kebele'];
            if (draft['ftc'] != null) _ftcController.text = draft['ftc'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agrietech_farm_registration_draft');
    } catch (_) {}
  }

  @override
  void dispose() {
    _draftSaveTimer?.cancel();
    _nameController.removeListener(_onFormChanged);
    _sizeController.removeListener(_onFormChanged);
    _kebeleController.removeListener(_onFormChanged);
    _ftcController.removeListener(_onFormChanged);

    _nameController.dispose();
    _sizeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _customCropController.dispose();
    _kebeleController.dispose();
    _ftcController.dispose();
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
    _onFormChanged();
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
    _onFormChanged();
  }

  void _onMapPointTapped(TapPosition tapPosition, LatLng point) {
    // Validate that clicked coordinates reside strictly within Ethiopian territory
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
      _latitude = point.latitude;
      _longitude = point.longitude;
      _latController.text = point.latitude.toStringAsFixed(5);
      _lngController.text = point.longitude.toStringAsFixed(5);

      // Find closest Ethiopian Woreda
      WoredaLocation? closestWoreda;
      String? closestRegion;
      double minDistance = double.infinity;

      for (final region in _ethiopianRegions) {
        for (final woreda in region.woredas) {
          final dLat = woreda.lat - point.latitude;
          final dLng = woreda.lng - point.longitude;
          final dist = (dLat * dLat) + (dLng * dLng);
          if (dist < minDistance) {
            minDistance = dist;
            closestWoreda = woreda;
            closestRegion = region.regionName;
          }
        }
      }

      if (closestWoreda != null && closestRegion != null) {
        _selectedRegion = closestRegion;
        _selectedWoredaName = closestWoreda.woredaName;
        _selectedWoredaId = closestWoreda.woredaId;
      }
    });
    _onFormChanged();
  }


  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS service disabled on device. Using administrative centroid.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final lat = position.latitude;
      final lng = position.longitude;
      setState(() {
        _latitude = lat;
        _longitude = lng;
        _latController.text = lat.toStringAsFixed(5);
        _lngController.text = lng.toStringAsFixed(5);
      });
      _miniMapController.move(LatLng(lat, lng), 14);
    } catch (_) {
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
    final size = double.tryParse(_sizeController.text.trim()) ?? 1.0;

    final effectiveCrop = (_selectedCrop == 'Other (Custom Crop)')
        ? (_customCropController.text.trim().isNotEmpty ? _customCropController.text.trim() : 'Custom Crop')
        : (_selectedCrop ?? 'Teff');

    setState(() => _isLoading = true);

    final farmPayload = {
      'farmName': _nameController.text.trim(),
      'areaHectares': size,
      'primaryCrop': effectiveCrop,
      'soilType': _selectedSoil ?? 'Vertisol (Black Cotton - ጥቁር አፈር)',
      'irrigationType': _selectedIrrigation ?? 'Rainfed (የዝናብ እርሻ)',
      'latitude': parsedLat,
      'longitude': parsedLng,
      'woredaId': _selectedWoredaId,
    };

    try {
      await ref.read(farmsProvider.notifier).createFarm(
            CreateFarmRequest(
              farmName: _nameController.text.trim(),
              areaHectares: size,
              primaryCrop: effectiveCrop,
              soilType: _selectedSoil ?? 'Vertisol (Black Cotton - ጥቁር አፈር)',
              irrigationType: _selectedIrrigation ?? 'Rainfed (የዝናብ እርሻ)',
              latitude: parsedLat,
              longitude: parsedLng,
              woredaId: _selectedWoredaId,
            ),
          );

      await _clearDraft();
      _hasUnsavedChanges = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm plot registered and synced with GEE telemetry!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      // Enqueue to offline sync queue for automatic background synchronization
      await SyncService.enqueue(ApiConstants.farms, 'POST', farmPayload);
      await _clearDraft();
      _hasUnsavedChanges = false;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Offline: Farm saved locally. Will sync when connected.'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          title: const Text('Register New Farm Plot'),
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
                      labelText: 'Farm Plot Name',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                    ),
                    validator: (v) => Validators.required(v, 'Farm name'),
                    textCapitalization: TextCapitalization.words,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedCrop,
                    decoration: InputDecoration(
                      labelText: 'Primary Crop',
                      prefixIcon: const Icon(Icons.grass),
                      border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                    ),
                    items: EthiopianCrops.allCrops.map((crop) {
                      return DropdownMenuItem(
                        value: crop.nameEn,
                        child: Text('${crop.nameEn} (${crop.nameAm})'),
                      );
                    }).toList(),
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedCrop = v),
                  ),

                  if (_selectedCrop == 'Other (Custom Crop)') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customCropController,
                      decoration: InputDecoration(
                        labelText: 'Custom Crop Name',
                        prefixIcon: const Icon(Icons.eco_outlined, color: AppTheme.primaryColor),
                        border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                        filled: true,
                        fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                      ),
                      validator: (v) => _selectedCrop == 'Other (Custom Crop)' ? Validators.required(v, 'Custom crop name') : null,
                      enabled: !_isLoading,
                    ),
                  ],

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _sizeController,
                    decoration: InputDecoration(
                      labelText: 'Farm Size (Hectares)',
                      prefixIcon: const Icon(Icons.square_foot),
                      suffixText: 'ha',
                      border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                      filled: true,
                      fillColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF8FAF8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.farmArea,
                    enabled: !_isLoading,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Soil & Water Prescription Card
            _buildFormCard(
              title: 'Soil Classification & Irrigation',
              icon: Icons.science_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSoil,
                    decoration: InputDecoration(
                      labelText: 'EthioSIS Soil Type',
                      prefixIcon: const Icon(Icons.terrain),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Vertisol (Black Cotton - ጥቁር አፈር)',
                        child: Text('Vertisol (Black Cotton - ጥቁር አፈር)'),
                      ),
                      DropdownMenuItem(
                        value: 'Nitisol (Red Basaltic - ቀይ አፈር)',
                        child: Text('Nitisol (Red Basaltic - ቀይ አፈር)'),
                      ),
                      DropdownMenuItem(
                        value: 'Cambisol (Brown Loam - ቡናማ አፈር)',
                        child: Text('Cambisol (Brown Loam - ቡናማ አፈር)'),
                      ),
                      DropdownMenuItem(
                        value: 'Fluvisol (Alluvial - ወንዝ ዳርቻ አፈር)',
                        child: Text('Fluvisol (Alluvial - ወንዝ ዳርቻ አፈር)'),
                      ),
                    ],
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedSoil = v),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedIrrigation,
                    decoration: InputDecoration(
                      labelText: 'Water Source / Irrigation Mode',
                      prefixIcon: const Icon(Icons.water_drop),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Rainfed (የዝናብ እርሻ)',
                        child: Text('Rainfed (የዝናብ እርሻ)'),
                      ),
                      DropdownMenuItem(
                        value: 'Furrow Irrigation (የቦይ መስኖ)',
                        child: Text('Furrow Irrigation (የቦይ መስኖ)'),
                      ),
                      DropdownMenuItem(
                        value: 'Drip Irrigation (የጠብታ መስኖ)',
                        child: Text('Drip Irrigation (የጠብታ መስኖ)'),
                      ),
                      DropdownMenuItem(
                        value: 'Groundwater / Solar Pump (የከርሰ ምድር ውሀ)',
                        child: Text('Groundwater / Solar Pump (የከርሰ ምድር ውሀ)'),
                      ),
                    ],
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedIrrigation = v),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedSlope,
                    decoration: InputDecoration(
                      labelText: 'Topography / Slope',
                      prefixIcon: const Icon(Icons.landscape_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF9FAF9),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Flat / Plain (0-2% Slope)', child: Text('Flat / Plain (0-2% Slope)')),
                      DropdownMenuItem(value: 'Gentle Slope (2-8% Slope)', child: Text('Gentle Slope (2-8% Slope)')),
                      DropdownMenuItem(value: 'Highland Hillside (8-15% Slope)', child: Text('Highland Hillside (8-15% Slope)')),
                      DropdownMenuItem(value: 'Valley Bottom / River Basin', child: Text('Valley Bottom / River Basin')),
                    ],
                    onChanged: _isLoading ? null : (v) => setState(() => _selectedSlope = v ?? _selectedSlope),
                  ),
                  const SizedBox(height: 14),

                  // Sowing and Harvest Dates
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () async {
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
                          onPressed: _isLoading ? null : () async {
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

            // 3. Location & GIS Boundary Picker
            _buildFormCard(
              title: 'GIS Plot Boundary & Coordinates',
              icon: Icons.place,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('Tap Map\n(GIS)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        icon: Icon(Icons.touch_app, size: 14),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Woreda\n(Zero GPS)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        icon: Icon(Icons.map, size: 14),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text('Manual\nCoords', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        icon: Icon(Icons.edit_location_alt, size: 14),
                      ),
                      ButtonSegment(
                        value: 3,
                        label: Text('Auto\nGPS', textAlign: TextAlign.center, style: TextStyle(fontSize: 10)),
                        icon: Icon(Icons.my_location, size: 14),
                      ),
                    ],
                    selected: {_locationMode},
                    onSelectionChanged: (set) {
                      final mode = set.first;
                      setState(() => _locationMode = mode);
                      if (mode == 3) {
                        _getCurrentLocation();
                      }
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: const Color(0xFF1B5E20),
                      selectedForegroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mode 0: Interactive GIS Map Pinpoint
                  if (_locationMode == 0) ...[
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.4)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FlutterMap(
                          mapController: _miniMapController,
                          options: MapOptions(
                            initialCenter: LatLng(_latitude, _longitude),
                            initialZoom: 10.0,
                            onTap: _onMapPointTapped,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.agrietech.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(_latitude, _longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap anywhere on the map to pinpoint exact farm plot coordinates',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Mode 1: Administrative Woreda Picker
                  if (_locationMode == 1) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRegion,
                      decoration: InputDecoration(
                        labelText: 'Administrative Region',
                        prefixIcon: const Icon(Icons.public),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                      ),
                      items: _ethiopianRegions.map((r) => DropdownMenuItem(value: r.regionName, child: Text(r.regionName))).toList(),
                      onChanged: _isLoading ? null : (v) => v != null ? _onRegionChanged(v) : null,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedWoredaName,
                      decoration: InputDecoration(
                        labelText: 'Woreda Center',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                      ),
                      items: _currentWoredas.map((w) => DropdownMenuItem(value: w.woredaName, child: Text(w.woredaName))).toList(),
                      onChanged: _isLoading ? null : (v) => v != null ? _onWoredaChanged(v) : null,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Mode 2: Manual Coordinates
                  if (_locationMode == 2) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            decoration: InputDecoration(
                              labelText: 'Latitude (°N)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.latitude,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            decoration: InputDecoration(
                              labelText: 'Longitude (°E)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF1B2E1E) : Colors.white,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.longitude,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Mode 3: Auto-GPS Sensor
                  if (_locationMode == 3) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _isGettingLocation
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.gps_fixed, color: Color(0xFF2E7D32), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isGettingLocation
                                  ? 'Acquiring high-accuracy GNSS fix...'
                                  : 'Device GPS: ${_latitude.toStringAsFixed(5)}°N, ${_longitude.toStringAsFixed(5)}°E',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: _isGettingLocation ? null : _getCurrentLocation,
                            child: const Text('Re-scan'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Kebele & FTC Extension Station
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _kebeleController,
                          decoration: InputDecoration(
                            labelText: 'Kebele / Tabia (Admin 4)',
                            prefixIcon: const Icon(Icons.home_outlined),
                            border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                            filled: true,
                            fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _ftcController,
                          decoration: InputDecoration(
                            labelText: 'FTC / Extension Unit',
                            prefixIcon: const Icon(Icons.home_work_outlined),
                            border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                            filled: true,
                            fillColor: isDark ? AppTheme.surfaceDark : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Centroid Confirmation Card
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
                            'GIS Centroid: ${_latitude.toStringAsFixed(5)}°N, ${_longitude.toStringAsFixed(5)}°E ($_selectedWoredaName, $_selectedRegion)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1B5E20)),
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
                  _isLoading ? 'Registering & Syncing...' : 'Register Farm Plot',
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
