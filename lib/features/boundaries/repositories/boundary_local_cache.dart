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

  /// Cold-boot baseline standard regions
  static const List<RegionModel> defaultRegions = [
    RegionModel(id: 'reg_oromia', code: 'OR', name: 'Oromia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_amhara', code: 'AM', name: 'Amhara', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_sidama', code: 'SI', name: 'Sidama', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_tigray', code: 'TG', name: 'Tigray', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_somali', code: 'SO', name: 'Somali', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_central_ethiopia', code: 'CE', name: 'Central Ethiopia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_south_ethiopia', code: 'SE', name: 'South Ethiopia', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_swepr', code: 'SW', name: "South West Ethiopia Peoples' Region", createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_afar', code: 'AF', name: 'Afar', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_benishangul', code: 'BG', name: 'Benishangul-Gumuz', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_gambela', code: 'GA', name: 'Gambela', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_harari', code: 'HA', name: 'Harari', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_addis_ababa', code: 'AA', name: 'Addis Ababa (City Administration)', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_dire_dawa', code: 'DD', name: 'Dire Dawa (Administration)', createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
    RegionModel(id: 'reg_snnp', code: 'SN', name: "Southern Nations, Nationalities & Peoples' (SNNPR)", createdAt: '2026-08-17T00:00:00.000Z', updatedAt: '2026-08-17T00:00:00.000Z'),
  ];

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
    return [];
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
    return [];
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
