import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/farm_model.dart';
import '../../farms/providers/farms_provider.dart';
import '../models/diagnosis_models.dart';
import '../providers/diagnosis_provider.dart';

class CreateDiagnosisScreen extends ConsumerStatefulWidget {
  const CreateDiagnosisScreen({super.key});

  @override
  ConsumerState<CreateDiagnosisScreen> createState() =>
      _CreateDiagnosisScreenState();
}

class _CreateDiagnosisScreenState extends ConsumerState<CreateDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedFarmId;
  String? _selectedCropType;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Diagnosis'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // High-Tech AI Viewfinder Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.biotech, color: AppTheme.secondaryColor, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Leaf Vision Input',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2E1E),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'MODEL v2.4 READY',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_selectedImage != null) ...[
                    // Display selected image in a high-tech frame
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Scanner overlay grid
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.8), width: 2),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'IMAGE ACQUIRED',
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Retake image button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showImageSourceDialog(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake or Choose Another Image'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                          side: const BorderSide(color: AppTheme.secondaryColor),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Futuristic Viewfinder Frame
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Color(0xFF1E293B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.4)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                                  ),
                                  child: const Icon(
                                    Icons.camera_enhance_outlined,
                                    size: 40,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Position Affected Plant Leaf',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'AI multi-spectrum pathology detection',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Viewfinder corner marks
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                  left: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                  right: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                  left: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                  right: BorderSide(color: Color(0xFF38BDF8), width: 2.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Live Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Upload Photo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryDark,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_selectedImage == null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '* Leaf photo required for neural pathology scan',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Farm Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Farm Dropdown
                    Builder(
                      builder: (context) {
                        if (farmsAsync.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (farmsAsync.error != null) {
                          return Text(
                            'Error loading farms: ${farmsAsync.error!.message}',
                            style: const TextStyle(color: Colors.red),
                          );
                        }
                        final farms = farmsAsync.farms;
                        if (farms.isEmpty) {
                          return Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.orange[700]),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No farms available. Please add a farm first.',
                                      style: TextStyle(
                                        color: Colors.orange[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          initialValue: _selectedFarmId,
                          decoration: const InputDecoration(
                            labelText: 'Select Farm',
                            prefixIcon: Icon(Icons.agriculture),
                            border: OutlineInputBorder(),
                          ),
                          items: farms.map((farm) {
                            return DropdownMenuItem(
                              value: farm.id,
                              child: Text(farm.farmName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedFarmId = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a farm';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Crop Type Dropdown (Optional)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCropType,
                      decoration: const InputDecoration(
                        labelText: 'Crop Type (Optional)',
                        prefixIcon: Icon(Icons.grass),
                        border: OutlineInputBorder(),
                        helperText: 'Leave empty for automatic detection',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Auto-detect'),
                        ),
                        ...CropTypes.ethiopianCrops.map((crop) {
                          return DropdownMenuItem(
                            value: crop,
                            child: Text(crop),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCropType = value);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting || _selectedImage == null
                    ? null
                    : _submitDiagnosis,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.biotech),
                label: Text(_isSubmitting ? 'Analyzing...' : 'Diagnose Disease'),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined,
                            color: Color(0xFF2E7D32)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tips for Best Results',
                            style: TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Take clear, well-lit photos'),
                    _buildTip('Focus on affected plant parts'),
                    _buildTip('Include multiple angles if possible'),
                    _buildTip('Avoid blurry or dark images'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: Color(0xFF43A047)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select image. Please try again.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  Future<void> _submitDiagnosis() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image to diagnose'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Compress image to reduce upload size
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        _selectedImage!.path,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedBytes == null) {
        throw Exception('Failed to compress image');
      }

      // Convert compressed image to base64
      final base64Image = base64Encode(compressedBytes);

      // Create diagnosis request
      final request = CreateDiagnosisRequest(
        farmId: _selectedFarmId!,
        imageBase64: base64Image,
        cropType: _selectedCropType,
      );

      // Submit diagnosis
      final repository = ref.read(diagnosisRepositoryProvider);
      await repository.createDiagnosis(request);

      // Refresh diagnosis list
      ref.invalidate(diagnosisListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diagnosis submitted successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit diagnosis. Please try again.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
