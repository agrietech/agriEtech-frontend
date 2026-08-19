import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/disease_diagnosis_model.dart';
import '../../disease_diagnosis/data/repositories/disease_repository.dart';
import '../../farms/providers/farms_provider.dart';

class DiseaseDiagnosisScreen extends ConsumerStatefulWidget {
  const DiseaseDiagnosisScreen({super.key});

  @override
  ConsumerState<DiseaseDiagnosisScreen> createState() =>
      _DiseaseDiagnosisScreenState();
}

class _DiseaseDiagnosisScreenState
    extends ConsumerState<DiseaseDiagnosisScreen> {
  File? _selectedImage;
  String? _selectedFarmId;
  String? _selectedCropType;
  bool _isAnalyzing = false;
  DiseaseDiagnosisModel? _diagnosisResult;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _diagnosisResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _analyzePlant() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    if (_selectedFarmId == null || _selectedCropType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select farm and crop type')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = DiagnosisRequest(
        farmId: _selectedFarmId!,
        cropType: _selectedCropType!,
        imageBase64: base64Image,
      );

      final diseaseRepository = ref.read(diseaseRepositoryProvider);
      final result = await diseaseRepository.diagnoseDisease(request);

      if (mounted) {
        setState(() {
          _diagnosisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Disease Diagnosis'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Take a clear photo of the affected plant leaves for accurate diagnosis',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image preview
            if (_selectedImage != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Card(
                elevation: 2,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Image selection buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Farm selection
            if (farmsAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (farmsAsync.error != null)
              Text('Error loading farms: ${farmsAsync.error}')
            else if (farmsAsync.farms.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No farms available. Please add a farm first.'),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedFarmId,
                    decoration: const InputDecoration(
                      labelText: 'Select Farm',
                      border: InputBorder.none,
                    ),
                    items: farmsAsync.farms.map((farm) {
                      return DropdownMenuItem(
                        value: farm.id,
                        child: Text(farm.farmName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFarmId = value;
                        // Auto-select crop type from farm
                        final farm = farmsAsync.farms.firstWhere((f) => f.id == value);
                        _selectedCropType = farm.primaryCrop;
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Crop type selection
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCropType,
                  decoration: const InputDecoration(
                    labelText: 'Crop Type',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Teff', child: Text('Teff (ጤፍ)')),
                    DropdownMenuItem(value: 'Wheat', child: Text('Wheat (ስንዴ)')),
                    DropdownMenuItem(value: 'Barley', child: Text('Barley (ገብስ)')),
                    DropdownMenuItem(value: 'Maize', child: Text('Maize (በቆሎ)')),
                    DropdownMenuItem(value: 'Sorghum', child: Text('Sorghum (ማሽላ)')),
                    DropdownMenuItem(value: 'Coffee', child: Text('Coffee (ቡና)')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCropType = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Analyze button
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzePlant,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Plant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green[700],
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_diagnosisResult != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Text(
                            'Diagnosis Results',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Confidence score
                      LinearProgressIndicator(
                        value: _diagnosisResult!.confidence,
                        backgroundColor: Colors.grey[200],
                        color: _getConfidenceColor(_diagnosisResult!.confidence),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(_diagnosisResult!.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Disease results
                      const Text(
                        'Detected Conditions:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._diagnosisResult!.results.map((result) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        result.diseaseName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${(result.probability * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                if (result.description != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    result.description!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),

                      // Treatment recommendation
                      if (_diagnosisResult!.treatmentRecommendation != null) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.medical_services,
                                color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            const Text(
                              'Treatment Recommendation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_diagnosisResult!.treatmentRecommendation!),
                      ],

                      // Prevention advice
                      if (_diagnosisResult!.preventionAdvice != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.shield, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            const Text(
                              'Prevention Advice',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_diagnosisResult!.preventionAdvice!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
