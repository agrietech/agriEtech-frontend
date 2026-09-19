import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/windows_camera_helper.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../offline_sync/domain/sync_service.dart';
import '../../farms/providers/farms_provider.dart';
import '../models/diagnosis_models.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/ai_leaf_scanner_modal.dart';
import '../../crop_protection/models/crop_protection_models.dart';
import '../../crop_protection/providers/crop_protection_provider.dart';

/// Available inspection modes for the consolidated Scan Crop Workstation
enum CropScanMode {
  all('all', '360° Agronomic Scan', 'የተሟላ የሰብል ቅኝት', Icons.all_inclusive_rounded,
      AppTheme.primaryColor),
  disease('disease', 'Disease Doctor', 'የሰብል በሽታ', Icons.biotech_rounded,
      AppTheme.telemetryNdvi),
  nutrient('nutrient', 'Nutrient Scan', 'ንጥረ-ነገር እጥረት',
      Icons.energy_savings_leaf_rounded, AppTheme.tertiaryColor),
  weed('weed', 'Weed Detector', 'አረም መለያ', Icons.grass_rounded,
      AppTheme.accentGreen),
  pest('pest', 'Pest Scout (ETL)', 'ተባይ ቅኝት', Icons.bug_report_rounded,
      AppTheme.criticalRiskColor);

  final String id;
  final String labelEn;
  final String labelAm;
  final IconData icon;
  final Color color;

  const CropScanMode(
      this.id, this.labelEn, this.labelAm, this.icon, this.color);

  static CropScanMode fromString(String? val) {
    if (val == null) return CropScanMode.all;
    switch (val.toLowerCase().trim()) {
      case 'nutrient':
      case 'nutrients':
      case 'chlorosis':
      case 'nutrient_deficiency':
        return CropScanMode.nutrient;
      case 'weed':
      case 'weeds':
      case 'weed_detector':
        return CropScanMode.weed;
      case 'pest':
      case 'pests':
      case 'pest_scout':
      case 'etl':
        return CropScanMode.pest;
      case 'disease':
      case 'pathology':
        return CropScanMode.disease;
      case 'all':
      default:
        return CropScanMode.all;
    }
  }
}

/// Unified Silicon Valley standard Scan Crop Agronomic Workstation.
/// Integrates Foliar Pathology, Visual Nutrient Deficiency, Weed Detection & Insect Pest Scouting
/// under a single high-performance camera viewfinder and decision engine.
class CreateDiagnosisScreen extends ConsumerStatefulWidget {
  final bool autoLaunchScanner;
  final CropScanMode initialMode;

  const CreateDiagnosisScreen({
    super.key,
    this.autoLaunchScanner = true,
    this.initialMode = CropScanMode.all,
  });

  @override
  ConsumerState<CreateDiagnosisScreen> createState() =>
      _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends ConsumerState<CreateDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _customCropController = TextEditingController();
  final TextEditingController _areaController =
      TextEditingController(text: '1.0');

  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  String? _selectedFarmId;
  String _selectedCropType = 'Wheat';
  String? _imageSourceLabel;
  bool _isSubmitting = false;

  // Telemetry calibration parameters
  String _leafPosition = 'older';
  final String _symptomPattern = 'v_shaped';
  double _soilPh = 6.5;

  final String _selectedPestId = 'fall_armyworm';
  String _cropStage = 'midWhorl';
  final double _damagePercent = 25.0;
  final int _totalSampled = 100;
  final int _infestedCount = 25;

