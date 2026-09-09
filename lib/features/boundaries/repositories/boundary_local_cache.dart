import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/boundary_models.dart';

/// Persistent local disk cache manager for administrative boundaries.
/// Follows Silicon Valley mobile architecture: 0ms offline access with seamless background sync.
class BoundaryLocalCache {
  static const String _prefix = 'agri_boundaries_';
  static const String _keyRegions = '${_prefix}regions';
  static const String _keyZonesPrefix = '${_prefix}zones_';
  static const String _keyWoredasPrefix = '${_prefix}woredas_';
  static const String _keyAllWoredas = '${_prefix}woredas_all';
  static const String _keyWoredaDetailPrefix = '${_prefix}woreda_detail_';
  static const String _keyLastSyncPrefix = '${_prefix}last_sync_';

  // In-memory L1 cache for instant sub-millisecond lookups
  static final Map<String, List<RegionModel>> _memRegions = {};
  static final Map<String, List<ZoneModel>> _memZones = {};
  static final Map<String, List<WoredaModel>> _memWoredas = {};
  static final Map<String, WoredaModel> _memWoredaDetails = {};

  /// Genuine OCHA HDX administrative regions
  static const List<RegionModel> defaultRegions = [
    RegionModel(id: 'ET01', code: 'ET01', name: 'Tigray', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET02', code: 'ET02', name: 'Afar', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET03', code: 'ET03', name: 'Amhara', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET04', code: 'ET04', name: 'Oromia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET05', code: 'ET05', name: 'Somali', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET06', code: 'ET06', name: 'Benishangul-Gumuz', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET07', code: 'ET07', name: 'Gambela', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET08', code: 'ET08', name: 'Harari', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET10', code: 'ET10', name: 'Sidama', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET11', code: 'ET11', name: 'Central Ethiopia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET12', code: 'ET12', name: 'South Ethiopia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET13', code: 'ET13', name: 'South West Ethiopia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET14', code: 'ET14', name: 'Addis Ababa', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET15', code: 'ET15', name: 'Dire Dawa', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'ET99', code: 'ET99', name: 'Contested Area', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
  ];

  /// Baseline fallback zones by region for zero-latency offline loading
  static const Map<String, List<ZoneModel>> defaultZonesByRegion = {
    'ET04': [
      ZoneModel(id: 'ET0401', regionId: 'ET04', name: 'West Wellega'),
      ZoneModel(id: 'ET0402', regionId: 'ET04', name: 'East Wellega'),
      ZoneModel(id: 'ET0403', regionId: 'ET04', name: 'Ilu Aba Bora'),
      ZoneModel(id: 'ET0404', regionId: 'ET04', name: 'Jimma'),
      ZoneModel(id: 'ET0405', regionId: 'ET04', name: 'West Shewa'),
      ZoneModel(id: 'ET0406', regionId: 'ET04', name: 'North Shewa (OR)'),
      ZoneModel(id: 'ET0407', regionId: 'ET04', name: 'East Shewa'),
      ZoneModel(id: 'ET0408', regionId: 'ET04', name: 'Arsi'),
      ZoneModel(id: 'ET0409', regionId: 'ET04', name: 'West Hararge'),
      ZoneModel(id: 'ET0410', regionId: 'ET04', name: 'East Hararge'),
      ZoneModel(id: 'ET0411', regionId: 'ET04', name: 'Bale'),
      ZoneModel(id: 'ET0412', regionId: 'ET04', name: 'Borena'),
      ZoneModel(id: 'ET0413', regionId: 'ET04', name: 'Guji'),
    ],
    'ET03': [
      ZoneModel(id: 'ET0301', regionId: 'ET03', name: 'North Gondar'),
      ZoneModel(id: 'ET0302', regionId: 'ET03', name: 'South Gondar'),
      ZoneModel(id: 'ET0303', regionId: 'ET03', name: 'North Wello'),
      ZoneModel(id: 'ET0304', regionId: 'ET03', name: 'South Wello'),
      ZoneModel(id: 'ET0305', regionId: 'ET03', name: 'North Shewa (AM)'),
      ZoneModel(id: 'ET0306', regionId: 'ET03', name: 'East Gojam'),
      ZoneModel(id: 'ET0307', regionId: 'ET03', name: 'West Gojam'),
      ZoneModel(id: 'ET0308', regionId: 'ET03', name: 'Wag Hamra'),
      ZoneModel(id: 'ET0309', regionId: 'ET03', name: 'Awi'),
      ZoneModel(id: 'ET0314', regionId: 'ET03', name: 'Bahir Dar town Admin'),
    ],
    'ET01': [
      ZoneModel(id: 'ET0101', regionId: 'ET01', name: 'North Western'),
      ZoneModel(id: 'ET0102', regionId: 'ET01', name: 'Central'),
      ZoneModel(id: 'ET0103', regionId: 'ET01', name: 'Eastern'),
      ZoneModel(id: 'ET0104', regionId: 'ET01', name: 'Southern'),
      ZoneModel(id: 'ET0106', regionId: 'ET01', name: 'South Eastern'),
      ZoneModel(id: 'ET0107', regionId: 'ET01', name: 'Mekelle'),
    ],
    'ET14': [
      ZoneModel(id: 'ET1401', regionId: 'ET14', name: 'Addis Ababa Zone 1'),
      ZoneModel(id: 'ET1402', regionId: 'ET14', name: 'Addis Ababa Zone 2'),
    ],
    'ET10': [
      ZoneModel(id: 'ET1001', regionId: 'ET10', name: 'Hawassa City'),
      ZoneModel(id: 'ET1002', regionId: 'ET10', name: 'Sidama Zone'),
    ],
    'ET05': [
      ZoneModel(id: 'ET0501', regionId: 'ET05', name: 'Sitti'),
      ZoneModel(id: 'ET0502', regionId: 'ET05', name: 'Fafan /Jigjiga'),
      ZoneModel(id: 'ET0503', regionId: 'ET05', name: 'Jarar'),
    ],
  };

  /// Baseline fallback woredas by zone for zero-latency offline loading
  static const Map<String, List<WoredaModel>> defaultWoredasByZone = {
    'ET0407': [
      WoredaModel(id: 'ET040101', zoneId: 'ET0407', name: 'Adama Zuria', centerLat: 8.54, centerLng: 39.27),
      WoredaModel(id: 'ET040102', zoneId: 'ET0407', name: 'Bishoftu /Ada\'a', centerLat: 8.75, centerLng: 38.98),
      WoredaModel(id: 'ET040103', zoneId: 'ET0407', name: 'Lome', centerLat: 8.60, centerLng: 39.12),
      WoredaModel(id: 'ET040104', zoneId: 'ET0407', name: 'Bora', centerLat: 8.35, centerLng: 38.75),
      WoredaModel(id: 'ET040105', zoneId: 'ET0407', name: 'Dugda', centerLat: 8.20, centerLng: 38.80),
      WoredaModel(id: 'ET040106', zoneId: 'ET0407', name: 'Gimbichu', centerLat: 8.90, centerLng: 39.15),
    ],
    'ET0405': [
      WoredaModel(id: 'ET040501', zoneId: 'ET0405', name: 'Ambo Zuria', centerLat: 8.98, centerLng: 37.85),
      WoredaModel(id: 'ET040502', zoneId: 'ET0405', name: 'Dendi', centerLat: 9.02, centerLng: 38.15),
      WoredaModel(id: 'ET040503', zoneId: 'ET0405', name: 'Walmara', centerLat: 9.07, centerLng: 38.52),
    ],
    'ET0306': [
      WoredaModel(id: 'ET030601', zoneId: 'ET0306', name: 'Debre Markos', centerLat: 10.33, centerLng: 37.73),
      WoredaModel(id: 'ET030602', zoneId: 'ET0306', name: 'Machakel', centerLat: 10.45, centerLng: 37.60),
    ],
    'ET0107': [
      WoredaModel(id: 'ET010701', zoneId: 'ET0107', name: 'Mekelle Central', centerLat: 13.50, centerLng: 39.47),
    ],
  };

  // --------------------------------------------------------------------------
  // REGIONS
  // --------------------------------------------------------------------------

  /// Get cached regions from memory L1 or persistent disk L2
  static Future<List<RegionModel>> getRegions() async {
    if (_memRegions.containsKey('all') && _memRegions['all']!.isNotEmpty) {
      return _memRegions['all']!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyRegions);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr);
        final list = raw.map((e) => RegionModel.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          _memRegions['all'] = list;
          return list;
        }
      }
    } catch (_) {}
    return defaultRegions;
  }

  /// Persist regions to disk and memory
  static Future<void> saveRegions(List<RegionModel> regions) async {
    if (regions.isEmpty) return;
    _memRegions['all'] = regions;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(regions.map((e) => e.toJson()).toList());
      await prefs.setString(_keyRegions, jsonStr);
      await prefs.setInt('${_keyLastSyncPrefix}regions', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // ZONES
  // --------------------------------------------------------------------------

  /// Get cached zones for a specific region
  static Future<List<ZoneModel>> getZonesByRegion(String regionId) async {
    if (_memZones.containsKey(regionId) && _memZones[regionId]!.isNotEmpty) {
      return _memZones[regionId]!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_keyZonesPrefix$regionId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr);
        final list = raw.map((e) => ZoneModel.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          _memZones[regionId] = list;
          return list;
        }
      }
    } catch (_) {}
    return defaultZonesByRegion[regionId] ?? [];
  }

  /// Persist zones for a specific region
  static Future<void> saveZonesByRegion(String regionId, List<ZoneModel> zones) async {
    if (zones.isEmpty) return;
    _memZones[regionId] = zones;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(zones.map((e) => e.toJson()).toList());
      await prefs.setString('$_keyZonesPrefix$regionId', jsonStr);
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // WOREDAS
  // --------------------------------------------------------------------------

  /// Get cached woredas for a specific zone
  static Future<List<WoredaModel>> getWoredasByZone(String zoneId) async {
    if (_memWoredas.containsKey(zoneId) && _memWoredas[zoneId]!.isNotEmpty) {
      return _memWoredas[zoneId]!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_keyWoredasPrefix$zoneId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr);
        final list = raw.map((e) => WoredaModel.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          _memWoredas[zoneId] = list;
          return list;
        }
      }
    } catch (_) {}
    return defaultWoredasByZone[zoneId] ?? [];
  }

  /// Persist woredas for a specific zone
  static Future<void> saveWoredasByZone(String zoneId, List<WoredaModel> woredas) async {
    if (woredas.isEmpty) return;
    _memWoredas[zoneId] = woredas;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(woredas.map((e) => e.toJson()).toList());
      await prefs.setString('$_keyWoredasPrefix$zoneId', jsonStr);
    } catch (_) {}
  }

  /// Get all cached woredas across all zones
  static Future<List<WoredaModel>> getAllWoredas() async {
    if (_memWoredas.containsKey('all') && _memWoredas['all']!.isNotEmpty) {
      return _memWoredas['all']!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyAllWoredas);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr);
        final list = raw.map((e) => WoredaModel.fromJson(e as Map<String, dynamic>)).toList();
        if (list.isNotEmpty) {
          _memWoredas['all'] = list;
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  /// Persist all woredas
  static Future<void> saveAllWoredas(List<WoredaModel> woredas) async {
    if (woredas.isEmpty) return;
    _memWoredas['all'] = woredas;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(woredas.map((e) => e.toJson()).toList());
      await prefs.setString(_keyAllWoredas, jsonStr);
    } catch (_) {}
  }

  // --------------------------------------------------------------------------
  // WOREDA DETAIL
  // --------------------------------------------------------------------------

  /// Get single woreda by ID from cache
  static Future<WoredaModel?> getWoredaById(String woredaId) async {
    if (_memWoredaDetails.containsKey(woredaId)) {
      return _memWoredaDetails[woredaId];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_keyWoredaDetailPrefix$woredaId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> raw = jsonDecode(jsonStr);
        final woreda = WoredaModel.fromJson(raw);
        _memWoredaDetails[woredaId] = woreda;
        return woreda;
      }
    } catch (_) {}
    return null;
  }

  /// Persist single woreda detail
  static Future<void> saveWoredaById(String woredaId, WoredaModel woreda) async {
    _memWoredaDetails[woredaId] = woreda;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(woreda.toJson());
      await prefs.setString('$_keyWoredaDetailPrefix$woredaId', jsonStr);
    } catch (_) {}
  }

  /// Clear all boundary caches
  static Future<void> clearCache() async {
    _memRegions.clear();
    _memZones.clear();
    _memWoredas.clear();
    _memWoredaDetails.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }
}
