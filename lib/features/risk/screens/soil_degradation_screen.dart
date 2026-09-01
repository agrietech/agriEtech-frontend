import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../../../core/widgets/risk_gauge_widget.dart';
import 'disaster_intelligence_screen.dart';


// Async provider for Live Soil Degradation & RUSLE
final soilDegradationDetailProvider = FutureProvider.family<Map<String, dynamic>, EthiopiaWoredaPreset>((ref, preset) async {
  final client = ref.watch(dioClientProvider);

  try {
    final response = await client.dio.get<Map<String, dynamic>>(
      ApiEndpoints.soilDegradation,
      queryParameters: {
        'lat': preset.lat,
        'lng': preset.lng,
        'woredaName': preset.name,
        'slopePct': preset.slope,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      final body = response.data!;
      return (body['data'] as Map<String, dynamic>?) ?? body;
    }
  } catch (_) {
    // Fallback if offline
  }

  return {
    'woredaName': preset.name,
    'topography': {
      'elevationMeters': preset.lat > 9.5 ? 2450 : 1850,
      'slopePercent': preset.slope,
      'topographicWetnessIndex': 6.8,
    },
    'rusleFactors': {
      'R_rainfallErosivity': 580,
      'K_soilErodibility': 0.026,
      'LS_slopeLengthSteepness': (preset.slope / 10).clamp(0.8, 8.5),
      'C_coverManagement': 0.35,
      'P_supportPractice': 1.0,
    },
    'erosionMetrics': {
      'annualSoilLossTonsPerHa': (preset.slope * 0.85).clamp(4.0, 48.0),
      'severityCategory': preset.slope > 18.0 ? 'HIGH' : 'MODERATE',
      'severityAm': preset.slope > 18.0 ? 'ከፍተኛ የመሬት መሸርሸር አደጋ' : 'መካከለኛ የመሸርሸር አደጋ',
      'tolerableSoilLossThresholdTonsPerHa': 10.0,
      'isExceedingTolerableLimit': preset.slope > 12.0,
    },
    'nutrientDepletion': {
      'annualSocLossKgPerHa': (preset.slope * 18.0).round(),
      'nitrogenLossKgPerHa': (preset.slope * 1.5).round(),
      'phosphorusLossKgPerHa': (preset.slope * 0.4).round(),
      'potassiumLossKgPerHa': (preset.slope * 0.9).round(),
    },
    'chemicalDegradation': {
      'type': preset.lat > 9.0 && preset.lng < 37.0 ? 'SEVERE_ACIDIFICATION' : 'BALANCED',
      'descriptionAm': preset.lat > 9.0 && preset.lng < 37.0 ? 'ከፍተኛ የአፈር አሲዳማነት (pH < 5.2) - ኖራ ያስፈልጋል' : 'መደበኛ ጤናማ አፈር',
      'dominantSoilType': preset.lat > 9.0 && preset.lng < 37.0 ? 'Dystric Nitisol (Acidic Red Soil)' : 'Vertisol / Luvisol',
    },
    'conservationInterventions': {
      'am': [
        'የእርከን ስራ (ፋንያ ጁ) እና የድንጋይ እርከን ማጠናከር፤ የውሃ ማስተንፈሻ ቦዮችን ማዘጋጀት።',
        'የቬቲቨር (Vetiver) ወይም የደሾ ሣር የመሸርሸር መከላከያ እርከን መትከል።',
        'በየሄክታሩ ከ12-18 ኩንታል የእርሻ ኖራ (Agricultural Lime) በመበተን የአፈር አሲዳማነትን ማከም።',
        'የግብርና-ደን ዛፎችን (እንደ ግራር/ግራቪሊያ) በሰብል ማሳዎች ውስጥ ደባልቆ መትከል።',
      ],
      'om': [
        'Daagaa Fanya Juu fi daagaa dhagaa hojjachuu; dhangala\'aa bishaanii to\'achuu.',
        'Muka daagaa fi Marga Vetiiveerii/Deeshoo sararaan dhaabuu.',
        'Noota qonnaa (lime) hektaaratti kuntaala 12-18 facaasuun asidummaa biyyee yaaluu.',
        'Mukkeen qonna-bosonaa (fkn. Laaftoo/Giraaviliyaa) maasii keessatti walmakuun dhaabuu.',
      ],
      'en': [
        'Construct Fanya Juu physical soil bunds, stone terraces, and drainage cutoff drains.',
        'Plant Vetiver or Desho grass vegetative hedgerows along contour lines.',
        'Apply 1.2 - 1.8 tons/ha agricultural lime to neutralize severe soil acidity.',
        'Implement agroforestry with Faidherbia albida and Sesbania in crop plots.',
      ],
    },
  };
});

class SoilDegradationScreen extends ConsumerStatefulWidget {
  const SoilDegradationScreen({super.key});

  @override
  ConsumerState<SoilDegradationScreen> createState() => _SoilDegradationScreenState();
}

class _SoilDegradationScreenState extends ConsumerState<SoilDegradationScreen> {
  EthiopiaWoredaPreset _selectedWoreda = woredaPresets[0];

  @override
  Widget build(BuildContext context) {
    final soilAsync = ref.watch(soilDegradationDetailProvider(_selectedWoreda));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Degradation & RUSLE Loss'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recalculate RUSLE Model',
            onPressed: () => ref.invalidate(soilDegradationDetailProvider(_selectedWoreda)),
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
                const Icon(Icons.terrain_rounded, color: Color(0xFF854D0E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EthiopiaWoredaPreset>(
                      isExpanded: true,
                      value: _selectedWoreda,
                      items: woredaPresets.map((preset) {
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

          // Main Content
          Expanded(
            child: soilAsync.when(
              data: (data) {
                final metrics = (data['erosionMetrics'] as Map<String, dynamic>?) ?? {};
                final rusle = (data['rusleFactors'] as Map<String, dynamic>?) ?? {};
                final nutrients = (data['nutrientDepletion'] as Map<String, dynamic>?) ?? {};
                final chemical = (data['chemicalDegradation'] as Map<String, dynamic>?) ?? {};
                final interventions = (data['conservationInterventions']?['am'] as List<dynamic>?) ?? [];
                final loss = (metrics['annualSoilLossTonsPerHa'] as num?)?.toDouble() ?? 14.5;
                final category = metrics['severityCategory'] as String? ?? 'MODERATE';

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // 1. Soil Loss Executive Gauge Badge
                    _buildSoilLossGaugeBadge(loss, category, metrics['severityAm'] ?? ''),
                    const SizedBox(height: AppSpacing.md),

                    // 2. RUSLE Equation Factor Decomposition (A = R * K * LS * C * P)
                    _buildRusleFactorCard(rusle),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Nutrient Leaching & SOC Loss Metrics
                    _buildNutrientDepletionCard(nutrients),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Soil Acidification & Salinization Diagnostics
                    _buildChemicalHealthCard(chemical),
                    const SizedBox(height: AppSpacing.md),

                    // 5. Actionable Engineering Prescriptions (Fanya Juu, Lime ኖራ)
                    _buildPrescriptionsCard(interventions),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: AppLoadingIndicator(
                  message: 'Computing RUSLE erosivity & SOC depletion model...',
                  color: Color(0xFF854D0E),
                ),
              ),
              error: (err, _) => AppErrorView(
                title: 'Soil Model Error',
                message: err.toString(),
                onRetry: () => ref.invalidate(soilDegradationDetailProvider(_selectedWoreda)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilLossGaugeBadge(double loss, String category, String amTitle) {
    final exceeds = loss > 10.0;
    final color = loss > 25.0 ? const Color(0xFFDC2626) : (loss > 10.0 ? const Color(0xFFEA580C) : const Color(0xFF16A34A));

    return AppSurfaceCard(
      glowColor: color,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.landscape_rounded, color: Color(0xFF854D0E), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'RUSLE SOIL LOSS INDEX',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedPill,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  category,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppRiskGauge(
            value: loss,
            maxValue: 50.0,
            label: 'RUSLE Loss',
            unit: 't / ha / yr',
            severityText: exceeds ? 'TOLERABLE LIMIT EXCEEDED' : 'SUSTAINABLE SOIL REGIME',
            severityColor: color,
            subMetrics: [
              'FAO Limit: 10.0 t/ha/yr',
              'Status: ${exceeds ? "High Erosion Stress" : "Stable Topsoil"}',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRusleFactorCard(Map<String, dynamic> rusle) {


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
                Icon(Icons.calculate_outlined, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'RUSLE Equation Decomposition (A = R × K × LS × C × P)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildFactorPill('R (Rainfall)', '${rusle['R_rainfallErosivity'] ?? 580}', Colors.blue)),
                const SizedBox(width: 6),
                Expanded(child: _buildFactorPill('K (Soil Text.)', '${rusle['K_soilErodibility'] ?? 0.026}', Colors.brown)),
                const SizedBox(width: 6),
                Expanded(child: _buildFactorPill('LS (Slope)', '${rusle['LS_slopeLengthSteepness'] ?? 2.4}', Colors.purple)),
                const SizedBox(width: 6),
                Expanded(child: _buildFactorPill('C (Cover)', '${rusle['C_coverManagement'] ?? 0.35}', Colors.green)),
                const SizedBox(width: 6),
                Expanded(child: _buildFactorPill('P (Support)', '${rusle['P_supportPractice'] ?? 1.0}', Colors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorPill(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 8, color: Colors.grey.shade700), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNutrientDepletionCard(Map<String, dynamic> nutrients) {
    final soc = nutrients['annualSocLossKgPerHa'] ?? 360;
    final n = nutrients['nitrogenLossKgPerHa'] ?? 28;
    final p = nutrients['phosphorusLossKgPerHa'] ?? 7;
    final k = nutrients['potassiumLossKgPerHa'] ?? 18;

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
                Icon(Icons.grain, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'Soil Organic Carbon (SOC) & Nutrient Leaching',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildNutrientTile('SOC Loss', '$soc kg/ha/yr', Colors.green.shade800)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientTile('Nitrogen (N)', '$n kg/ha', Colors.blue.shade800)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientTile('Phosphorus (P)', '$p kg/ha', Colors.amber.shade900)),
                const SizedBox(width: 8),
                Expanded(child: _buildNutrientTile('Potassium (K)', '$k kg/ha', Colors.purple.shade800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientTile(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildChemicalHealthCard(Map<String, dynamic> chemical) {
    final type = chemical['type'] ?? 'BALANCED';
    final desc = chemical['descriptionAm'] ?? 'መደበኛ ጤናማ አፈር';
    final soilType = chemical['dominantSoilType'] ?? 'Nitisol';

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
                    Icon(Icons.science_outlined, color: Colors.teal, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Chemical Degradation & Soil Classification',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: type == 'SEVERE_ACIDIFICATION' ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    type == 'SEVERE_ACIDIFICATION' ? 'Acidic pH < 5.2' : 'Optimal pH',
                    style: TextStyle(
                      color: type == 'SEVERE_ACIDIFICATION' ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Dominant Profile: $soilType', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(desc.toString(), style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionsCard(List<dynamic> interventions) {
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
                Icon(Icons.handyman_outlined, color: AppTheme.primaryColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'የአፈር ጥበቃና እርከን ስራዎች (Prescriptions)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...interventions.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(i.toString(), style: const TextStyle(fontSize: 12, height: 1.3))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
