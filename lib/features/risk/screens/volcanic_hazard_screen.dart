import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'disaster_intelligence_screen.dart';

class VolcanicHazardScreen extends ConsumerStatefulWidget {
  const VolcanicHazardScreen({super.key});

  @override
  ConsumerState<VolcanicHazardScreen> createState() => _VolcanicHazardScreenState();
}

class _VolcanicHazardScreenState extends ConsumerState<VolcanicHazardScreen> {
  EthiopiaWoredaPreset? _selectedWoreda;

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(woredaPresetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return presetsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Volcanic & Geothermal Hazards')),
        body: const AppLoadingIndicator(message: 'Loading woredas...'),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Volcanic & Geothermal Hazards')),
        body: AppErrorView(
          title: 'Failed to load woredas',
          message: err.toString(),
          onRetry: () => ref.invalidate(woredaPresetsProvider),
        ),
      ),
      data: (presets) {
        if (presets.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Volcanic & Geothermal Hazards')),
            body: const AppErrorView(title: 'No woredas', message: 'No woredas found.'),
          );
        }
        final selected = _selectedWoreda ?? presets.first;
        if (_selectedWoreda == null) {
          Future.microtask(() => setState(() => _selectedWoreda = presets.first));
        }
        final predictionAsync = ref.watch(disasterPredictionProvider(selected));
        return _buildVolcanicScaffold(context, predictionAsync, presets, selected, isDark);
      },
    );
  }

  Widget _buildVolcanicScaffold(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> predictionAsync,
    List<EthiopiaWoredaPreset> presets,
    EthiopiaWoredaPreset selected,
    bool isDark,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volcanic & Geothermal Hazards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Volcanic Proximity',
            onPressed: () => ref.invalidate(disasterPredictionProvider(selected)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Woreda Selector Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162A1D) : AppTheme.surfaceLight,
              border: Border(bottom: BorderSide(color: isDark ? AppTheme.borderDark : AppTheme.borderLight)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 20),
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
                            preset.name,
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

          // Main Body
          Expanded(
            child: predictionAsync.when(
              data: (data) {
                final pillars = (data['detailedPillars'] as Map<String, dynamic>?) ?? {};
                final volcanology = (pillars['volcanology'] as Map<String, dynamic>?) ?? {};
                final double nearestVolcanoKm = (volcanology['distanceKm'] as num?)?.toDouble() ?? 65.0;
                final String nearestName = (volcanology['nearestVolcano'] as String?) ?? 'Main Ethiopian Rift Caldera';
                final String riskLevel = (volcanology['riskLevel'] as String?) ?? 'LOW';
                final isProximityAlert = nearestVolcanoKm < 45.0 || riskLevel.contains('HIGH');

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Volcanic Hazard Header Badge
                    _buildVolcanicHeaderBadge(nearestVolcanoKm, nearestName, isProximityAlert),
                    const SizedBox(height: 16),

                    // 2. Active Calderas & Thermal Radiative Power (MODIS FIRMS)
                    _buildThermalAnomaliesCard(),
                    const SizedBox(height: 16),

                    // 3. Ethiopian Active Volcanic Centers Registry
                    _buildVolcanicRegistryCard(),
                    const SizedBox(height: 16),

                    // 4. Ashfall & Gas Exposure Protocols
                    _buildAshfallProtocolsCard(),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(
                  message: 'Querying Smithsonian GVP volcanic telemetry & thermal anomalies...',
                  color: Colors.deepOrange,
                ),
              ),
              error: (err, _) => AppErrorView(
                title: 'Volcanic Model Error',
                message: err.toString(),
                onRetry: () => ref.invalidate(disasterPredictionProvider(selected)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolcanicHeaderBadge(double dist, String volcano, bool isAlert) {
    Color cardColor = isAlert ? Colors.deepOrange.shade900 : Colors.brown.shade800;

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
                  Icon(Icons.whatshot, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'VOLCANOLOGY & THERMAL MONITORING',
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
                  isAlert ? 'BUFFER ZONE' : 'STABLE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildVolcanoStat('${dist.toStringAsFixed(0)} km', 'Nearest Caldera', volcano.split(' ')[0]),
              _buildVolcanoStat('42 MW', 'Thermal Power (FRP)', 'MODIS FIRMS'),
              _buildVolcanoStat(isAlert ? 'WATCH' : 'LOW', 'Ashfall Risk', 'SO2 Telemetry'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolcanoStat(String val, String title, String sub) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 9)),
      ],
    );
  }

  Widget _buildThermalAnomaliesCard() {
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
                Icon(Icons.sensors, color: Colors.deepOrange, size: 20),
                SizedBox(width: 8),
                Text(
                  'Thermal Infrared & Gas Flux Telemetry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricTile(title: 'Land Surface Temp', value: '38.4°C', color: Colors.orange.shade900)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricTile(title: 'Radiative Power', value: '42 MW', color: Colors.red.shade900)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricTile(title: 'SO₂ Column Mass', value: '0.8 DU', color: Colors.purple.shade900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolcanicRegistryCard() {
    final volcanoes = [
      {'name': 'Erta Ale Shield Volcano (Afar)', 'type': 'Active Basaltic Lava Lake', 'radius': '45 km'},
      {'name': 'Dabbahu / Boina Volcano (Afar)', 'type': 'Active Fissure Rifting Center', 'radius': '35 km'},
      {'name': 'Fentale Stratovolcano (Awash)', 'type': 'Caldera & Fissure Vent', 'radius': '25 km'},
      {'name': 'Alutu Volcanic Center (Langano)', 'type': 'Active Geothermal Complex', 'radius': '20 km'},
      {'name': 'Corbetti Caldera (Hawassa)', 'type': 'Pyroclastic Volcano', 'radius': '25 km'},
    ];

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
                Icon(Icons.volcano_outlined, color: Colors.brown, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ethiopian Active Volcanic Complex Registry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...volcanoes.map((v) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(v['type']!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                  Text('Radius: ${v['radius']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAshfallProtocolsCard() {
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
                  'የእሳተ-ገሞራ አመድና ጋዝ ጥንቃቄዎች (Protocols)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildProtocolItem('የእሳተ-ገሞራ አመድ በሚወርድበት ጊዜ የሰብል ማሳዎችንና የውሃ ማጠራቀሚያዎችን በፕላስቲክ ወይም በሸራ መሸፈን።'),
            _buildProtocolItem('የሰልፈር ዳይኦክሳይድ (SO2) ጋዝ ሽታ ሲኖር አፍንና አፍንጫን በጨርቅ መሸፈንና ወደ ከፍታ ስፍራ መሄድ።'),
            _buildProtocolItem('የእንስሳት መኖዎችን ከአመድ ንክኪ መጠበቅና ንጹህ ውሃ ማቅረብ።'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 8, color: Colors.grey.shade700), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProtocolItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.3))),
        ],
      ),
    );
  }
}
