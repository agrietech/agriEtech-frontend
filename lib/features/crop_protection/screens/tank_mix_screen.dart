import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class TankMixScreen extends ConsumerStatefulWidget {
  const TankMixScreen({super.key});

  @override
  ConsumerState<TankMixScreen> createState() => _TankMixScreenState();
}

class _TankMixScreenState extends ConsumerState<TankMixScreen> {
  final List<String> _selectedProductIds = ['2_4_d_amine', 'copper_hydroxide_wp'];
  double _waterVolume = 16.0;

  final List<({String id, String name, String type})> _commonChemicals = const [
    (id: '2_4_d_amine', name: '2,4-D Amine 720 SL', type: 'Herbicide (SL)'),
    (id: 'copper_hydroxide_wp', name: 'Kocide / Copper Hydroxide WP', type: 'Fungicide (WP)'),
    (id: 'palace_75_wg', name: 'Palace 75 WG', type: 'Herbicide (WG)'),
    (id: 'pallas_45_od', name: 'Pallas 45 OD', type: 'Herbicide (OD)'),
    (id: 'topic_080_ec', name: 'Topic 080 EC', type: 'Herbicide (EC)'),
    (id: 'tilt_250_ec', name: 'Tilt 250 EC', type: 'Fungicide (EC)'),
    (id: 'mancozeb_80_wp', name: 'Mancozeb 80% WP', type: 'Fungicide (WP)'),
    (id: 'ampligo_150_zc', name: 'Ampligo 150 ZC', type: 'Insecticide (SC)'),
    (id: 'karate_5_ec', name: 'Karate 5 EC', type: 'Insecticide (EC)'),
    (id: 'dimethoate_40_ec', name: 'Dimethoate 40% EC', type: 'Insecticide (EC)'),
    (id: 'urea_foliar', name: 'Foliar Urea Solution', type: 'Nutrient (Foliar)'),
    (id: 'zinc_sulfate', name: 'Zinc Sulfate (ZnSO4)', type: 'Nutrient (Foliar)'),
    (id: 'calcium_nitrate', name: 'Calcium Nitrate', type: 'Nutrient (Foliar)'),
    (id: 'monoammonium_phosphate', name: 'Monoammonium Phosphate (MAP)', type: 'Nutrient (Foliar)'),
  ];

