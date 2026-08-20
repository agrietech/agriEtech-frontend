import '../models/boundary_models.dart';

/// Preloaded standard Ethiopian administrative hierarchy data
/// Ensures instant UI responsiveness and offline resilience for Region, Zone, and Woreda selectors.
class EthiopiaBoundariesData {
  static const String _defaultDate = '2025-01-01T00:00:00.000Z';

  static final List<RegionModel> defaultRegions = [
    const RegionModel(
      id: 'reg_oromia',
      code: 'OR',
      name: 'Oromia',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_amhara',
      code: 'AM',
      name: 'Amhara',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_sidama',
      code: 'SI',
      name: 'Sidama',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_tigray',
      code: 'TG',
      name: 'Tigray',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_somali',
      code: 'SO',
      name: 'Somali',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_snnp',
      code: 'SN',
      name: 'Central Ethiopia (SNNP)',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_afar',
      code: 'AF',
      name: 'Afar',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_benishangul',
      code: 'BG',
      name: 'Benishangul-Gumuz',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_gambela',
      code: 'GA',
      name: 'Gambela',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_harari',
      code: 'HA',
      name: 'Harari',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_addis_ababa',
      code: 'AA',
      name: 'Addis Ababa',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
    const RegionModel(
      id: 'reg_dire_dawa',
      code: 'DD',
      name: 'Dire Dawa',
      createdAt: _defaultDate,
      updatedAt: _defaultDate,
    ),
  ];

  static final Map<String, List<ZoneModel>> defaultZonesByRegion = {
    'reg_oromia': [
      const ZoneModel(id: 'zone_east_shewa', regionId: 'reg_oromia', name: 'East Shewa', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_west_shewa', regionId: 'reg_oromia', name: 'West Shewa', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_arsi', regionId: 'reg_oromia', name: 'Arsi', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_west_arsi', regionId: 'reg_oromia', name: 'West Arsi', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_jimma', regionId: 'reg_oromia', name: 'Jimma', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_bale', regionId: 'reg_oromia', name: 'Bale', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_borena', regionId: 'reg_oromia', name: 'Borena', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_east_hararghe', regionId: 'reg_oromia', name: 'East Hararghe', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_west_hararghe', regionId: 'reg_oromia', name: 'West Hararghe', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_illubabor', regionId: 'reg_oromia', name: 'Illubabor', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_amhara': [
      const ZoneModel(id: 'zone_east_gojjam', regionId: 'reg_amhara', name: 'East Gojjam', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_west_gojjam', regionId: 'reg_amhara', name: 'West Gojjam', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_south_wollo', regionId: 'reg_amhara', name: 'South Wollo', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_north_wollo', regionId: 'reg_amhara', name: 'North Wollo', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_north_shewa_am', regionId: 'reg_amhara', name: 'North Shewa', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_south_gondar', regionId: 'reg_amhara', name: 'South Gondar', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_central_gondar', regionId: 'reg_amhara', name: 'Central Gondar', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_west_gondar', regionId: 'reg_amhara', name: 'West Gondar', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_awi', regionId: 'reg_amhara', name: 'Awi', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_sidama': [
      const ZoneModel(id: 'zone_hawassa_zuria', regionId: 'reg_sidama', name: 'Hawassa Zuria', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_aleta_wondo', regionId: 'reg_sidama', name: 'Aleta Wondo', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_yirgalem', regionId: 'reg_sidama', name: 'Yirgalem', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_bona_zuria', regionId: 'reg_sidama', name: 'Bona Zuria', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_tigray': [
      const ZoneModel(id: 'zone_central_tigray', regionId: 'reg_tigray', name: 'Central Tigray', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_eastern_tigray', regionId: 'reg_tigray', name: 'Eastern Tigray', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_southern_tigray', regionId: 'reg_tigray', name: 'Southern Tigray', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_north_western_tigray', regionId: 'reg_tigray', name: 'North Western Tigray', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_south_eastern_tigray', regionId: 'reg_tigray', name: 'South Eastern Tigray', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_somali': [
      const ZoneModel(id: 'zone_fafan', regionId: 'reg_somali', name: 'Fafan', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_siti', regionId: 'reg_somali', name: 'Siti', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_shabelle', regionId: 'reg_somali', name: 'Shabelle', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_doollo', regionId: 'reg_somali', name: 'Doollo', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_jarar', regionId: 'reg_somali', name: 'Jarar', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_snnp': [
      const ZoneModel(id: 'zone_gurage', regionId: 'reg_snnp', name: 'Gurage', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_wolayita', regionId: 'reg_snnp', name: 'Wolayita', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_hadiya', regionId: 'reg_snnp', name: 'Hadiya', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_kembata', regionId: 'reg_snnp', name: 'Kembata Tembaro', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_gamo', regionId: 'reg_snnp', name: 'Gamo', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_silte', regionId: 'reg_snnp', name: 'Silte', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_afar': [
      const ZoneModel(id: 'zone_afar_1', regionId: 'reg_afar', name: 'Awsi Rasu (Zone 1)', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_afar_2', regionId: 'reg_afar', name: 'Kilbet Rasu (Zone 2)', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_afar_3', regionId: 'reg_afar', name: 'Gabi Rasu (Zone 3)', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_benishangul': [
      const ZoneModel(id: 'zone_metekel', regionId: 'reg_benishangul', name: 'Metekel', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_asosa', regionId: 'reg_benishangul', name: 'Asosa', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_kamashi', regionId: 'reg_benishangul', name: 'Kamashi', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_gambela': [
      const ZoneModel(id: 'zone_anuak', regionId: 'reg_gambela', name: 'Anuak', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_nuer', regionId: 'reg_gambela', name: 'Nuer', createdAt: _defaultDate, updatedAt: _defaultDate),
      const ZoneModel(id: 'zone_majang', regionId: 'reg_gambela', name: 'Majang', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_harari': [
      const ZoneModel(id: 'zone_harari', regionId: 'reg_harari', name: 'Harari City & Woredas', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_addis_ababa': [
      const ZoneModel(id: 'zone_aa_central', regionId: 'reg_addis_ababa', name: 'Addis Ababa Sub-Cities', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'reg_dire_dawa': [
      const ZoneModel(id: 'zone_dd_admin', regionId: 'reg_dire_dawa', name: 'Dire Dawa Administration', createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
  };

  static final Map<String, List<WoredaModel>> defaultWoredasByZone = {
    'zone_east_shewa': [
      const WoredaModel(id: 'woreda_adaa', zoneId: 'zone_east_shewa', name: "Ada'a", centerLat: 8.75, centerLng: 38.98, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_lome', zoneId: 'zone_east_shewa', name: 'Lome', centerLat: 8.60, centerLng: 39.12, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dugda', zoneId: 'zone_east_shewa', name: 'Dugda', centerLat: 8.18, centerLng: 38.72, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_adama_zuria', zoneId: 'zone_east_shewa', name: 'Adama Zuria', centerLat: 8.54, centerLng: 39.27, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_boset', zoneId: 'zone_east_shewa', name: 'Boset', centerLat: 8.68, centerLng: 39.45, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_gimbichu', zoneId: 'zone_east_shewa', name: 'Gimbichu', centerLat: 8.95, centerLng: 39.12, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_bora', zoneId: 'zone_east_shewa', name: 'Bora', centerLat: 8.35, centerLng: 38.80, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_west_shewa': [
      const WoredaModel(id: 'woreda_ambo', zoneId: 'zone_west_shewa', name: 'Ambo', centerLat: 8.98, centerLng: 37.85, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dendi', zoneId: 'zone_west_shewa', name: 'Dendi', centerLat: 9.02, centerLng: 38.15, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_walmara', zoneId: 'zone_west_shewa', name: 'Walmara', centerLat: 9.08, centerLng: 38.52, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_ejere', zoneId: 'zone_west_shewa', name: 'Ejere', centerLat: 8.95, centerLng: 38.35, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_tokke_kuttaye', zoneId: 'zone_west_shewa', name: 'Tokke Kuttaye', centerLat: 9.05, centerLng: 37.60, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_arsi': [
      const WoredaModel(id: 'woreda_tiyo', zoneId: 'zone_arsi', name: 'Tiyo (Asella)', centerLat: 7.95, centerLng: 39.15, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_hetosa', zoneId: 'zone_arsi', name: 'Hetosa', centerLat: 8.12, centerLng: 39.32, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_digelu', zoneId: 'zone_arsi', name: 'Digelu and Tijo', centerLat: 7.78, centerLng: 39.25, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dodota', zoneId: 'zone_arsi', name: 'Dodota', centerLat: 8.30, centerLng: 39.35, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_limu_bilbilo', zoneId: 'zone_arsi', name: 'Limu and Bilbilo', centerLat: 7.60, centerLng: 39.40, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_jimma': [
      const WoredaModel(id: 'woreda_mana', zoneId: 'zone_jimma', name: 'Mana', centerLat: 7.75, centerLng: 36.80, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_gomma', zoneId: 'zone_jimma', name: 'Gomma', centerLat: 7.85, centerLng: 36.65, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_kersa', zoneId: 'zone_jimma', name: 'Kersa', centerLat: 7.70, centerLng: 37.00, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_limmu_kosa', zoneId: 'zone_jimma', name: 'Limmu Kosa', centerLat: 8.15, centerLng: 36.95, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_seka_cheworsa', zoneId: 'zone_jimma', name: 'Seka Cheworsa', centerLat: 7.55, centerLng: 36.75, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_east_gojjam': [
      const WoredaModel(id: 'woreda_dejen', zoneId: 'zone_east_gojjam', name: 'Dejen', centerLat: 10.16, centerLng: 38.13, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_debre_markos', zoneId: 'zone_east_gojjam', name: 'Debre Markos Zuria', centerLat: 10.33, centerLng: 37.73, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_machakel', zoneId: 'zone_east_gojjam', name: 'Machakel', centerLat: 10.55, centerLng: 37.65, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_shebel_berenta', zoneId: 'zone_east_gojjam', name: 'Shebel Berenta', centerLat: 10.30, centerLng: 38.35, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_enemay', zoneId: 'zone_east_gojjam', name: 'Enemay', centerLat: 10.45, centerLng: 37.95, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_south_wollo': [
      const WoredaModel(id: 'woreda_dessie_zuria', zoneId: 'zone_south_wollo', name: 'Dessie Zuria', centerLat: 11.13, centerLng: 39.63, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_kalu', zoneId: 'zone_south_wollo', name: 'Kalu', centerLat: 11.08, centerLng: 39.78, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_tehuledere', zoneId: 'zone_south_wollo', name: 'Tehuledere', centerLat: 11.30, centerLng: 39.65, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_ambasel', zoneId: 'zone_south_wollo', name: 'Ambasel', centerLat: 11.55, centerLng: 39.60, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_were_babu', zoneId: 'zone_south_wollo', name: 'Were Babu', centerLat: 11.45, centerLng: 39.85, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_hawassa_zuria': [
      const WoredaModel(id: 'woreda_hawassa_zuria', zoneId: 'zone_hawassa_zuria', name: 'Hawassa Zuria', centerLat: 7.05, centerLng: 38.48, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_shebedino', zoneId: 'zone_hawassa_zuria', name: 'Shebedino', centerLat: 6.92, centerLng: 38.45, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_aleta_chuko', zoneId: 'zone_hawassa_zuria', name: 'Aleta Chuko', centerLat: 6.65, centerLng: 38.38, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_boricha', zoneId: 'zone_hawassa_zuria', name: 'Boricha', centerLat: 6.95, centerLng: 38.30, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dale', zoneId: 'zone_hawassa_zuria', name: 'Dale', centerLat: 6.80, centerLng: 38.35, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_central_tigray': [
      const WoredaModel(id: 'woreda_axum', zoneId: 'zone_central_tigray', name: 'Axum Zuria', centerLat: 14.12, centerLng: 38.72, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_adwa', zoneId: 'zone_central_tigray', name: 'Adwa', centerLat: 14.16, centerLng: 38.90, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_werie_leke', zoneId: 'zone_central_tigray', name: 'Werie Leke', centerLat: 14.05, centerLng: 39.05, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_fafan': [
      const WoredaModel(id: 'woreda_jijiga', zoneId: 'zone_fafan', name: 'Jijiga Woreda', centerLat: 9.35, centerLng: 42.80, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_kebribeyah', zoneId: 'zone_fafan', name: 'Kebribeyah', centerLat: 9.10, centerLng: 43.15, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_awbare', zoneId: 'zone_fafan', name: 'Awbare', centerLat: 9.75, centerLng: 43.10, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_gursum_so', zoneId: 'zone_fafan', name: 'Gursum (Somali)', centerLat: 9.30, centerLng: 42.45, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_gurage': [
      const WoredaModel(id: 'woreda_wolkite', zoneId: 'zone_gurage', name: 'Wolkite', centerLat: 8.28, centerLng: 37.78, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_cheha', zoneId: 'zone_gurage', name: 'Cheha', centerLat: 8.18, centerLng: 37.85, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_ezha', zoneId: 'zone_gurage', name: 'Ezha', centerLat: 8.12, centerLng: 38.00, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_gumero', zoneId: 'zone_gurage', name: 'Gumer', centerLat: 8.02, centerLng: 38.05, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_wolayita': [
      const WoredaModel(id: 'woreda_sodo_zuria', zoneId: 'zone_wolayita', name: 'Sodo Zuria', centerLat: 6.85, centerLng: 37.75, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_damot_gale', zoneId: 'zone_wolayita', name: 'Damot Gale', centerLat: 6.98, centerLng: 37.88, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_damot_woyde', zoneId: 'zone_wolayita', name: 'Damot Woyde', centerLat: 6.90, centerLng: 38.00, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_boloso_sore', zoneId: 'zone_wolayita', name: 'Boloso Sore', centerLat: 7.05, centerLng: 37.68, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_afar_1': [
      const WoredaModel(id: 'woreda_asayita', zoneId: 'zone_afar_1', name: 'Asayita', centerLat: 11.56, centerLng: 41.44, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dubti', zoneId: 'zone_afar_1', name: 'Dubti', centerLat: 11.73, centerLng: 41.08, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_afambo', zoneId: 'zone_afar_1', name: 'Afambo', centerLat: 11.45, centerLng: 41.70, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_metekel': [
      const WoredaModel(id: 'woreda_mandura', zoneId: 'zone_metekel', name: 'Mandura', centerLat: 10.90, centerLng: 36.35, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dangur', zoneId: 'zone_metekel', name: 'Dangur', centerLat: 11.20, centerLng: 36.00, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_pawe', zoneId: 'zone_metekel', name: 'Pawe', centerLat: 11.32, centerLng: 36.42, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_guba', zoneId: 'zone_metekel', name: 'Guba', centerLat: 11.25, centerLng: 35.25, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_bullen', zoneId: 'zone_metekel', name: 'Bullen', centerLat: 10.60, centerLng: 36.05, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_asosa': [
      const WoredaModel(id: 'woreda_asosa', zoneId: 'zone_asosa', name: 'Asosa Zuria', centerLat: 10.05, centerLng: 34.53, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_bambasi', zoneId: 'zone_asosa', name: 'Bambasi', centerLat: 9.75, centerLng: 34.72, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_homosha', zoneId: 'zone_asosa', name: 'Homosha', centerLat: 10.35, centerLng: 34.65, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_menge', zoneId: 'zone_asosa', name: 'Menge', centerLat: 10.40, centerLng: 34.85, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_kurmuk', zoneId: 'zone_asosa', name: 'Kurmuk', centerLat: 10.55, centerLng: 34.28, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_kamashi': [
      const WoredaModel(id: 'woreda_kamashi', zoneId: 'zone_kamashi', name: 'Kamashi', centerLat: 9.50, centerLng: 35.85, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_belo_jegonfoy', zoneId: 'zone_kamashi', name: 'Belo Jegonfoy', centerLat: 9.35, centerLng: 36.15, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_sirba_abbay', zoneId: 'zone_kamashi', name: 'Sirba Abbay', centerLat: 10.00, centerLng: 35.30, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_anuak': [
      const WoredaModel(id: 'woreda_gambela_zuria', zoneId: 'zone_anuak', name: 'Gambela Zuria', centerLat: 8.25, centerLng: 34.58, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_abobo', zoneId: 'zone_anuak', name: 'Abobo', centerLat: 7.85, centerLng: 34.55, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_gog', zoneId: 'zone_anuak', name: 'Gog', centerLat: 7.50, centerLng: 34.40, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dimma', zoneId: 'zone_anuak', name: 'Dimma', centerLat: 6.80, centerLng: 35.10, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_nuer': [
      const WoredaModel(id: 'woreda_lare', zoneId: 'zone_nuer', name: 'Lare', centerLat: 8.35, centerLng: 33.95, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_itang', zoneId: 'zone_nuer', name: 'Itang Special', centerLat: 8.20, centerLng: 34.25, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_jikaw', zoneId: 'zone_nuer', name: 'Jikaw', centerLat: 8.40, centerLng: 33.75, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_akobo', zoneId: 'zone_nuer', name: 'Akobo', centerLat: 7.80, centerLng: 33.00, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_majang': [
      const WoredaModel(id: 'woreda_mengesh', zoneId: 'zone_majang', name: 'Mengesh', centerLat: 7.35, centerLng: 35.30, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_godere', zoneId: 'zone_majang', name: 'Godere', centerLat: 7.15, centerLng: 35.20, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_harari': [
      const WoredaModel(id: 'woreda_amir_nur', zoneId: 'zone_harari', name: 'Amir-Nur', centerLat: 9.31, centerLng: 42.13, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_sofi', zoneId: 'zone_harari', name: 'Sofi (Rural)', centerLat: 9.25, centerLng: 42.20, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_erer', zoneId: 'zone_harari', name: 'Erer (Rural)', centerLat: 9.35, centerLng: 42.25, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_dire_teyara', zoneId: 'zone_harari', name: 'Dire-Teyara', centerLat: 9.38, centerLng: 42.10, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_aa_central': [
      const WoredaModel(id: 'woreda_bole', zoneId: 'zone_aa_central', name: 'Bole Sub-City', centerLat: 8.98, centerLng: 38.78, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_yeka', zoneId: 'zone_aa_central', name: 'Yeka Sub-City', centerLat: 9.04, centerLng: 38.82, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_akaki_kality', zoneId: 'zone_aa_central', name: 'Akaki-Kality Sub-City', centerLat: 8.88, centerLng: 38.75, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_lemi_kura', zoneId: 'zone_aa_central', name: 'Lemi-Kura Sub-City', centerLat: 9.02, centerLng: 38.86, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_kolfe', zoneId: 'zone_aa_central', name: 'Kolfe-Keranio Sub-City', centerLat: 9.01, centerLng: 38.70, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
    'zone_dd_admin': [
      const WoredaModel(id: 'woreda_dd_urban', zoneId: 'zone_dd_admin', name: 'Dire Dawa Urban', centerLat: 9.59, centerLng: 41.86, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_melka_jebdu', zoneId: 'zone_dd_admin', name: 'Melka Jebdu', centerLat: 9.62, centerLng: 41.80, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_wahil', zoneId: 'zone_dd_admin', name: 'Wahil (Rural)', centerLat: 9.65, centerLng: 41.95, createdAt: _defaultDate, updatedAt: _defaultDate),
      const WoredaModel(id: 'woreda_biyawale', zoneId: 'zone_dd_admin', name: 'Biyawale', centerLat: 9.50, centerLng: 41.78, createdAt: _defaultDate, updatedAt: _defaultDate),
    ],
  };

  /// Fallback woreda finder
  static List<WoredaModel> getFallbackWoredas(String? zoneId) {
    if (zoneId == null) return [];
    if (defaultWoredasByZone.containsKey(zoneId)) {
      return defaultWoredasByZone[zoneId]!;
    }
    // Generic fallback for any zone without explicit sub-list
    return [
      WoredaModel(
        id: '${zoneId}_woreda_01',
        zoneId: zoneId,
        name: 'District Central',
        centerLat: 9.0,
        centerLng: 38.7,
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      WoredaModel(
        id: '${zoneId}_woreda_02',
        zoneId: zoneId,
        name: 'District North',
        centerLat: 9.1,
        centerLng: 38.8,
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      WoredaModel(
        id: '${zoneId}_woreda_03',
        zoneId: zoneId,
        name: 'District South',
        centerLat: 8.9,
        centerLng: 38.6,
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
    ];
  }

  /// Fallback zone finder
  static List<ZoneModel> getFallbackZones(String? regionId) {
    if (regionId == null) return [];
    if (defaultZonesByRegion.containsKey(regionId)) {
      return defaultZonesByRegion[regionId]!;
    }
    return [
      ZoneModel(
        id: '${regionId}_zone_01',
        regionId: regionId,
        name: 'Central Zone',
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      ZoneModel(
        id: '${regionId}_zone_02',
        regionId: regionId,
        name: 'Eastern Zone',
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      ZoneModel(
        id: '${regionId}_zone_03',
        regionId: regionId,
        name: 'Western Zone',
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
    ];
  }
}