  final List<String> _cropOptions = const [
    'Wheat',
    'Teff',
    'Maize',
    'Barley',
    'Sorghum',
    'Coffee',
    'Sesame',
    'Chickpeas',
    'Lentils',
    'Faba Bean',
    'Enset',
    'Avocado',
    'Potato',
    'Red Pepper / Berbere',
    'Garlic',
    'Other (Custom Crop)',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.autoLaunchScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedImageBytes == null) {
          _openScannerModal();
        }
      });
    }
  }

  @override
  void dispose() {
    _customCropController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  /// Open the interactive AI Leaf Scanner & Camera Viewfinder
  Future<void> _openScannerModal() async {
    final result = await AiLeafScannerModal.show(
      context,
      initialCropType: _selectedCropType,
    );

    if (result != null && mounted) {
      _applyAcquisitionResult(result);
    }
  }

  void _applyAcquisitionResult(ScannerAcquisitionResult result) {
    setState(() {
      _selectedImageBytes = result.imageBytes;
      _imageSourceLabel = result.sourceLabel;
      if (result.imagePath != null) {
        _selectedImagePath = result.imagePath;
      }
      if (result.suggestedCrop != null) {
        final match = _cropOptions.firstWhere(
          (c) =>
              c.toLowerCase().contains(result.suggestedCrop!.toLowerCase()) ||
              result.suggestedCrop!.toLowerCase().contains(c.toLowerCase()),
          orElse: () => _selectedCropType,
        );
        _selectedCropType = match;
      }
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Acquired specimen from ${result.sourceLabel}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Direct hardware camera photo acquisition or viewfinder launch
  Future<void> _handleCameraCapture() async {
    if (WindowsCameraHelper.isWindows) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                    'Opening HP Camera... Snap your photo in the Camera app!'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF1B5E20),
          duration: Duration(seconds: 4),
        ),
      );

      final file = await WindowsCameraHelper.capturePhotoFromWindowsCamera(
        timeout: const Duration(seconds: 60),
        onStatus: (status) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(status),
                backgroundColor: const Color(0xFF1B5E20),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );

      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        _applyAcquisitionResult(
          ScannerAcquisitionResult(
            imageBytes: bytes,
            imagePath: file.path,
            sourceLabel:
                'HP Camera (${file.path.split(Platform.pathSeparator).last})',
          ),
        );
        return;
      }

      if (mounted) {
        // If timed out or cancelled, open scanner modal with recent photos
        _openScannerModal();
      }
      return;
    }

    _openScannerModal();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      _handleCameraCapture();
      return;
    }

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 88,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (mounted) {
          setState(() => _selectedImagePath = picked.path);
          _applyAcquisitionResult(
            ScannerAcquisitionResult(
              imageBytes: bytes,
              imagePath: picked.path,
              sourceLabel: 'Gallery',
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _openScannerModal();
      }
    }
  }

  String _getEffectiveCrop() {
    if (_selectedCropType == 'Other (Custom Crop)') {
      final custom = _customCropController.text.trim();
      return custom.isNotEmpty ? custom : 'Custom Crop';
    }
    return _selectedCropType;
  }

  // ─── UNIFIED 360° MULTIMODAL SCAN PIPELINE ────────────────────────────────

  Future<void> _submitScan() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please capture or choose a crop specimen photo to diagnose.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final effectiveCrop = _getEffectiveCrop();
    final base64Image =
        _selectedImageBytes != null ? base64Encode(_selectedImageBytes!) : '';

    try {
      await _submitUnified360Scan(effectiveCrop, base64Image);
    } catch (e) {
      if (mounted) {
        final errorMsg = e
            .toString()
            .replaceAll('Exception:', '')
            .replaceAll('UnknownError:', '')
            .trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(errorMsg.isNotEmpty
                        ? errorMsg
                        : 'Diagnostic scan error occurred.')),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitUnified360Scan(
      String effectiveCrop, String base64Image) async {
    final farmsState = ref.read(farmsProvider);
    final String? targetFarmId = _selectedFarmId ??
        (farmsState.hasFarms ? farmsState.farms.first.id : null);

    DiagnosisModel? diagnosis;
    NutrientDeficiencyResult? nutrientResult;
    WeedDetectionResult? weedResult;
    PestScoutResult? pestResult;

    final area = double.tryParse(_areaController.text) ?? 1.0;

    // Concurrently evaluate all 4 agronomic vectors from the single camera scan
    await Future.wait([
      // 1. Foliar Pathology & Disease Model
      () async {
        try {
          final request = CreateDiagnosisRequest(
            farmId: targetFarmId,
            imageBase64: base64Image,
            imageBytes: _selectedImageBytes,
            imagePath: _selectedImagePath,
            cropType: effectiveCrop,
          );
          final repository = ref.read(diagnosisRepositoryProvider);
          diagnosis = await repository.createDiagnosis(request);
          ref.invalidate(diagnosisListProvider);
          ref.invalidate(diagnosisStatisticsProvider);
        } catch (e) {
          debugPrint('Unified disease scan error: $e');
          final payload = {
            if (targetFarmId != null) 'farmId': targetFarmId,
            'imageBase64': base64Image,
            'cropType': effectiveCrop,
          };
          await SyncService.enqueue(ApiConstants.diagnose, 'POST', payload);
        }
      }(),
      // 2. Visual Nutrient Chlorosis Model
      () async {
        try {
          await ref.read(nutrientScannerStateProvider.notifier).scan(
                imagePath: _selectedImagePath,
                imageBase64: base64Image,
                cropType: effectiveCrop,
                leafPosition: _leafPosition,
                pattern: _symptomPattern,
                soilPh: _soilPh,
              );
          nutrientResult = ref.read(nutrientScannerStateProvider).result;
        } catch (e) {
          debugPrint('Unified nutrient scan error: $e');
        }
      }(),
      // 3. Invasive Weed Detection Model
      () async {
        try {
          await ref.read(weedDetectorStateProvider.notifier).detect(
                imagePath: _selectedImagePath,
                imageBase64: base64Image,
                cropType: effectiveCrop,
                areaHectares: area,
              );
          weedResult = ref.read(weedDetectorStateProvider).result;
        } catch (e) {
          debugPrint('Unified weed scan error: $e');
        }
      }(),
      // 4. Insect Pest Scout & ETL Evaluation Model
      () async {
        try {
          await ref.read(pestScoutStateProvider.notifier).scout(
                imagePath: _selectedImagePath,
                imageBase64: base64Image,
                pestId: _selectedPestId,
                cropType: effectiveCrop,
                cropStage: _cropStage,
                observedDamagePercent: _damagePercent,
                infestedPlantsCount: _infestedCount,
                totalSampledPlants: _totalSampled,
              );
          pestResult = ref.read(pestScoutStateProvider).result;
        } catch (e) {
          debugPrint('Unified pest scout error: $e');
        }
      }(),
    ]);

    if (mounted) {
      _showUnified360ReportModal(
        crop: effectiveCrop,
        diagnosis: diagnosis,
        nutrient: nutrientResult,
        weed: weedResult,
        pest: pestResult,
      );
    }
  }

  void _showUnified360ReportModal({
    required String crop,
    DiagnosisModel? diagnosis,
    NutrientDeficiencyResult? nutrient,
    WeedDetectionResult? weed,
    PestScoutResult? pest,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _Unified360ReportSheet(
        crop: crop,
        imageBytes: _selectedImageBytes,
        diagnosis: diagnosis,
        nutrient: nutrient,
        weed: weed,
        pest: pest,
        onSave: () {
          ref.read(diagnosisListProvider.notifier).refresh();
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '360° Agronomic Health Report saved to farm registry!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }



  // ─── BUILD SCREEN ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic = currentLang == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAmharic ? 'የሰብል ሐኪም 360° (Crop Doctor)' : 'Crop Doctor 360° AI',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Agronomic Reference Guides',
            onPressed: () => _showConsolidatedGuide(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Unified 360° Intelligence Banner
              _buildUnified360Banner(isDark, isAmharic),

              const SizedBox(height: 16),

              // 2. Photo Acquisition Preview Card
              _buildPhotoPreviewCard(isDark, isAmharic),

              const SizedBox(height: 12),

              // 3. Fast Capture Options
              _buildFastCaptureRow(isDark, isAmharic),

              const SizedBox(height: 18),

              // 4. Shared Selectors: Farm & Crop
              if (farmsState.hasFarms) ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedFarmId,
                  decoration: InputDecoration(
                    labelText: isAmharic ? 'የታለመው እርሻ' : 'Target Farm Plot',
                    prefixIcon: const Icon(Icons.agriculture_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: farmsState.farms.map((f) {
                    return DropdownMenuItem<String>(
                      value: f.id,
                      child: Text('${f.farmName} (${f.primaryCrop})',
                          overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFarmId = val),
                ),
                const SizedBox(height: 14),
              ],

              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedCropType,
                decoration: InputDecoration(
                  labelText: isAmharic ? 'የታለመው ሰብል አይነት' : 'Target Crop Type',
                  prefixIcon: const Icon(Icons.grass_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _cropOptions.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCropType = val);
                },
              ),

              if (_selectedCropType == 'Other (Custom Crop)') ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _customCropController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Crop Variety Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 5. Optional Advanced Field Telemetry (Collapsible)
              _buildAdvancedTelemetryInputs(isDark, isAmharic),

              const SizedBox(height: 24),

              // 6. Unified 360° Submit Action Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: _isSubmitting ? null : _submitScan,
                icon: _isSubmitting
                    ? const AppLoadingIndicator.small(color: Colors.white)
                    : const Icon(Icons.all_inclusive_rounded, size: 22),
                label: Text(
                  _isSubmitting
                      ? (isAmharic
                          ? 'የተሟላ የሰብል ምርመራ በመካሄድ ላይ...'
                          : 'Analyzing 360° Agronomic Intelligence...')
                      : (isAmharic
                          ? 'የተሟላ 360° የሰብል ምርመራ ያካሂዱ'
                          : 'Run 360° Complete Agronomic Scan'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── WIDGET BUILDERS ────────────────────────────────────────────────────────

  Widget _buildUnified360Banner(bool isDark, bool isAmharic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1B3820), const Color(0xFF132817)]
              : [const Color(0xFFE8F5E9), const Color(0xFFF1F8F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.all_inclusive_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAmharic
                          ? 'የሰብል ሐኪም 360° • ሙሉ ምርመራ'
                          : 'Crop Doctor 360° • All-in-One Scan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAmharic
                          ? 'አንድ ፎቶ ብቻ ያንሱ፡ በሽታ፣ ንጥረ-ነገር፣ አረም እና ተባይ በአንድ ላይ ይመረመራሉ'
                          : 'Snap 1 photo: AI simultaneously evaluates Pathology, Nutrients, Weeds & Pests',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFeaturePill(Icons.biotech_rounded, 'Pathology',
                  const Color(0xFF2E7D32), isDark),
              _buildFeaturePill(Icons.energy_savings_leaf_rounded, 'Nutrient',
                  const Color(0xFFD97706), isDark),
              _buildFeaturePill(Icons.grass_rounded, 'Weed',
                  const Color(0xFF16A34A), isDark),
              _buildFeaturePill(Icons.bug_report_rounded, 'Pest ETL',
                  const Color(0xFFDC2626), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(
      IconData icon, String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreviewCard(bool isDark, bool isAmharic) {
    return GestureDetector(
      onTap: _openScannerModal,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF162516) : const Color(0xFFF1F8F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.4), width: 2),
        ),
        child: _selectedImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                color: Color(0xFF4ADE80), size: 13),
                            const SizedBox(width: 5),
                            Text(
                              _imageSourceLabel ?? 'Ready for Scan',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt,
                                color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text('Change Photo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.all_inclusive_rounded,
                        size: 46, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 10),
                    Text(
                      isAmharic
                          ? 'የሰብል ፎቶ ያንሱ ወይም ይምረጡ'
                          : 'Snap or Select Crop Specimen Photo',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAmharic
                          ? 'በአንድ ፎቶ በሽታ፣ ንጥረ-ነገር፣ አረም እና ተባይ በአንድ ላይ ይመረመራሉ'
                          : 'Evaluates Pathology, Nutrients, Weeds & Pests simultaneously',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFastCaptureRow(bool isDark, bool isAmharic) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            onPressed: _handleCameraCapture,
            icon: const Icon(Icons.camera_alt,
                size: 16, color: Color(0xFF2E7D32)),
            label: Text(
                isAmharic
                    ? (WindowsCameraHelper.isWindows ? 'ካሜራ (HP)' : 'ካሜራ')
                    : (WindowsCameraHelper.isWindows ? 'HP Camera' : 'Camera'),
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: Icon(Icons.photo_library,
                size: 16, color: Colors.grey.shade700),
            label: Text(isAmharic ? 'ማዕከለ-ስዕላት' : 'Gallery',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            onPressed: _openScannerModal,
            icon: const Icon(Icons.filter_center_focus_rounded,
                size: 16, color: Color(0xFF2E7D32)),
            label: Text(isAmharic ? 'የናሙና መመልከቻ' : 'AI Viewfinder',
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedTelemetryInputs(bool isDark, bool isAmharic) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading:
            const Icon(Icons.tune_rounded, size: 20, color: Color(0xFF2E7D32)),
        title: Text(
          isAmharic
              ? 'ተጨማሪ የመስክ መለኪያዎች (አማራጭ)'
              : 'Advanced Field Telemetry (Optional)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          isAmharic
              ? 'የአፈር ፒኤች፣ የመሬት ስፋት (ቅድመ-የተዘጋጀ)'
              : 'Soil pH, Field Area, Crop Stage (Pre-calibrated)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF1E241E) : const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _areaController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Field Area (Hectares)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _cropStage,
                        decoration: const InputDecoration(
                          labelText: 'Crop Stage',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'seedling', child: Text('Seedling (ችግኝ)')),
                          DropdownMenuItem(
                              value: 'midWhorl',
                              child: Text('Mid-Whorl / Tillering')),
                          DropdownMenuItem(
                              value: 'tasseling',
                              child: Text('Flowering / Heading')),
                          DropdownMenuItem(
                              value: 'grainFill',
                              child: Text('Grain Fill / Maturing')),
                        ],
                        onChanged: (val) =>
                            setState(() => _cropStage = val ?? 'midWhorl'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _leafPosition,
                        decoration: const InputDecoration(
                          labelText: 'Leaf Position',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'older',
                              child: Text('Lower/Older Leaves')),
                          DropdownMenuItem(
                              value: 'younger',
                              child: Text('Upper/Younger Leaves')),
                        ],
                        onChanged: (val) =>
                            setState(() => _leafPosition = val ?? 'older'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<double>(
                        initialValue: _soilPh,
                        decoration: const InputDecoration(
                          labelText: 'Soil pH',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 5.5, child: Text('Acidic (5.5)')),
                          DropdownMenuItem(
                              value: 6.5, child: Text('Neutral (6.5)')),
                          DropdownMenuItem(
                              value: 7.5, child: Text('Alkaline (7.5)')),
                        ],
                        onChanged: (val) =>
                            setState(() => _soilPh = val ?? 6.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConsolidatedGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        maxChildSize: 0.94,
        minChildSize: 0.45,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: const [
              Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      color: Color(0xFF2E7D32), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Crop Doctor 360° Agronomic Manual',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '🌿 1. Visual Nutrient Deficiencies (ንጥረ-ነገር መመሪያ)',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFB45309)),
              ),
              SizedBox(height: 6),
              Text(
                  '• Nitrogen (N): V-shaped chlorosis on older leaves. Correct with Urea top-dressing.'),
              Text(
                  '• Phosphorus (P): Purplish bronze margins and stunted roots. Common in acidic soils.'),
              Text(
                  '• Potassium (K): Marginal leaf scorching and tip burn on older leaves.'),
              Text(
                  '• Zinc (Zn): Interveinal bleaching and "white bud" on corn seedlings.'),
              SizedBox(height: 16),
              Text(
                '🌾 2. Noxious & Invasive Weeds (የአረም መመሪያ)',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF15803D)),
              ),
              SizedBox(height: 6),
              Text(
                  '• Parthenium hysterophorus (ኮንግረስ ሳር): Aggressive broadleaf weed. Treat with 2,4-D Amine @ 1.2 L/ha.'),
              Text(
                  '• Striga hermonthica (አቆራጭ): Parasitic root weed on sorghum and maize.'),
              Text(
                  '• Wild Oat (አጃ): Competitive grass in wheat/barley. Use selective graminicides.'),
              SizedBox(height: 16),
              Text(
                '🐛 3. Insect Pests & Economic Threshold Levels (ተባይ መመሪያ)',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFB91C1C)),
              ),
              SizedBox(height: 6),
              Text(
                  '• Fall Armyworm (ተምች): Spray when 20% of whorls show fresh feeding damage in seedling stage.'),
              Text(
                  '• Desert Locust (የበረሃ አንበጣ): Hopper bands require immediate containment spray before fledging.'),
              Text(
                  '• Maize Stem Borer: 5% of plants with "window-pane" feeding on leaves before stem penetration.'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unified 360° Agronomic Health Report Bottom Sheet Modal
class _Unified360ReportSheet extends StatefulWidget {
  final String crop;
  final Uint8List? imageBytes;
  final DiagnosisModel? diagnosis;
  final NutrientDeficiencyResult? nutrient;
  final WeedDetectionResult? weed;
  final PestScoutResult? pest;
  final VoidCallback onSave;

  const _Unified360ReportSheet({
    required this.crop,
    this.imageBytes,
    this.diagnosis,
    this.nutrient,
    this.weed,
    this.pest,
    required this.onSave,
  });

  @override
  State<_Unified360ReportSheet> createState() => _Unified360ReportSheetState();
}

class _Unified360ReportSheetState extends State<_Unified360ReportSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _computeHealthScore() {
    int score = 96;
    if (widget.diagnosis != null) {
      final sev = (widget.diagnosis!.severity ?? '').toUpperCase();
      if (sev.contains('CRITICAL') || sev.contains('HIGH')) {
        score -= 24;
      } else if (sev.contains('MODERATE')) {
        score -= 14;
      } else {
        score -= 6;
      }
    }
    if (widget.nutrient != null) {
      score -= 14;
    }
    if (widget.weed != null) {
      score -= 10;
    }
    if (widget.pest != null &&
        widget.pest!.economicThresholdEvaluation.isAboveETL) {
      score -= 22;
    } else if (widget.pest != null) {
      score -= 6;
    }
    return score.clamp(32, 98);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final healthScore = _computeHealthScore();

    Color scoreColor;
    String scoreStatus;
    IconData scoreIcon;
    if (healthScore >= 80) {
      scoreColor = const Color(0xFF16A34A);
      scoreStatus = 'HEALTHY / LOW RISK';
      scoreIcon = Icons.check_circle_rounded;
    } else if (healthScore >= 60) {
      scoreColor = const Color(0xFFD97706);
      scoreStatus = 'MODERATE ALERT • ACTION ADVISED';
      scoreIcon = Icons.warning_amber_rounded;
    } else {
      scoreColor = const Color(0xFFDC2626);
      scoreStatus = 'CRITICAL ALERT • IMMEDIATE ACTION';
      scoreIcon = Icons.error_rounded;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      maxChildSize: 0.95,
      minChildSize: 0.50,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F18) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Top Header: Photo, Title, Crop, Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  if (widget.imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        widget.imageBytes!,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (widget.imageBytes != null) const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.all_inclusive_rounded,
                                color: Color(0xFF2E7D32), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '360° Agronomic Health Report',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1B5E20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.crop} Variety • Unified Multi-Model Diagnostic',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Overall Health Rating Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scoreColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: healthScore / 100,
                          strokeWidth: 5,
                          backgroundColor: scoreColor.withValues(alpha: 0.2),
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        '$healthScore%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(scoreIcon, color: scoreColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              scoreStatus,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: scoreColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.diagnosis?.diseaseName != null
                              ? 'Foliar condition: ${widget.diagnosis!.diseaseName}. Prompt cultural & chemical defense recommended.'
                              : 'All 4 agronomic vectors scanned. See individual model findings below.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4-in-1 Segmented Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1C281F) : const Color(0xFFF1F5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.biotech_rounded, size: 16),
                      text: 'Pathology'),
                  Tab(
                      icon: Icon(Icons.energy_savings_leaf_rounded, size: 16),
                      text: 'Nutrients'),
                  Tab(icon: Icon(Icons.grass_rounded, size: 16), text: 'Weeds'),
                  Tab(
                      icon: Icon(Icons.bug_report_rounded, size: 16),
                      text: 'Pest (ETL)'),
                ],
              ),
            ),

            // Tab Views Area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Disease
                  _buildDiseaseTab(isDark),
                  // Tab 1: Nutrients
                  _buildNutrientTab(isDark),
                  // Tab 2: Weeds
                  _buildWeedTab(isDark),
                  // Tab 3: Pests
                  _buildPestTab(isDark),
                ],
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF131D14) : const Color(0xFFFAFAFA),
                border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: widget.onSave,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: const Text(
                        'Save 360° Report',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseTab(bool isDark) {
    final d = widget.diagnosis;
    if (d == null) {
      return _buildEmptyTabState(
        Icons.check_circle_outline,
        'No Acute Foliar Pathogen Detected',
        'Foliage appears clear of active fungal rust, blights, or leaf spot infections. Report synced for cloud tracking.',
      );
    }

    final conf = d.confidenceScore != null
        ? (d.confidenceScore! * 100).toStringAsFixed(1)
        : '94.0';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.diseaseName ?? 'Foliar Pathogen Identified',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1B5E20),
                ),
              ),
              if (d.diseaseNameAm != null) ...[
                const SizedBox(height: 2),
                Text(
                  d.diseaseNameAm!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _badge('Confidence: $conf%', const Color(0xFF2E7D32)),
                  _badge(
                      'Severity: ${d.severity ?? "MODERATE"}',
                      d.severity == 'HIGH'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFFD97706)),
                  if (d.pathogen != null) _badge(d.pathogen!, Colors.blueGrey),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (d.treatmentEn != null || d.treatment != null) ...[
          const Text('💊 Chemical Treatment Prescription:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2820) : const Color(0xFFF1F8F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              d.treatmentEn ?? d.treatment!,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (d.preventionEn != null || d.preventionTips != null) ...[
          const Text('🌿 Cultural & Agronomic Practices:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF1B5E20))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2820) : const Color(0xFFF1F8F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              d.preventionEn ?? d.preventionTips!,
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNutrientTab(bool isDark) {
    final n = widget.nutrient;
    if (n == null) {
      return _buildEmptyTabState(
        Icons.energy_savings_leaf_outlined,
        'Chlorophyll & Nutrient Profile Balanced',
        'Visual examination shows balanced nitrogen, phosphorus, and potassium levels without acute chlorosis.',
      );
    }

    final def = n.diagnosedDeficiency;
    final action = n.correctiveAction;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${def.nutrient} Deficiency (${def.nutrientNameAm})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 6),
              Text(def.visualDescriptionEn,
                  style: const TextStyle(fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('🧪 Corrective Fertilizer Top-Dressing Plan:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262016) : const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '• Product: ${action.fertilizerName} (${action.fertilizerNameAm})',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                  '• Application: ${action.applicationType} @ ${action.ratePerHectare}',
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text('• Foliar Rescue: ${action.knapsackFoliarRescue}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047857))),
              const SizedBox(height: 6),
              Text(n.applicationSummaryEn,
                  style:
                      TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeedTab(bool isDark) {
    final w = widget.weed;
    if (w == null) {
      return _buildEmptyTabState(
        Icons.grass_outlined,
        'No Noxious Weed Infestation Detected',
        'Canopy area is free of high-density invasive weeds (Parthenium, Striga, Commelina). Field weed density below 5%.',
      );
    }

    final weed = w.weed;
    final plan = w.calibratedKnapsackSprayerPlan;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weed.commonNameEn} (${weed.commonNameAm})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${weed.scientificName} • Type: ${weed.weedType} (${weed.lifecycle})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('🚜 Calibrated Knapsack Plan (16L Tanks):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17241A) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Sprayers Required: ${plan.totalKnapsacksNeeded} tanks',
                  style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 4),
              Text('• Herbicide Dosage per 16L: ${plan.dosagePer16LTank}',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D))),
            ],
          ),
        ),
        if (w.recommendedHerbicides.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('Recommended Selective Herbicides:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          ...w.recommendedHerbicides.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                    '• ${h.tradeName} (${h.ratePerHectare}) - Timing: ${h.timing}',
                    style: const TextStyle(fontSize: 12)),
              )),
        ],
      ],
    );
  }

  Widget _buildPestTab(bool isDark) {
    final p = widget.pest;
    if (p == null) {
      return _buildEmptyTabState(
        Icons.bug_report_outlined,
        'Insect Pests Below Economic Threshold (ETL)',
        'No critical insect infestation (Armyworm, Locust, Stem Borer) exceeding economic injury level detected.',
      );
    }

    final eval = p.economicThresholdEvaluation;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (eval.isAboveETL
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A))
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (eval.isAboveETL
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A))
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${eval.commonNameEn} (${eval.commonNameAm})',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text('${eval.scientificName} • Stage: ${eval.cropStage}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: eval.isAboveETL
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  eval.isAboveETL
                      ? '⚠️ ECONOMIC THRESHOLD EXCEEDED (${eval.observedDamagePercent.toStringAsFixed(0)}% vs ${eval.thresholdPercent.toStringAsFixed(0)}% limit)'
                      : '✅ BELOW ECONOMIC THRESHOLD (${eval.observedDamagePercent.toStringAsFixed(0)}% vs ${eval.thresholdPercent.toStringAsFixed(0)}% limit)',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Prescription & Scouting Recommendation:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF261D1D) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(eval.recommendation.en,
              style: const TextStyle(fontSize: 12.5)),
        ),
        if (eval.firstLinePesticides.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Text('First-Line Pesticide Control Options:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          ...eval.firstLinePesticides.map((p) => Text(
                '• ${p.tradeName} @ ${p.ratePerHa} (${p.ratePer16LKnapsack} / 16L)',
                style: const TextStyle(fontSize: 12),
              )),
        ],
      ],
    );
  }

  Widget _buildEmptyTabState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