  @override
  void initState() {
    super.initState();
    // Validate default mix on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runValidation();
    });
  }

  void _runValidation() {
    ref.read(tankMixStateProvider.notifier).validate(
      productIds: _selectedProductIds,
      waterVolumeLiters: _waterVolume,
    );
  }

  void _toggleProduct(String id) {
    setState(() {
      if (_selectedProductIds.contains(id)) {
        _selectedProductIds.remove(id);
      } else {
        _selectedProductIds.add(id);
      }
    });
    _runValidation();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tankState = ref.watch(tankMixStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tank-Mix & Compatibility Validator'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'W-A-L-E-S Rules',
            onPressed: () => _showWalesRuleDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector Card
            _buildProductSelectionCard(isDark),

            const SizedBox(height: 16),

            // 2. Tank Volume Picker
            _buildVolumeSelector(isDark),

            const SizedBox(height: 16),

            // 3. Validation Status & Loading
            if (tankState.isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ))
            else if (tankState.result != null)
              _buildValidationResult(tankState.result!, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelectionCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, color: Color(0xFF9333EA), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Select Chemicals to Tank-Mix',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Text(
                '${_selectedProductIds.length} selected',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF9333EA)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonChemicals.map((chem) {
              final isSelected = _selectedProductIds.contains(chem.id);
              return FilterChip(
                selected: isSelected,
                label: Text(chem.name, style: const TextStyle(fontSize: 12)),
                selectedColor: const Color(0xFF9333EA).withValues(alpha: 0.18),
                checkmarkColor: const Color(0xFF9333EA),
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  _toggleProduct(chem.id);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSelector(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 10),
          const Text('Sprayer Volume:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const Spacer(),
          ...[16.0, 50.0, 100.0, 200.0].map((v) {
            final isSel = _waterVolume == v;
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text('${v.toInt()}L', style: const TextStyle(fontSize: 11)),
                selected: isSel,
                onSelected: (s) {
                  if (s) {
                    setState(() => _waterVolume = v);
                    _runValidation();
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildValidationResult(TankMixValidationResult result, bool isDark) {
    Color bannerColor;
    String statusTitle;
    String statusAmharic;
    IconData statusIcon;

    switch (result.riskLevel) {
      case 'SAFE':
      case 'SAFE_SINGLE_PRODUCT':
      case 'COMPATIBLE_WITH_W_A_L_E_S':
        bannerColor = const Color(0xFF16A34A);
        statusTitle = 'COMPATIBLE (SAFE TO MIX)';
        statusAmharic = 'ተኳሃኝ ናቸው (በአንድ ላይ ማቀላቀል ይቻላል)';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'CAUTION':
      case 'ACCEPTABLE_WITH_WATER_CONDITIONER':
        bannerColor = const Color(0xFFF59E0B);
        statusTitle = 'CAUTION: CONDITIONAL MIX';
        statusAmharic = 'ጥንቃቄ፡ በጥንቃቄና በቅድመ-ሁኔታ የሚደባለቅ';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'INCOMPATIBLE':
      default:
        bannerColor = const Color(0xFFDC2626);
        statusTitle = 'INCOMPATIBLE (DO NOT MIX!)';
        statusAmharic = 'አይጣጣሙም! (በአንድ ታንክ በፍጹም አይቀላቅሉ)';
        statusIcon = Icons.cancel_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bannerColor.withValues(alpha: 0.12),
            borderRadius: AppRadii.roundedLg,
            border: Border.all(color: bannerColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: bannerColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: bannerColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      statusAmharic,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Conflicts List
        if (result.conflicts.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Identified Chemical Incompatibilities',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
          ),
          const SizedBox(height: 8),
          ...result.conflicts.map((conf) => _buildConflictCard(conf, isDark)),
        ],

        const SizedBox(height: 16),

        // W-A-L-E-S Mixing Sequence
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF9333EA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sequential W-A-L-E-S Tank Filling Order',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...result.mixingSequence.map((step) => _buildMixingStepItem(step, isDark)),

        // 500 mL Jar Test Protocol
        if (result.jarTestProcedure != null) ...[
          const SizedBox(height: 16),
          _buildJarTestCard(result.jarTestProcedure!, isDark),
        ],
      ],
    );
  }

  Widget _buildConflictCard(ConflictModel conf, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${conf.productA}  ⚡  ${conf.productB}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(conf.issueEn, style: const TextStyle(fontSize: 12, height: 1.35)),
          const SizedBox(height: 4),
          Text(conf.issueAm, style: const TextStyle(fontSize: 11.5, color: Color(0xFFDC2626))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Text(
              'Recommended Action: ${conf.actionEn}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixingStepItem(MixingStepModel step, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF9333EA).withValues(alpha: 0.15),
            child: Text(
              '${step.stepNumber}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.titleEn, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(step.detailEn, style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF475569))),
                const SizedBox(height: 2),
                Text(step.detailAm, style: const TextStyle(fontSize: 11, color: Color(0xFF15803D))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJarTestCard(JarTestModel jar, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2A20) : const Color(0xFFF0FDF4),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.biotech_rounded, color: AppTheme.primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'Pre-Mix Validation: 500 mL Jar Test Protocol',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...jar.instructionsEn.map((inst) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(inst, style: const TextStyle(fontSize: 12, height: 1.3))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showWalesRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('The W-A-L-E-S Mixing Order'),
        content: const SingleChildScrollView(
          child: Text(
            'To prevent curdling, sludge, and nozzle blockages, always add agricultural products into the sprayer tank in this universal sequence:\n\n'
            '1. W - Wettable Powders (WP) and Dry Granules (WDG/WG)\n'
            '2. A - Agitate thoroughly to fully disperse solids\n'
            '3. L - Liquid Flowables and Suspension Concentrates (SC, OD)\n'
            '4. E - Emulsifiable Concentrates (EC)\n'
            '5. S - Soluble Liquids (SL), Foliar Fertilizers & Adjuvants\n\n'
            'Crucial Warning: Never mix Copper fungicides with 2,4-D amine or Calcium nitrate with Phosphates in the same tank.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
