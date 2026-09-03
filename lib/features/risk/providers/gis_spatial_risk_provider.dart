import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../alerts/models/alert_models.dart';
import '../../alerts/providers/alerts_provider.dart';
import '../../boundaries/providers/boundary_provider.dart';
import '../models/spatial_risk_model.dart';

/// Backward-compatible empty baseline (no hardcoded woredas)
const List<WoredaSpatialProfile> defaultWoredaSpatialProfiles = [];

/// Live Dynamic Spatial Risk Provider that connects to Backend Multi-Hazard Telemetry
final liveSpatialRiskProfilesProvider = FutureProvider<List<WoredaSpatialProfile>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final alertsAsync = ref.watch(alertsProvider);
  final List<AlertModel> activeAlerts = alertsAsync.asData?.value ?? [];
  final woredas = await ref.watch(allWoredasProvider.future);

  final List<WoredaSpatialProfile> updatedProfiles = [];

  for (final w in woredas) {
    try {
      final response = await dioClient.get(
        ApiEndpoints.naturalDisasters,
        queryParameters: {
          'lat': w.centerLat,
          'lng': w.centerLng,
          'woredaName': w.name,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = (response.data is Map && response.data['data'] != null)
            ? response.data['data'] as Map<String, dynamic>
            : (response.data as Map<String, dynamic>);

        final composite = (data['compositeDisasterIndex'] ?? data['compositeIndex'] as num?)?.toDouble() ?? 0.35;
        final riskLevel = (data['overallAlertLevel'] ?? data['compositeRiskLevel'] as String?) ?? 'MODERATE';

        final seismic = data['detailedPillars']?['seismology'] as Map<String, dynamic>? ??
            (data['seismology'] as Map<String, dynamic>?);
        final pga = (seismic?['seismicHazard']?['peakGroundAccelerationG'] ?? seismic?['pgaG'] as num?)?.toDouble() ?? 0.08;

        final soil = data['detailedPillars']?['soilDegradation'] as Map<String, dynamic>? ??
            (data['soilDegradation'] as Map<String, dynamic>?);
        final soilLoss = (soil?['erosionMetrics']?['annualSoilLossTonsPerHa'] ?? soil?['annualSoilLossTonsPerHa'] as num?)?.toDouble() ?? 12.0;
        final slope = (soil?['topography']?['slopePercent'] ?? soil?['slopePercent'] as num?)?.toDouble() ?? 8.0;

        final drought = data['detailedPillars']?['droughtClimate'] as Map<String, dynamic>? ??
            (data['drought'] as Map<String, dynamic>?);
        final spi = (drought?['spi3'] as num?)?.toDouble() ?? -0.2;

        final flood = data['detailedPillars']?['hydrologyFlood'] as Map<String, dynamic>? ??
            (data['flood'] as Map<String, dynamic>?);
        final floodScore = (flood?['score'] as num?)?.toDouble() ?? 0.2;
        final flow = (flood?['dischargeM3s'] as num?)?.toDouble() ?? ((floodScore * 350.0) + 50.0);

        final volcano = data['detailedPillars']?['volcanology'] as Map<String, dynamic>?;
        final volcanoDist = (volcano?['distanceKm'] as num?)?.toDouble() ?? 95.0;
        final volcanoName = (volcano?['nearestVolcano'] as String?) ?? 'Rift Volcanic Field';

        final advAm = (data['recommendedEmergencyActions']?['am'] ?? data['actionableAdvisoryAm'] as String?) ??
            'የተፈጥሮ አደጋ ክትትልና የመስኖ ጥበቃ ስራዎችን ያጠናክሩ።';
        final advOm = (data['recommendedEmergencyActions']?['om'] ?? data['actionableAdvisoryOm'] as String?) ??
            'Hordoffii balaa uumamaa fi eegumsa misooma qonnaa jabeessaa.';

        // Check if there are active alerts for this woreda
        final hasWoredaAlert = activeAlerts.any((a) =>
            a.woredaId == w.id ||
            (a.woreda?.name != null && a.woreda!.name.toLowerCase() == w.name.toLowerCase()));
        final effectiveRisk = hasWoredaAlert ? (composite < 0.75 ? 0.85 : composite) : composite;
        final effectiveLevel = hasWoredaAlert ? 'CRITICAL' : riskLevel;

        const dLat = 0.18;
        const dLng = 0.20;
        final polygon = [
          LatLng(w.centerLat + dLat, w.centerLng - dLng),
          LatLng(w.centerLat + dLat, w.centerLng + dLng),
          LatLng(w.centerLat - dLat, w.centerLng + dLng),
          LatLng(w.centerLat - dLat, w.centerLng - dLng),
        ];

        updatedProfiles.add(WoredaSpatialProfile(
          id: w.id,
          woredaName: w.name,
          region: w.zone?.region?.name ?? '',
          aez: 'Agricultural Zone',
          elevation: (flood?['elevationMeters'] as num?)?.toInt() ?? 1800,
          centroid: LatLng(w.centerLat, w.centerLng),
          polygon: polygon,
          compositeRisk: effectiveRisk,
          riskLevel: effectiveLevel,
          pgaG: pga,
          soilLossTonsPerHa: soilLoss,
          slopePercent: slope,
          spi3: spi,
          riverDischargeM3s: flow,
          nearestVolcanoDistKm: volcanoDist,
          nearestVolcanoName: volcanoName,
          amharicAdvisory: advAm,
          oromoAdvisory: advOm,
        ));
      }
    } catch (_) {
      // Gracefully skip failed woreda, avoiding fake placeholder data
    }
  }

  return updatedProfiles;
});
