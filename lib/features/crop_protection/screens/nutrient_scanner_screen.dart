import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class NutrientScannerScreen extends ConsumerStatefulWidget {
  const NutrientScannerScreen({super.key});

  @override
  ConsumerState<NutrientScannerScreen> createState() => _NutrientScannerScreenState();
}

class _NutrientScannerScreenState extends ConsumerState<NutrientScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  String _selectedCrop = 'Maize';
  String _leafPosition = 'older';
  String _symptomPattern = 'v_shaped';
  double _soilPh = 6.5;
  Uint8List? _imageBytes;
  String? _imagePath;

  final List<String> _crops = const [
    'Maize',
    'Wheat',
    'Teff',
    'Barley',
    'Sorghum',
    'Faba Bean',
    'Coffee',
  ];

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

  void _runScan() {
    String? base64Str;
    if (_imageBytes != null) {
      base64Str = base64Encode(_imageBytes!);
    }

    ref.read(nutrientScannerStateProvider.notifier).scan(
      imagePath: _imagePath,
      imageBase64: base64Str,
      cropType: _selectedCrop,
      leafPosition: _leafPosition,
      pattern: _symptomPattern,
      soilPh: _soilPh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scanState = ref.watch(nutrientScannerStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrient Deficiency Scanner'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_rounded),
            tooltip: 'Deficiencies Guide',
            onPressed: () => _showNutrientGuide(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Photo Capture Card
            _buildPhotoCard(isDark),

            const SizedBox(height: 16),

            // 2. Symptom & Soil Selectors
            _buildSymptomSelectorCard(isDark),

            const SizedBox(height: 16),

            // 3. Scan Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  elevation: 2,
                ),
                onPressed: scanState.isLoading ? null : _runScan,
                icon: scanState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.energy_savings_leaf_rounded),
                label: Text(
                  scanState.isLoading ? 'Analyzing Chlorosis & Soil...' : 'Diagnose Deficiency & Top-Dressing',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (scanState.error != null) ...[
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
                      child: Text('Scan error: ${scanState.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Result View
            if (scanState.result != null) ...[
              const SizedBox(height: 20),
              _buildResultView(scanState.result!, isDark),
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
              const Icon(Icons.center_focus_strong_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Leaf Chlorosis Photograph (Optional)',
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
                color: isDark ? const Color(0xFF2E1C0C) : const Color(0xFFFFFBEB),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: isDark ? const Color(0xFF523315) : const Color(0xFFFDE68A),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 30, color: Color(0xFFD97706)),
                  SizedBox(height: 6),
                  Text(
                    'Tap Camera / Gallery below to inspect yellowing pattern',
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

  Widget _buildSymptomSelectorCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Crop & Visual Symptom Markers',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Crop Type
          DropdownButtonFormField<String>(
            initialValue: _selectedCrop,
            decoration: const InputDecoration(
              labelText: 'Crop Species',
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCrop = val);
            },
          ),
          const SizedBox(height: 12),

          // Leaf Location
          const Text('Leaf Position on Plant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Older / Lower Leaves'),
                  ),
                  selected: _leafPosition == 'older',
                  onSelected: (sel) {
                    if (sel) setState(() => _leafPosition = 'older');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Youngest Upper Leaves'),
                  ),
                  selected: _leafPosition == 'upper',
                  onSelected: (sel) {
                    if (sel) setState(() => _leafPosition = 'upper');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pattern
          DropdownButtonFormField<String>(
            initialValue: _symptomPattern,
            decoration: const InputDecoration(
              labelText: 'Visual Discoloration Pattern',
              border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            items: const [
              DropdownMenuItem(
                value: 'v_shaped',
                child: Text('V-shaped yellowing along midrib (N)'),
              ),
              DropdownMenuItem(
                value: 'purple_margin',
                child: Text('Purplish / bronze leaf margins (P)'),
              ),
              DropdownMenuItem(
                value: 'marginal_scorch',
                child: Text('Burnt / scorched leaf edges (K)'),
              ),
              DropdownMenuItem(
                value: 'white_bands',
                child: Text('Bleached white bands beside midrib (Zn)'),
              ),
              DropdownMenuItem(
                value: 'interveinal',
                child: Text('Sharp interveinal yellowing / green veins (Fe)'),
              ),
              DropdownMenuItem(
                value: 'pale_yellow',
                child: Text('Uniform pale yellow on new leaves (S)'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _symptomPattern = val);
            },
          ),
          const SizedBox(height: 12),

          // Soil pH slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated Soil pH:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_soilPh.toStringAsFixed(1)} (${_soilPh < 5.5 ? "Acidic Nitisol" : (_soilPh > 7.5 ? "Alkaline Vertisol" : "Optimal")})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Slider(
            value: _soilPh,
            min: 4.5,
            max: 8.5,
            divisions: 8,
            label: _soilPh.toStringAsFixed(1),
            activeColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _soilPh = val),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(NutrientDeficiencyResult result, bool isDark) {
    final def = result.diagnosedDeficiency;
    final action = result.correctiveAction;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        AppSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.science_rounded, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          def.nutrient,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          def.nutrientNameAm,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD97706),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(result.confidenceScore * 100).toInt()}% CONFIDENCE',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                def.visualDescriptionEn,
                style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white70 : const Color(0xFF334155), height: 1.35),
              ),
              const SizedBox(height: 6),
              Text(
                def.visualDescriptionAm,
                style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), height: 1.35),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.terrain_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Soil Causes: ${def.causesEn}',
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Corrective Fertilizer Plan
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF166534)],
            ),
            borderRadius: AppRadii.roundedLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory_2_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Corrective Fertilizer Prescription',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Fertilizer: ${action.fertilizerName} (${action.fertilizerNameAm})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Application: ${action.applicationType}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.scale_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dosage: ${action.ratePerHectare}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.colorize_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Emergency Knapsack Rescue: ${action.knapsackFoliarRescue}',
                            style: const TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Timing: ${action.timingEn}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                action.timingAm,
                style: const TextStyle(color: Color(0xFF86EFAC), fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNutrientGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Consumer(
              builder: (context, ref, _) {
                final nutAsync = ref.watch(nutrientDatabaseFutureProvider);
                return nutAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Failed: $e')),
                  data: (defs) => ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: defs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final d = defs[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFEF3C7),
                          child: Text(d.nutrient.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                        ),
                        title: Text(d.nutrient, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${d.nutrientNameAm}\n${d.symptomPattern}'),
                        isThreeLine: true,
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
