import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class PestScoutScreen extends ConsumerStatefulWidget {
  const PestScoutScreen({super.key});

  @override
  ConsumerState<PestScoutScreen> createState() => _PestScoutScreenState();
}

class _PestScoutScreenState extends ConsumerState<PestScoutScreen> {
  final ImagePicker _picker = ImagePicker();

  String _selectedPestId = 'fall_armyworm';
  final String _selectedCrop = 'Maize';
  String _cropStage = 'midWhorl';
  double _damagePercent = 25.0;
  final int _totalSampled = 100;
  int _infestedCount = 25;
  Uint8List? _imageBytes;
  String? _imagePath;

  final List<String> _pests = const [
    'fall_armyworm',
    'african_armyworm',
    'desert_locust',
    'maize_stem_borer',
    'coffee_berry_borer',
  ];

  final Map<String, String> _pestLabels = const {
    'fall_armyworm': 'Fall Armyworm (ተምች)',
    'african_armyworm': 'African Armyworm (ጥቁር ተምች)',
    'desert_locust': 'Desert Locust (የበረሃ አንበጣ)',
    'maize_stem_borer': 'Maize Stem Borer (ግንድ ቆርጣጭ)',
    'coffee_berry_borer': 'Coffee Berry Borer (የቡና ነቀዝ)',
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imagePath = file.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _runScout() {
    String? base64Str;
    if (_imageBytes != null) {
      base64Str = base64Encode(_imageBytes!);
    }

    ref.read(pestScoutStateProvider.notifier).scout(
      imagePath: _imagePath,
      imageBase64: base64Str,
      pestId: _selectedPestId,
      cropType: _selectedCrop,
      cropStage: _cropStage,
      observedDamagePercent: _damagePercent,
      infestedPlantsCount: _infestedCount,
      totalSampledPlants: _totalSampled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pestState = ref.watch(pestScoutStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insect Pest Scout & ETL Advisor'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'What is ETL?',
            onPressed: () => _showEtlExplanationDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Photo Capture
            _buildPhotoCard(isDark),

            const SizedBox(height: 16),

            // 2. Field Scouting Sampling Card
            _buildScoutingInputsCard(isDark),

            const SizedBox(height: 16),

            // 3. Evaluate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  elevation: 2,
                ),
                onPressed: pestState.isLoading ? null : _runScout,
                icon: pestState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate_rounded),
                label: Text(
                  pestState.isLoading ? 'Evaluating Economic Threshold...' : 'Evaluate Economic Threshold (ETL)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (pestState.error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: AppRadii.roundedMd,
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Scouting error: ${pestState.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Results View
            if (pestState.result != null) ...[
              const SizedBox(height: 20),
              _buildResultView(pestState.result!, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report_rounded, color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Insect Pest / Crop Damage Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              if (_imageBytes != null)
                TextButton(
                  onPressed: () => setState(() {
                    _imageBytes = null;
                    _imagePath = null;
                  }),
                  child: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: AppRadii.roundedMd,
              child: Image.memory(
                _imageBytes!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: isDark ? const Color(0xFF4C1D1D) : const Color(0xFFFECACA),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 30, color: Color(0xFFDC2626)),
                  SizedBox(height: 6),
                  Text(
                    'Optional: Take photo of caterpillar or leaf damage',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_rounded, size: 16),
                  label: const Text('Camera', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 16),
                  label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoutingInputsCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field Sampling & Pest Parameters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // Pest Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedPestId,
            decoration: const InputDecoration(
              labelText: 'Target Pest Species',
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _pests.map((p) => DropdownMenuItem(value: p, child: Text(_pestLabels[p] ?? p))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedPestId = val);
            },
          ),
          const SizedBox(height: 12),

          // Crop Stage
          DropdownButtonFormField<String>(
            initialValue: _cropStage,
            decoration: const InputDecoration(
              labelText: 'Crop Growth Stage',
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(value: 'seedling', child: Text('Early Seedling / Young Whorl')),
              DropdownMenuItem(value: 'midWhorl', child: Text('Mid-Whorl / Vegetative')),
              DropdownMenuItem(value: 'tasseling', child: Text('Tasseling / Flowering / Boot')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _cropStage = val);
            },
          ),
          const SizedBox(height: 14),

          // Infested slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Observed Field Infestation:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                '${_damagePercent.toStringAsFixed(0)}% ($_infestedCount / $_totalSampled plants)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Slider(
            value: _damagePercent,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_damagePercent.toStringAsFixed(0)}%',
            activeColor: const Color(0xFFDC2626),
            onChanged: (val) {
              setState(() {
                _damagePercent = val;
                _infestedCount = (val / 100 * _totalSampled).round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(PestScoutResult result, bool isDark) {
    final etl = result.economicThresholdEvaluation;
    final rec = etl.recommendation;

    Color badgeColor;
    switch (rec.action) {
      case 'TREAT_IMMEDIATELY':
      case 'TREAT_NOW':
        badgeColor = const Color(0xFFDC2626);
        break;
      case 'MONITOR_CLOSELY':
        badgeColor = const Color(0xFFF59E0B);
        break;
      case 'NO_CHEMICAL_ACTION':
      default:
        badgeColor = const Color(0xFF16A34A);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ETL Decision Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: AppRadii.roundedLg,
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_outlined, color: badgeColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.action.replaceAll('_', ' '),
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Observed: ${etl.observedDamagePercent}%  |  Threshold: ${etl.thresholdPercent}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Text(
                rec.en,
                style: const TextStyle(fontSize: 12.5, height: 1.35),
              ),
              const SizedBox(height: 6),
              Text(
                rec.am,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // First-line Insecticides
        const Text(
          'Prescribed Chemical & Bio-rational Insecticides',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...etl.firstLinePesticides.map((pest) => _buildInsecticideCard(pest, isDark)),

        const SizedBox(height: 16),

        // Cultural & Biocontrol Alternatives
        const Text(
          'Agro-ecological & Cultural Controls',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...etl.culturalControls.map((cult) => _buildBiocontrolCard(cult, isDark)),
      ],
    );
  }

  Widget _buildInsecticideCard(PesticideModel p, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.tradeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFFDC2626)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  p.type.split(' ')[0],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Active: ${p.activeIngredient}', style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Row(
              children: [
                Expanded(child: Text('Rate: ${p.ratePerHa}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5))),
                Expanded(child: Text('16L Knapsack: ${p.ratePer16LKnapsack}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5))),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(p.timing, style: const TextStyle(fontSize: 11.5, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildBiocontrolCard(BiocontrolModel b, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_rounded, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  b.method,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(b.descriptionEn, style: const TextStyle(fontSize: 11.5, height: 1.3)),
          const SizedBox(height: 2),
          Text(b.descriptionAm, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))),
        ],
      ),
    );
  }

  void _showEtlExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Economic Threshold Level (ETL)'),
        content: const SingleChildScrollView(
          child: Text(
            'The Economic Threshold Level (ETL) is the pest population density at which management action must be taken to prevent reaching the Economic Injury Level (EIL) where financial loss exceeds the cost of chemical control.\n\n'
            '• Below ETL: Do NOT spray. Beneficial predatory insects (wasps, spiders, ladybirds) eat pests.\n'
            '• At or Above ETL: Spraying is financially justified to avoid devastating yield loss.\n\n'
            'Ethiopian Guidelines:\n'
            '• Fall Armyworm: 20% in young whorl, 40% in mid-whorl.\n'
            '• African Armyworm: 3-5 caterpillars per square meter.\n'
            '• Desert Locust: Any gregarious hopper band warrants emergency reporting.',
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
