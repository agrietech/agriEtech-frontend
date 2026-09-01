import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../alerts/models/alert_models.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../models/spatial_risk_model.dart';

/// Baseline geometry and spatial profile data for all 12 major Ethiopian agricultural zones
final List<WoredaSpatialProfile> defaultWoredaSpatialProfiles = [
  const WoredaSpatialProfile(
    id: 'wor_adama',
    woredaName: 'Adama (Central Wonji Rift)',
    region: 'Oromia',
    aez: 'Weina Dega / Rift Floor',
    elevation: 1712,
    centroid: LatLng(8.54, 39.27),
    polygon: [
      LatLng(8.72, 39.15),
      LatLng(8.75, 39.42),
      LatLng(8.38, 39.45),
      LatLng(8.35, 39.16),
    ],
    compositeRisk: 0.68,
    riskLevel: 'HIGH',
    pgaG: 0.14,
    soilLossTonsPerHa: 18.4,
    slopePercent: 8.5,
    spi3: -0.25,
    riverDischargeM3s: 342.0,
    nearestVolcanoDistKm: 28.0,
    nearestVolcanoName: 'Fentale & Alutu Complex',
    amharicAdvisory: 'በዎንጂ ስምጥ-ሸለቆ የመሬት መንቀጥቀጥና የአዋሽ ወንዝ ሙላት ምክንያት የመስኖ ቦዮችንና እርከኖችን ያጠናክሩ።',
    oromoAdvisory: 'Sochii lafaa fi lolaa Laga Awaash ittisuuf daagaa fi sarara dhangala\'aa to\'adhaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_semara',
    woredaName: 'Semara (Afar Mega-Rift)',
    region: 'Afar',
    aez: 'Bereha (Arid Lowland)',
    elevation: 435,
    centroid: LatLng(11.79, 41.01),
    polygon: [
      LatLng(12.08, 40.82),
      LatLng(12.05, 41.28),
      LatLng(11.52, 41.22),
      LatLng(11.58, 40.78),
    ],
    compositeRisk: 0.88,
    riskLevel: 'CRITICAL',
    pgaG: 0.22,
    soilLossTonsPerHa: 6.2,
    slopePercent: 4.2,
    spi3: -1.75,
    riverDischargeM3s: 210.0,
    nearestVolcanoDistKm: 32.0,
    nearestVolcanoName: 'Erta Ale & Dabbahu Caldera',
    amharicAdvisory: 'የአፋር ስምጥ ሸለቆ የመሬት መንቀጥቀጥ፣ ከፍተኛ ድርቅና የእሳተ-ገሞራ አመድ ስጋት አለ። የጥንቃቄ እርምጃ ይውሰዱ።',
    oromoAdvisory: 'Balaan goginsaa cimaa fi sochii lafaa waan jiruuf bishaan fi dawoo qusadhaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_debre_berhan',
    woredaName: 'Debre Berhan (Highland Escarpment)',
    region: 'Amhara',
    aez: 'Dega / Wurch (Highland Alpine)',
    elevation: 2840,
    centroid: LatLng(9.68, 39.53),
    polygon: [
      LatLng(9.88, 39.38),
      LatLng(9.90, 39.70),
      LatLng(9.48, 39.68),
      LatLng(9.45, 39.35),
    ],
    compositeRisk: 0.72,
    riskLevel: 'HIGH',
    pgaG: 0.11,
    soilLossTonsPerHa: 34.5,
    slopePercent: 24.0,
    spi3: 0.35,
    riverDischargeM3s: 85.0,
    nearestVolcanoDistKm: 85.0,
    nearestVolcanoName: 'Ankober Border Zone',
    amharicAdvisory: 'ቁልቁለታማ የደብረ ሲና ዳገቶች ላይ የመሬት መንሸራተትና ከፍተኛ የአፈር መሸርሸር (34.5 t/ha) ስጋት አለ። ፋንያ ጁ እርከን ይስሩ።',
    oromoAdvisory: 'Dhiqama biyyoo fi sigiga lafaa ittisuuf daagaa Fanya Juu fi muka dhaabaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_nekemte',
    woredaName: 'Nekemte (Western Acidic Soils)',
    region: 'Oromia',
    aez: 'Weina Dega (High Rainfall)',
    elevation: 2088,
    centroid: LatLng(9.08, 36.55),
    polygon: [
      LatLng(9.28, 36.38),
      LatLng(9.30, 36.75),
      LatLng(8.88, 36.72),
      LatLng(8.85, 36.35),
    ],
    compositeRisk: 0.58,
    riskLevel: 'MODERATE',
    pgaG: 0.04,
    soilLossTonsPerHa: 22.0,
    slopePercent: 14.5,
    spi3: 0.85,
    riverDischargeM3s: 145.0,
    nearestVolcanoDistKm: 190.0,
    nearestVolcanoName: 'Western Stable Craton',
    amharicAdvisory: 'ከፍተኛ የአፈር አሲዳማነት (pH 4.8) ስለተከሰተ በሄክታር 15 ኩንታል የእርሻ ኖራ (Lime) በመበተን አፈሩን ያክሙ።',
    oromoAdvisory: 'Koomiin biyyoo (Acidic pH 4.8) waan jiruuf nooraa qonnaa kuntaala 15/ha itti naqaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_arba_minch',
    woredaName: 'Arba Minch & Gofa (Southern Rift)',
    region: 'South Ethiopia',
    aez: 'Kolla / Weina Dega',
    elevation: 1285,
    centroid: LatLng(6.03, 37.55),
    polygon: [
      LatLng(6.28, 37.38),
      LatLng(6.30, 37.78),
      LatLng(5.78, 37.72),
      LatLng(5.75, 37.35),
    ],
    compositeRisk: 0.78,
    riskLevel: 'CRITICAL',
    pgaG: 0.12,
    soilLossTonsPerHa: 28.0,
    slopePercent: 22.0,
    spi3: 0.10,
    riverDischargeM3s: 180.0,
    nearestVolcanoDistKm: 65.0,
    nearestVolcanoName: 'Corbetti & Chamo Basin',
    amharicAdvisory: 'በጎፋና አርባ ምንጭ ተራራማ ተፋሰስ ከፍተኛ የመሬት መንሸራተት ስጋት አለ። የፍሳሽ ማስቀየሻ ቦዮችን ይክፈቱ።',
    oromoAdvisory: 'Sigiga lafaa tulluu Gofaa fi dhangala\'aa bishaanii to\'achuuf qophaa\'aa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_jijiga',
    woredaName: 'Jijiga (Somali Lowlands)',
    region: 'Somali',
    aez: 'Kolla / Pastoralist Lowland',
    elevation: 1609,
    centroid: LatLng(9.35, 42.80),
    polygon: [
      LatLng(9.58, 42.58),
      LatLng(9.60, 43.08),
      LatLng(9.12, 43.02),
      LatLng(9.10, 42.55),
    ],
    compositeRisk: 0.84,
    riskLevel: 'CRITICAL',
    pgaG: 0.05,
    soilLossTonsPerHa: 8.5,
    slopePercent: 3.5,
    spi3: -1.68,
    riverDischargeM3s: 35.0,
    nearestVolcanoDistKm: 140.0,
    nearestVolcanoName: 'Eastern Lowland Margin',
    amharicAdvisory: 'ከፍተኛ የድርቅና የአፈር እርጥበት እጥረት (SPI-3 -1.68)። የውሃ ጉድጓዶችንና የደረቁ እንስሳት መኖዎችን ያከፋፍሉ።',
    oromoAdvisory: 'Balaan hongee cimaan waan jiruuf bishaan fi nyaata horii dhiyeessaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_hawassa',
    woredaName: 'Hawassa & Shashemene (Sidama Rift)',
    region: 'Sidama',
    aez: 'Weina Dega',
    elevation: 1708,
    centroid: LatLng(7.05, 38.48),
    polygon: [
      LatLng(7.25, 38.32),
      LatLng(7.28, 38.68),
      LatLng(6.85, 38.62),
      LatLng(6.82, 38.30),
    ],
    compositeRisk: 0.62,
    riskLevel: 'HIGH',
    pgaG: 0.13,
    soilLossTonsPerHa: 14.2,
    slopePercent: 9.0,
    spi3: -0.15,
    riverDischargeM3s: 110.0,
    nearestVolcanoDistKm: 18.0,
    nearestVolcanoName: 'Corbetti Caldera',
    amharicAdvisory: 'የኮርቤቲ እሳተ-ገሞራና የስምጥ ሸለቆ ንዝረት ዞን። የሐይቁን የውሃ ከፍታና የመስኖ ግድቦችን ይከታተሉ።',
    oromoAdvisory: 'Sochii lafaa Qorbeetii fi ol-ka\'iinsa bishaan haroo Hawaasaa hordofaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_bahir_dar',
    woredaName: 'Bahir Dar (Lake Tana Basin)',
    region: 'Amhara',
    aez: 'Weina Dega (Lake Basin)',
    elevation: 1800,
    centroid: LatLng(11.59, 37.39),
    polygon: [
      LatLng(11.78, 37.22),
      LatLng(11.80, 37.58),
      LatLng(11.38, 37.55),
      LatLng(11.35, 37.20),
    ],
    compositeRisk: 0.45,
    riskLevel: 'MODERATE',
    pgaG: 0.06,
    soilLossTonsPerHa: 12.5,
    slopePercent: 6.0,
    spi3: 0.45,
    riverDischargeM3s: 290.0,
    nearestVolcanoDistKm: 120.0,
    nearestVolcanoName: 'South Tana Volcanic Field',
    amharicAdvisory: 'የጣና ተፋሰስና የዓባይ ወንዝ መነሻ። በዝናብ ወቅት የወንዝ ዳርቻ የጎርፍ መከላከያ ቦዮችን ያጽዱ።',
    oromoAdvisory: 'Lolaa Laga Abbayyaa ittisuuf sarara bishaanii qulqulleessaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_jimma',
    woredaName: 'Jimma (Southwestern Coffee Belt)',
    region: 'Oromia',
    aez: 'Weina Dega (Forest Agro-Forestry)',
    elevation: 1780,
    centroid: LatLng(7.67, 36.83),
    polygon: [
      LatLng(7.85, 36.65),
      LatLng(7.88, 37.05),
      LatLng(7.48, 37.02),
      LatLng(7.45, 36.62),
    ],
    compositeRisk: 0.52,
    riskLevel: 'MODERATE',
    pgaG: 0.05,
    soilLossTonsPerHa: 16.8,
    slopePercent: 12.0,
    spi3: 0.65,
    riverDischargeM3s: 130.0,
    nearestVolcanoDistKm: 160.0,
    nearestVolcanoName: 'Stable Volcanic Plateau',
    amharicAdvisory: 'ጥላ ዛፎችን ለቡና ተክሎች ማጠናከርና በዳገታማ መሬቶች ላይ የአፈር እርከን መስራት ያስፈልጋል።',
    oromoAdvisory: 'Gaaddisa muka bunaa fi daagaa lafa koobii eegaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_bale_robe',
    woredaName: 'Bale Robe (Highland Wheat Plateau)',
    region: 'Oromia',
    aez: 'Dega (High Altitude Plateau)',
    elevation: 2490,
    centroid: LatLng(7.12, 40.00),
    polygon: [
      LatLng(7.32, 39.80),
      LatLng(7.35, 40.22),
      LatLng(6.90, 40.18),
      LatLng(6.88, 39.78),
    ],
    compositeRisk: 0.48,
    riskLevel: 'LOW',
    pgaG: 0.06,
    soilLossTonsPerHa: 9.5,
    slopePercent: 7.5,
    spi3: 0.20,
    riverDischargeM3s: 70.0,
    nearestVolcanoDistKm: 95.0,
    nearestVolcanoName: 'Bale Volcanic Field',
    amharicAdvisory: 'የስንዴ ዝገት (Wheat Rust) በሽታ ቅኝት ማካሄድና የቅድመ-ማስጠንቀቂያ ፀረ-ፈንገስ መርጨት።',
    oromoAdvisory: 'Dhukkuba wawaa qamadii hordofaa fi qoricha farra fangasii qopheessaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_mekelle',
    woredaName: 'Mekelle (Northern Semiarid Basin)',
    region: 'Tigray',
    aez: 'Weina Dega / Kolla',
    elevation: 2084,
    centroid: LatLng(13.50, 39.47),
    polygon: [
      LatLng(13.68, 39.30),
      LatLng(13.70, 39.68),
      LatLng(13.30, 39.65),
      LatLng(13.28, 39.28),
    ],
    compositeRisk: 0.74,
    riskLevel: 'HIGH',
    pgaG: 0.08,
    soilLossTonsPerHa: 27.5,
    slopePercent: 11.4,
    spi3: -1.15,
    riverDischargeM3s: 40.0,
    nearestVolcanoDistKm: 80.0,
    nearestVolcanoName: 'Eastern Danakil Border',
    amharicAdvisory: 'የተፋሰስ ጥበቃ፣ የውሃ ማቆሪያ ግድቦችና ጥምር የደን-እርሻ (Agroforestry) ስራዎችን ያጠናክሩ።',
    oromoAdvisory: 'Bishaan kuusuu fi hojii qabeenya uumamaa jabeessaa.',
  ),
  const WoredaSpatialProfile(
    id: 'wor_gambella',
    woredaName: 'Gambella (Baro Flood Basin)',
    region: 'Gambella',
    aez: 'Bereha / Kolla (Alluvial Lowland)',
    elevation: 526,
    centroid: LatLng(8.25, 34.58),
    polygon: [
      LatLng(8.45, 34.38),
      LatLng(8.48, 34.80),
      LatLng(8.05, 34.78),
      LatLng(8.02, 34.35),
    ],
    compositeRisk: 0.82,
    riskLevel: 'CRITICAL',
    pgaG: 0.02,
    soilLossTonsPerHa: 4.1,
    slopePercent: 2.1,
    spi3: 0.95,
    riverDischargeM3s: 420.0,
    nearestVolcanoDistKm: 240.0,
    nearestVolcanoName: 'Western Inactive Basin',
    amharicAdvisory: 'የባሮ ወንዝ ሙላትና ድንገተኛ ጎርፍ ስጋት። የእንስሳትንና የሰብል ምርትን ወደ ደረቅ ከፍታ ቦታዎች ያሸጋግሩ።',
    oromoAdvisory: 'Lolaa Laga Baaroo ittisuuf beellada fi omisha gara bakka ol-ka\'aatti dabarsaa.',
  ),
];

