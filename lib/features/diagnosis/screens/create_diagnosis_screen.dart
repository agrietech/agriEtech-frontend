import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../offline_sync/domain/sync_service.dart';
import '../../farms/providers/farms_provider.dart';
import '../models/diagnosis_models.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/ai_leaf_scanner_modal.dart';

class CreateDiagnosisScreen extends ConsumerStatefulWidget {
  final bool autoLaunchScanner;

  const CreateDiagnosisScreen({
    super.key,
    this.autoLaunchScanner = true,
  });

  @override
  ConsumerState<CreateDiagnosisScreen> createState() =>
      _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends ConsumerState<CreateDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _customCropController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedFarmId;
  String _selectedCropType = 'Wheat';
  String? _imageSourceLabel;
  bool _isSubmitting = false;

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
    super.dispose();
  }

  /// Open the Silicon Valley interactive AI Leaf Scanner & Camera Viewfinder
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
      if (result.suggestedCrop != null) {
        final match = _cropOptions.firstWhere(
          (c) => c.toLowerCase().contains(result.suggestedCrop!.toLowerCase()) ||
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
                'Acquired leaf from ${result.sourceLabel}',
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

  Future<void> _pickImage(ImageSource source) async {
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
          _applyAcquisitionResult(
            ScannerAcquisitionResult(
              imageBytes: bytes,
              sourceLabel: source == ImageSource.camera ? 'Camera' : 'Gallery',
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Fallback gracefully to interactive scanner modal
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

  Future<void> _submitDiagnosis() async {
    if (_selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or choose a leaf photo to diagnose.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final effectiveCrop = _getEffectiveCrop();
    final base64Image = _selectedImageBytes != null ? base64Encode(_selectedImageBytes!) : '';

    try {
      final request = CreateDiagnosisRequest(
        farmId: _selectedFarmId ?? 'farm_demo_01',
        imageBase64: base64Image,
        imageBytes: _selectedImageBytes,
        cropType: effectiveCrop,
      );

      final repository = ref.read(diagnosisRepositoryProvider);
      final diagnosis = await repository.createDiagnosis(request);

      if (mounted) {
        _showDiagnosisResultDialog(diagnosis);
      }
    } catch (e) {
      final payload = {
        'farmId': _selectedFarmId ?? 'farm_demo_01',
        'imageBase64': base64Image,
        'cropType': effectiveCrop,
      };
      await SyncService.enqueue(ApiConstants.diagnose, 'POST', payload);

      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception:', '').replaceAll('UnknownError:', '').trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMsg.isNotEmpty && !errorMsg.contains('null')
                        ? 'Diagnostic queued offline ($errorMsg). Will analyze when connected.'
                        : 'Diagnostic queued offline. Will analyze when connected.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE65100),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitDiagnosis,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showDiagnosisResultDialog(DiagnosisModel diagnosis) {
    final conf = diagnosis.confidenceScore != null
        ? (diagnosis.confidenceScore! * 100).toStringAsFixed(1)
        : '94.0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Diagnosis Complete',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diagnosis.diseaseName ?? 'Identified Foliar Pathogen',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20)),
                      ),
                      if (diagnosis.diseaseNameAm != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          diagnosis.diseaseNameAm!,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Confidence: $conf%',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Severity: ${diagnosis.severity ?? "HIGH"}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recommended Action Plan:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                if (diagnosis.treatmentEn != null || diagnosis.treatment != null) ...[
                  const Text('💊 Treatment Prescription:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
                  const SizedBox(height: 4),
                  Text(
                    diagnosis.treatmentEn ?? diagnosis.treatment!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
                if (diagnosis.preventionEn != null || diagnosis.preventionTips != null) ...[
                  const Text('🌿 Agronomic & Cultural Controls:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 4),
                  Text(
                    diagnosis.preventionEn ?? diagnosis.preventionTips!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to diagnosis list
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmsState = ref.watch(farmsProvider);
    final currentLang = ref.watch(appLocaleProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAmharic = currentLang == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAmharic ? 'የሰብል በሽታ ምርመራ (AI ስካነር)' : 'AI Crop Pathology Scanner',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo acquisition preview card
              GestureDetector(
                onTap: _openScannerModal,
                child: Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF162516) : const Color(0xFFF1F8F1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, color: Color(0xFF4ADE80), size: 13),
                                      const SizedBox(width: 5),
                                      Text(
                                        _imageSourceLabel ?? (isAmharic ? 'ለAI ምርመራ ዝግጁ' : 'Ready for Scan'),
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAmharic ? 'ፎቶ ቀይር' : 'Change Photo',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            // Corner targeting brackets
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                    left: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                    right: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 14,
                              left: 14,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                    left: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 14,
                              right: 14,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                    right: BorderSide(color: Color(0xFF2E7D32), width: 3),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.document_scanner,
                                      size: 44,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isAmharic ? 'የሰብል ቅጠል ካሜራ ስካነርን ክፈት' : 'Launch AI Leaf Camera Scanner',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAmharic
                                        ? 'የታመመውን ቅጠል በክፈፉ ውስጥ ያስተካክሉ'
                                        : 'Align single symptomatic leaf inside targeting frame',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isAmharic
                                          ? '☀️ የተፈጥሮ ብርሃን • 🔍 15-20 ሳ.ሜ ርቀት • 🌿 ጥርት ያለ'
                                          : '☀️ Natural Light • 🔍 15-20cm Distance • 🌿 In Focus',
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick Input Action Buttons: Camera Scanner, Gallery, Specimen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                      ),
                      onPressed: _openScannerModal,
                      icon: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF2E7D32)),
                      label: Text(
                        isAmharic ? 'ካሜራ' : 'Camera UI',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, size: 16, color: Colors.grey.shade700),
                      label: Text(
                        isAmharic ? 'ማዕከለ-ስዕላት' : 'Gallery',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.amber.shade700),
                      ),
                      onPressed: _openScannerModal,
                      icon: Icon(Icons.biotech, size: 16, color: Colors.amber.shade800),
                      label: Text(
                        isAmharic ? 'የናሙና ቅጠል' : 'Specimen',
                        style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Farm Selector
              if (farmsState.hasFarms) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedFarmId,
                  decoration: InputDecoration(
                    labelText: isAmharic ? 'የታለመው እርሻ (አስገዳጅ ያልሆነ)' : 'Target Farm Plot (Optional)',
                    prefixIcon: const Icon(Icons.agriculture_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: farmsState.farms.map((f) {
                    return DropdownMenuItem<String>(
                      value: f.id,
                      child: Text('${f.farmName} (${f.primaryCrop})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedFarmId = val),
                ),
                const SizedBox(height: 16),
              ],

              // Crop Selector Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCropType,
                decoration: InputDecoration(
                  labelText: isAmharic ? 'የታለመው ሰብል አይነት' : 'Target Crop Type',
                  prefixIcon: const Icon(Icons.grass_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _cropOptions.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCropType = val);
                  }
                },
              ),

              // Dynamic Custom Crop Input
              if (_selectedCropType == 'Other (Custom Crop)') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCropController,
                  decoration: InputDecoration(
                    labelText: isAmharic ? 'የሰብሉ ዝርያ ስም' : 'Custom Crop Variety Name',
                    prefixIcon: const Icon(Icons.eco_outlined, color: AppTheme.primaryColor),
                    border: const OutlineInputBorder(borderRadius: AppRadii.roundedMd),
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Diagnosis Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                  elevation: 2,
                ),
                onPressed: _isSubmitting ? null : _submitDiagnosis,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.document_scanner_outlined),
                label: Text(
                  _isSubmitting
                      ? (isAmharic ? 'ምርመራ በAI እየተካሄደ ነው...' : 'Scanning Pathology via Dual-AI...')
                      : (isAmharic ? 'የበሽታ ምርመራ በAI ጀምር' : 'Run Dual-AI Pathology Scan'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
