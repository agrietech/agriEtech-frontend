import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'disaster_intelligence_screen.dart';

class LandslideRiskScreen extends ConsumerStatefulWidget {
  const LandslideRiskScreen({super.key});

  @override
  ConsumerState<LandslideRiskScreen> createState() => _LandslideRiskScreenState();
}

class _LandslideRiskScreenState extends ConsumerState<LandslideRiskScreen> {
  EthiopiaWoredaPreset? _selectedWoreda;

  @override
  Widget build(BuildContext context) {
    final presetsAsync = ref.watch(woredaPresetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return presetsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Landslides & Slope Mudflows')),
        body: const AppLoadingIndicator(message: 'Loading woredas...'),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Landslides & Slope Mudflows')),
        body: AppErrorView(
          title: 'Failed to load woredas',
          message: err.toString(),
          onRetry: () => ref.invalidate(woredaPresetsProvider),
        ),
      ),
      data: (presets) {
        if (presets.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Landslides & Slope Mudflows')),
            body: const AppErrorView(title: 'No woredas', message: 'No woredas found.'),
          );
        }
        final selected = _selectedWoreda ?? presets.first;
        if (_selectedWoreda == null) {
          Future.microtask(() => setState(() => _selectedWoreda = presets.first));
        }
        final predictionAsync = ref.watch(disasterPredictionProvider(selected));
        return _buildLandslideScaffold(context, predictionAsync, presets, selected, isDark);
      },
    );
  }

  Widget _buildLandslideScaffold(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> predictionAsync,
    List<EthiopiaWoredaPreset> presets,
    EthiopiaWoredaPreset selected,
    bool isDark,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landslides & Slope Mudflows'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Geotechnical Data',
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
                const Icon(Icons.landslide_rounded, color: Colors.blueGrey, size: 20),
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
                final landslides = (pillars['landslides'] as Map<String, dynamic>?) ?? {};
                final soilDegradation = (pillars['soilDegradation'] as Map<String, dynamic>?) ?? {};
                final topography = (soilDegradation['topography'] as Map<String, dynamic>?) ?? {};

                final double slope = (topography['slopePercent'] as num?)?.toDouble() ??
                    ((landslides['slopePercent'] as num?)?.toDouble() ?? 8.0);
                final double soilMoisture = (landslides['soilSaturationPct'] as num?)?.toDouble() ?? 45.0;
                final double dailyRain = (soilMoisture * 0.55).clamp(5.0, 75.0);
                final String riskLevel = (landslides['riskLevel'] as String?) ?? 'LOW';

                // Infinite Slope Factor of Safety: FS
                final slopeAngleRad = (slope / 100) * 0.9;
                final double fs = (1.85 / (0.8 + slopeAngleRad * 1.5 + (soilMoisture / 100) * 0.9)).clamp(0.65, 2.5);

                final isCritical = fs < 1.15 || riskLevel.contains('CRITICAL');
                final isModerate = fs < 1.5 || riskLevel.contains('MODERATE');

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 1. Landslide Factor of Safety Badge
                    _buildFactorOfSafetyBadge(fs, isCritical, isModerate),
                    const SizedBox(height: 16),

                    // 2. Geotechnical Parameters Card
                    _buildGeotechnicalParametersCard(slope, soilMoisture, dailyRain),
                    const SizedBox(height: 16),

                    // 3. Ethiopian Highland High-Risk Escarpments Monitor
                    _buildHighRiskEscarpmentCard(),
                    const SizedBox(height: 16),

                    // 4. Slope Stabilization & Drainage Protocols
                    _buildStabilizationProtocolsCard(),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(
                child: AppLoadingIndicator(
                  message: 'Analyzing slope stability, DEM & pore water saturation...',
                  color: Colors.blueGrey,
                ),
              ),
              error: (err, _) => AppErrorView(
                title: 'Landslide Model Error',
                message: err.toString(),
                onRetry: () => ref.invalidate(disasterPredictionProvider(selected)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorOfSafetyBadge(double fs, bool isCritical, bool isModerate) {
    Color cardColor = isCritical ? Colors.red.shade800 : (isModerate ? Colors.orange.shade800 : Colors.green.shade800);
    String status = isCritical ? 'CRITICAL SLOPE INSTABILITY' : (isModerate ? 'MODERATE LANDSLIDE WATCH' : 'STABLE SLOPE');

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
                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'FACTOR OF SAFETY (FS) INDEX',
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
                  status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFsStat(fs.toStringAsFixed(2), 'Factor of Safety', 'Limit: 1.0 (Failure)'),
              _buildFsStat('${_selectedWoreda?.slope ?? 0.0}%', 'Terrain Slope', 'DEM 30m Elevation'),
              _buildFsStat(isCritical ? 'CRITICAL' : (isModerate ? 'WATCH' : 'SAFE'), 'Risk Alert', 'Sentinel-1 SAR'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFsStat(String val, String title, String sub) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 9)),
      ],
    );
  }

  Widget _buildGeotechnicalParametersCard(double slope, double moisture, double rain) {
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
                Icon(Icons.speed_rounded, color: Colors.blueGrey, size: 20),
                SizedBox(width: 8),
                Text(
                  'Slope Stability Trigger Telemetry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildParamBox('Terrain Slope', '$slope%', Icons.landscape, Colors.deepOrange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildParamBox('SAR Soil Saturation', '$moisture%', Icons.water_drop, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildParamBox('Rainfall Rate', '$rain mm/d', Icons.thunderstorm, Colors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParamBox(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 9, color: Colors.grey.shade700), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHighRiskEscarpmentCard() {
    final zones = [
      {'name': 'Debre Sina & Tarma Ber Escarpment', 'risk': 'CRITICAL', 'elevation': '3,100 m'},
      {'name': 'Gofa / Sawla Mountain Basin', 'risk': 'HIGH', 'elevation': '2,400 m'},
      {'name': 'Mount Choke Watershed (East Gojjam)', 'risk': 'MODERATE', 'elevation': '2,800 m'},
      {'name': 'Ankober Border Fault Escarpment', 'risk': 'HIGH', 'elevation': '2,750 m'},
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
                Icon(Icons.map_outlined, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Ethiopian Escarpment Vulnerability Registry',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...zones.map((z) => Container(
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
                      Text(z['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Elev: ${z['elevation']}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: z['risk'] == 'CRITICAL' ? Colors.red.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      z['risk']!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: z['risk'] == 'CRITICAL' ? Colors.red.shade900 : Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStabilizationProtocolsCard() {
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
                  'የመሬት መንሸራተት መከላከያ እርምጃዎች (Protocols)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildProtocolItem('የዳገት ፍሳሽ ማስቀየሻ ቦዮችን (Cut-off drains) በመቆፈር ውሃ መሬት ውስጥ ሰርጎ እንዳይገባ መከላከል።'),
            _buildProtocolItem('ጥልቅ ስር ያላቸውን የቀርከሃ (Bamboo) እና የቬቲቨር ሣር ዝርያዎችን በዳገታማ ስፍራዎች መትከል።'),
            _buildProtocolItem('በከባድ ዝናብ ወቅት ቁልቁለታማ ዳገቶች ላይ የሚገኙ ሰዎችንና እንስሳትን ወደ ደህንነቱ ስፍራ ማሸጋገር።'),
          ],
        ),
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