/// Live Dynamic Spatial Risk Provider that connects to Backend Multi-Hazard Telemetry
final liveSpatialRiskProfilesProvider = FutureProvider<List<WoredaSpatialProfile>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final alertsAsync = ref.watch(alertsProvider);
  final List<AlertModel> activeAlerts = alertsAsync.asData?.value ?? [];

  final List<WoredaSpatialProfile> updatedProfiles = [];

  for (final baseline in defaultWoredaSpatialProfiles) {
    try {
      final response = await dioClient.get(
        ApiEndpoints.naturalDisasters,
        queryParameters: {
          'lat': baseline.centroid.latitude,
          'lng': baseline.centroid.longitude,
          'woredaName': baseline.woredaName,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = (response.data is Map && response.data['data'] != null)
            ? response.data['data'] as Map<String, dynamic>
            : (response.data as Map<String, dynamic>);

        final composite = (data['compositeIndex'] as num?)?.toDouble() ?? baseline.compositeRisk;
        final riskLevel = (data['compositeRiskLevel'] as String?) ?? baseline.riskLevel;

        final seismic = data['seismology'] as Map<String, dynamic>?;
        final pga = (seismic?['pgaG'] as num?)?.toDouble() ?? baseline.pgaG;

        final soil = data['soilDegradation'] as Map<String, dynamic>?;
        final soilLoss = (soil?['annualSoilLossTonsPerHa'] as num?)?.toDouble() ?? baseline.soilLossTonsPerHa;
        final slope = (soil?['slopePercent'] as num?)?.toDouble() ?? baseline.slopePercent;

        final drought = data['drought'] as Map<String, dynamic>?;
        final spi = (drought?['spi3'] as num?)?.toDouble() ?? baseline.spi3;

        final flood = data['flood'] as Map<String, dynamic>?;
        final flow = (flood?['dischargeM3s'] as num?)?.toDouble() ?? baseline.riverDischargeM3s;

        final advAm = (data['actionableAdvisoryAm'] as String?) ?? baseline.amharicAdvisory;
        final advOm = (data['actionableAdvisoryOm'] as String?) ?? baseline.oromoAdvisory;

        // Check if there are active alerts for this woreda
        final hasWoredaAlert = activeAlerts.any((a) => a.woredaId == baseline.id || (a.woreda?.name != null && a.woreda!.name.toLowerCase() == baseline.woredaName.toLowerCase()));
        final effectiveRisk = hasWoredaAlert ? (composite < 0.75 ? 0.85 : composite) : composite;
        final effectiveLevel = hasWoredaAlert ? 'CRITICAL' : riskLevel;

        updatedProfiles.add(WoredaSpatialProfile(
          id: baseline.id,
          woredaName: baseline.woredaName,
          region: baseline.region,
          aez: baseline.aez,
          elevation: baseline.elevation,
          centroid: baseline.centroid,
          polygon: baseline.polygon,
          compositeRisk: effectiveRisk,
          riskLevel: effectiveLevel,
          pgaG: pga,
          soilLossTonsPerHa: soilLoss,
          slopePercent: slope,
          spi3: spi,
          riverDischargeM3s: flow,
          nearestVolcanoDistKm: baseline.nearestVolcanoDistKm,
          nearestVolcanoName: baseline.nearestVolcanoName,
          amharicAdvisory: advAm,
          oromoAdvisory: advOm,
        ));
        continue;
      }
    } catch (_) {
      // Fallback to baseline on network error
    }

    updatedProfiles.add(baseline);
  }

  return updatedProfiles;
});
