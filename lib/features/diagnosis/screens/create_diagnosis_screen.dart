import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
            // Image Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plant Image',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    if (_selectedImage != null) ...[
                      // Display selected image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Change image button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showImageSourceDialog(),
                          icon: const Icon(Icons.image),
                          label: const Text('Change Image'),
                        ),
                      ),
                    ] else ...[
                      // Image selection buttons
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select an image to diagnose',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),

                      if (_selectedImage == null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '* Image is required',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
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
