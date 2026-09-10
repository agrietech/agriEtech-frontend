import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class SeedCalculatorScreen extends ConsumerStatefulWidget {
  const SeedCalculatorScreen({super.key});

  @override
  ConsumerState<SeedCalculatorScreen> createState() => _SeedCalculatorScreenState();
}

class _SeedCalculatorScreenState extends ConsumerState<SeedCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController(text: '1.0');

  String _selectedCropId = 'teff';
  String _areaUnit = 'HECTARES';
  String _plantingMethod = 'ROW';

  final List<({String id, String nameEn, String nameAm})> _crops = const [
    (id: 'teff', nameEn: 'Teff (Eragrostis tef)', nameAm: 'ጤፍ'),
    (id: 'wheat', nameEn: 'Bread Wheat', nameAm: 'ስንዴ'),
    (id: 'maize', nameEn: 'Maize / Corn', nameAm: 'በቆሎ'),
    (id: 'barley', nameEn: 'Barley', nameAm: 'ገብስ'),
    (id: 'sorghum', nameEn: 'Sorghum', nameAm: 'ማሽላ'),
    (id: 'faba_bean', nameEn: 'Faba Bean', nameAm: 'ባቄላ'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runCalculation();
    });
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _runCalculation() {
    final area = double.tryParse(_areaController.text) ?? 1.0;
    ref.read(seedCalculatorStateProvider.notifier).calculate(
      cropId: _selectedCropId,
      areaValue: area,
      areaUnit: _areaUnit,
      plantingMethod: _plantingMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calcState = ref.watch(seedCalculatorStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed & Plant Spacing Calculator'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Calculator Inputs Card
            _buildInputsCard(isDark),

            const SizedBox(height: 16),

            // 2. Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                ),
                onPressed: calcState.isLoading ? null : _runCalculation,
                icon: calcState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate_rounded),
                label: const Text(
                  'Calculate Seed & Fertilizer Requirements',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (calcState.error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Text('Calculation error: ${calcState.error}', style: const TextStyle(color: Colors.red)),
              ),
            ],

            // 3. Output Results
            if (calcState.result != null) ...[
              const SizedBox(height: 20),
              _buildResultsView(calcState.result!, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputsCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop & Land Specifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // Crop Selector
          DropdownButtonFormField<String>(
            initialValue: _selectedCropId,
            decoration: const InputDecoration(
              labelText: 'Select Crop',
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _crops.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text('${c.nameEn} (${c.nameAm})'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedCropId = val);
                _runCalculation();
              }
            },
          ),
          const SizedBox(height: 14),

          // Area & Unit
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Plot Area',
                    border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onFieldSubmitted: (_) => _runCalculation(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  initialValue: _areaUnit,
                  decoration: const InputDecoration(
                    labelText: 'Area Unit',
                    border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'HECTARES', child: Text('Hectares (ሄክታር)')),
                    DropdownMenuItem(value: 'TIMAD', child: Text('Timad (ጭማድ - ¼ ha)')),
                    DropdownMenuItem(value: 'SQM', child: Text('Square Meters (m²)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _areaUnit = val);
                      _runCalculation();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Planting Method (Row vs Broadcast)
          const Text('Planting Technique', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Row Planting (ረድፍ)'),
                  selected: _plantingMethod == 'ROW',
                  onSelected: (sel) {
                    if (sel) {
                      setState(() => _plantingMethod = 'ROW');
                      _runCalculation();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Broadcasting (መበተን)'),
                  selected: _plantingMethod == 'BROADCAST',
                  onSelected: (sel) {
                    if (sel) {
                      setState(() => _plantingMethod = 'BROADCAST');
                      _runCalculation();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(SeedCalculationResult res, bool isDark) {
    final seed = res.seedPlan;
    final fert = res.fertilizerPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seed Requirement Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
            ),
            borderRadius: AppRadii.roundedLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.grain_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    '${res.crop.cropNameEn} Seed Requirement',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildStatCard('Total Seed', '${seed.totalSeedRequiredKg} kg', Icons.scale_rounded),
                  _buildStatCard('50kg Bags', '${seed.bags50kg} bags', Icons.shopping_bag_outlined),
                  _buildStatCard('Effective Area', '${res.hectaresEquivalent} ha', Icons.square_foot_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Text(
                  'Recommended Certified Varieties: ${res.crop.recommendedVarieties.join(', ')}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Planting Geometry & Population
        AppSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.grid_4x4_rounded, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Planting Geometry & Population Target',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (seed.rowSpacingCm != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailTile('Inter-Row Spacing', '${seed.rowSpacingCm} cm'),
                    ),
                    Expanded(
                      child: _buildDetailTile('Intra-Row Spacing', '${seed.plantSpacingCm} cm'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildDetailTile('Seeding Depth', seed.plantingDepth),
                  ),
                  if (seed.estimatedTotalPlants != null)
                    Expanded(
                      child: _buildDetailTile('Est. Plant Population', '${seed.estimatedTotalPlants} plants'),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Fertilizer Nutrition Plan
        AppSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.compost_rounded, color: Color(0xFF15803D), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Basal & Top-Dress Fertilizer Plan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Basal NPSB
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162A1D) : const Color(0xFFF0FDF4),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Basal NPSB at Planting:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${fert.basalNpsb.totalRequiredKg} kg (${fert.basalNpsb.bags50kg} bags)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(fert.basalNpsb.timingEn, style: const TextStyle(fontSize: 11.5)),
                    Text(fert.basalNpsb.timingAm, style: const TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Top-dress Urea
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Top-Dress Urea (46% N):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${fert.topDressUrea.totalRequiredKg} kg (${fert.topDressUrea.bags50kg} bags)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(fert.topDressUrea.timingEn, style: const TextStyle(fontSize: 11.5)),
                    Text(fert.topDressUrea.timingAm, style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Agronomic Instructions
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132419) : const Color(0xFFF4F9F4),
            borderRadius: AppRadii.roundedMd,
            border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📅 Sowing Window: ${res.plantingWindowEn}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              const SizedBox(height: 4),
              Text(
                'የመዝሪያ ወቅት፡ ${res.plantingWindowAm}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF15803D)),
              ),
              const SizedBox(height: 8),
              Text(
                res.specialInstructionsEn,
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
              const SizedBox(height: 4),
              Text(
                res.specialInstructionsAm,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF15803D), height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: AppRadii.roundedMd,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: AppRadii.roundedMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
