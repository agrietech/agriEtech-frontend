import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'disaster_intelligence_screen.dart';

// Async provider for Live USGS Seismology
final seismologyDetailProvider = FutureProvider.family<Map<String, dynamic>, EthiopiaWoredaPreset>((ref, preset) async {
  final client = ref.watch(dioClientProvider);

  final response = await client.dio.get<Map<String, dynamic>>(
    ApiEndpoints.seismology,
    queryParameters: {
      'lat': preset.lat,
      'lng': preset.lng,
      'woredaName': preset.name,
    },
  );

  if (response.statusCode == 200 && response.data != null) {
    final body = response.data!;
    return (body['data'] as Map<String, dynamic>?) ?? body;
  }
  throw Exception('Failed to fetch seismology data for ${preset.name}');
});

class SeismologyDetailScreen extends ConsumerStatefulWidget {
  const SeismologyDetailScreen({super.key});

  @override
  ConsumerState<SeismologyDetailScreen> createState() => _SeismologyDetailScreenState();
}

class _SeismologyDetailScreenState extends ConsumerState<SeismologyDetailScreen> {
  EthiopiaWoredaPreset? _selectedWoreda;

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(woredaPresetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return presetsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Seismology & Rift Tectonics')),
        body: const AppLoadingIndicator(message: 'Loading woredas...'),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Seismology & Rift Tectonics')),
        body: AppErrorView(title: 'Failed to load woredas', message: err.toString(), onRetry: () => ref.invalidate(woredaPresetsProvider)),
      ),
      data: (presets) {
        if (presets.isEmpty) {
          return Scaffold(appBar: AppBar(title: const Text('Seismology & Rift Tectonics')), body: const AppErrorView(title: 'No woredas', message: 'No woredas found.'));
        }
        final selected = _selectedWoreda ?? presets.first;
        if (_selectedWoreda == null) Future.microtask(() => setState(() => _selectedWoreda = presets.first));
        final seismicAsync = ref.watch(seismologyDetailProvider(selected));
        return _buildSeismologyBody(context, seismicAsync, presets, selected, isDark);
      },
    );
  }

  Widget _buildSeismologyBody(BuildContext context, AsyncValue<Map<String, dynamic>> seismicAsync, List<EthiopiaWoredaPreset> presets, EthiopiaWoredaPreset selected, bool isDark) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seismology & Rift Tectonics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Seismic Telemetry',
            onPressed: () => ref.invalidate(seismologyDetailProvider(selected)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Woreda Selector Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1A) : const Color(0xFFFFF7ED),
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepOrange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EthiopiaWoredaPreset>(
                      isExpanded: true,
                      value: selected,
                      items: presets.map((preset) {
                        return DropdownMenuItem<EthiopiaWoredaPreset>(
                          value: preset,
                          child: Text(
                            '${preset.name} (${preset.region})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedWoreda = val);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: seismicAsync.when(
              data: (data) {
                final hazard = data['locationRisk']?['seismicHazard'] as Map<String, dynamic>? ?? {};
                final fault = data['locationRisk']?['nearestFaultSystem'] as Map<String, dynamic>? ?? {};
                final advisories = (data['infrastructureAdvisories'] as List<dynamic>?) ?? [];
                final recentQuakes = (data['recentEarthquakesFeed'] as List<dynamic>?) ?? [];

                final pga = (hazard['peakGroundAcceleration_g'] as num?)?.toDouble() ?? 0.28;
                final mmi = hazard['mercalliIntensityExpected'] as String? ?? 'VII';
                final prob30 = (hazard['thirtyYearEarthquakeProbM5Plus'] as num?)?.toDouble() ?? 78.5;
                final riskLevel = hazard['compositeRiskLevel'] as String? ?? 'HIGH_SEISMIC_ZONE';

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // 1. Tectonic PGA Risk Header Card
                    _buildSeismicHeaderCard(pga, mmi, prob30, riskLevel),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Active Fault Architecture & Ground Motion Breakdown
                    _buildFaultProximityCard(fault),

                    const SizedBox(height: AppSpacing.md),

                    // 3. Infrastructure & Irrigation Safety
                    _buildInfrastructureAdvisoryCard(advisories),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Live USGS Recent Earthquakes Feed
                    _buildRecentEarthquakesList(recentQuakes),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(
                  message: 'Fetching live USGS Horn of Africa seismic telemetry...',
                  color: Colors.deepOrange,
                ),
              ),
              error: (err, _) => AppErrorView(
                title: 'Seismic Telemetry Error',
                message: err.toString(),
                onRetry: () => ref.invalidate(seismologyDetailProvider(selected)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeismicHeaderCard(double pga, String mmi, double prob30, String riskLevel) {
    Color cardColor = riskLevel.contains('CRITICAL') || riskLevel.contains('HIGH')
        ? Colors.deepOrange.shade800
        : Colors.teal.shade800;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sensors, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'GROUND MOTION & PGA ACCELERATION',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  riskLevel,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderKpi('Peak Acceleration', '${pga}g', 'Joyner-Boore GMPE'),
              _buildHeaderKpi('MMI Shaking', mmi.split(' ')[0], 'Wald scale'),
              _buildHeaderKpi('30-Day Prob. (M≥4.5)', '${(prob30 * 100).toStringAsFixed(0)}%', 'Gutenberg-Richter'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderKpi(String label, String value, String sub) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9)),
      ],
    );
  }

  Widget _buildFaultProximityCard(Map<String, dynamic> fault) {
    final name = fault['name'] ?? 'Wonji Fault Belt';
    final distanceKm = fault['distanceKm'] ?? 14.2;
    final slipRate = fault['annualSlipRateMm'] ?? 5.5;
    final maxMag = fault['historicalMaxMagnitude'] ?? 6.5;
    final type = fault['faultType'] ?? 'Continental Extensional Rifting';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.architecture, color: Colors.indigo, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tectonic Fault Line Architecture',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('Mechanism: $type', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoBox('Axis Distance', '$distanceKm km', Colors.deepOrange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoBox('Annual Slip Rate', '$slipRate mm/yr', Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoBox('Max Historical M', 'M$maxMag', Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfrastructureAdvisoryCard(List<dynamic> advisories) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'የመስኖና የግብርና መዋቅሮች ጥንቃቄ (Advisories)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...advisories.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(a.toString(), style: const TextStyle(fontSize: 12, height: 1.3))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEarthquakesList(List<dynamic> quakes) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.blueGrey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Recent Horn of Africa Earthquakes (USGS)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Text('${quakes.length} Events', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 12),
            ...quakes.map((q) {
              final qu = q as Map<String, dynamic>;
              final num mag = (qu['magnitude'] as num?) ?? 4.0;
              final place = qu['place'] ?? 'Ethiopia';
              final depth = qu['depthKm'] ?? 10.0;
              final felt = qu['feltReports'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mag >= 4.5 ? Colors.red.shade100 : Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'M$mag',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: mag >= 4.5 ? Colors.red.shade900 : Colors.amber.shade900,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Depth: $depth km • Felt Reports: $felt', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
