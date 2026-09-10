import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_surface_card.dart';
import '../models/crop_protection_models.dart';
import '../providers/crop_protection_provider.dart';

class WeedDetectorScreen extends ConsumerStatefulWidget {
  const WeedDetectorScreen({super.key});

  @override
  ConsumerState<WeedDetectorScreen> createState() => _WeedDetectorScreenState();
}

class _WeedDetectorScreenState extends ConsumerState<WeedDetectorScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _areaController = TextEditingController(text: '1.0');

  String _selectedCrop = 'Wheat';
  Uint8List? _imageBytes;
  String? _imagePath;

  final List<String> _cropOptions = const [
    'Wheat',
    'Teff',
    'Maize',
    'Sorghum',
    'Barley',
    'Faba Bean',
  ];

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

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

  void _runDetection() {
    final area = double.tryParse(_areaController.text) ?? 1.0;
    String? base64Str;
    if (_imageBytes != null) {
      base64Str = base64Encode(_imageBytes!);
    }

    ref.read(weedDetectorStateProvider.notifier).detect(
      imagePath: _imagePath,
      imageBase64: base64Str,
      cropType: _selectedCrop,
      areaHectares: area,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weedState = ref.watch(weedDetectorStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weed Detector & Herbicides'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Weed Catalog',
            onPressed: () => _showWeedCatalogSheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Photo Capture & Preview Card
            _buildPhotoCard(isDark),

            const SizedBox(height: 16),

            // 2. Field Configuration (Crop & Area)
            _buildFieldConfigCard(isDark),

            const SizedBox(height: 16),

            // 3. Detect Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  elevation: 2,
                ),
                onPressed: weedState.isLoading ? null : _runDetection,
                icon: weedState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: Text(
                  weedState.isLoading ? 'Analyzing Weed & Calibrating...' : 'Identify Weed & Prescribe Herbicides',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),

            if (weedState.error != null) ...[
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
                      child: Text(
                        'Detection failed: ${weedState.error}',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Results Display
            if (weedState.result != null) ...[
              const SizedBox(height: 20),
              _buildResultsView(weedState.result!, isDark),
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
              const Icon(Icons.camera_alt_rounded, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weed Leaf / Field Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
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
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF162A1D) : const Color(0xFFF0FDF4),
                borderRadius: AppRadii.roundedMd,
                border: Border.all(
                  color: isDark ? const Color(0xFF23442E) : const Color(0xFFBBF7D0),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  Text(
                    'Capture or upload weed photograph for AI diagnosis',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_rounded, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldConfigCard(bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field & Crop Parameters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCrop,
                  decoration: const InputDecoration(
                    labelText: 'Target Crop',
                    border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: _cropOptions
                      .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCrop = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Plot Area (Ha)',
                    suffixText: 'ha',
                    border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [0.25, 0.5, 1.0, 2.0, 5.0].map((ha) {
              final label = ha == 0.25 ? '1 Timad' : '$ha ha';
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ActionChip(
                  label: Text(label, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    _areaController.text = ha.toString();
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(WeedDetectionResult result, bool isDark) {
    final weed = result.weed;
    final knapsack = result.calibratedKnapsackSprayerPlan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Identification Card
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
                      color: const Color(0xFF16A34A).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weed.commonNameEn,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${weed.scientificName} • ${weed.commonNameAm}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      weed.invasiveSeverity,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                weed.descriptionEn,
                style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white70 : const Color(0xFF334155), height: 1.35),
              ),
              const SizedBox(height: 6),
              Text(
                weed.descriptionAm,
                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534), height: 1.35),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Knapsack Sprayer Calibration Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
            ),
            borderRadius: AppRadii.roundedLg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.colorize_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    '16L Knapsack Sprayer Dilution Plan',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatTile('Plot Area', '${knapsack.areaHectares} ha', Icons.landscape_rounded),
                  _buildStatTile('Knapsack Tanks', '${knapsack.totalKnapsacksNeeded} tanks', Icons.local_gas_station_rounded),
                  _buildStatTile('Dose / Tank', knapsack.dosagePer16LTank.split(' per ')[0], Icons.science_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: AppRadii.roundedMd,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total chemical needed: ${knapsack.totalChemicalNeeded} ${knapsack.unit}. Based on standard 200 L/ha water volume.',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Recommended Selective Herbicides
        const Text(
          'Recommended Selective Herbicides',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...result.recommendedHerbicides.map((herb) => _buildHerbicideCard(herb, isDark)),

        const SizedBox(height: 16),

        // Cultural & Mechanical Controls
        const Text(
          'Cultural & Preventive Alternatives',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        ...result.culturalControls.map((cult) => _buildCulturalCard(cult, isDark)),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
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
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5), textAlign: TextAlign.center),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHerbicideCard(HerbicideModel herb, bool isDark) {
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
                  herb.tradeName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppTheme.primaryColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${herb.rainfastnessHours}h Rainfast',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Active: ${herb.activeIngredient} (${herb.chemicalFamily})',
            style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: AppRadii.roundedMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Rate: ${herb.ratePerHectare}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5)),
                ),
                Expanded(
                  child: Text('PHI: ${herb.phiDays} days', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(herb.timing, style: const TextStyle(fontSize: 11.5, height: 1.3)),
          if (herb.notesEn != null) ...[
            const SizedBox(height: 4),
            Text(
              '⚠️ ${herb.notesEn}',
              style: const TextStyle(fontSize: 11, color: Color(0xFFD97706)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCulturalCard(CulturalControlModel cult, bool isDark) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cult.method,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(cult.instructionsEn, style: const TextStyle(fontSize: 11.5, height: 1.3)),
          const SizedBox(height: 2),
          Text(cult.instructionsAm, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D))),
        ],
      ),
    );
  }

  void _showWeedCatalogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Consumer(
              builder: (context, ref, _) {
                final weedsAsync = ref.watch(weedListFutureProvider);
                return weedsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Failed: $e')),
                  data: (weeds) => ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount: weeds.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      final w = weeds[i];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFDCFCE7),
                          child: Icon(Icons.grass_rounded, color: Color(0xFF16A34A)),
                        ),
                        title: Text(w.commonNameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${w.scientificName}\n${w.commonNameAm}'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(weedDetectorStateProvider.notifier).detect(
                            cropType: _selectedCrop,
                            areaHectares: double.tryParse(_areaController.text) ?? 1.0,
                          );
                        },
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
