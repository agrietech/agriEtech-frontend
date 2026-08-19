import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../providers/disease_provider.dart';
import '../../../../core/l10n/app_localizations.dart';

class LeafPhotoCaptureScreen extends ConsumerStatefulWidget {
  final String? farmId;
  
  const LeafPhotoCaptureScreen({super.key, this.farmId});

  @override
  ConsumerState<LeafPhotoCaptureScreen> createState() => _LeafPhotoCaptureScreenState();
}

class _LeafPhotoCaptureScreenState extends ConsumerState<LeafPhotoCaptureScreen> {
  File? _imageFile;
  final _imagePicker = ImagePicker();
  final _cropTypeController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isAnalyzing = false;

  final List<String> _ethiopianCrops = [
    'Teff',
    'Wheat',
    'Barley',
    'Maize',
    'Sorghum',
    'Coffee',
    'Potato',
    'Tomato',
    'Onion',
    'Cabbage',
  ];

  @override
  void dispose() {
    _cropTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _analyzePlant() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    if (_cropTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop type')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Convert image to base64
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Call diagnosis API
      final result = await ref.read(diseaseProviderProvider.notifier).diagnosePlant(
        base64Image: base64Image,
        cropType: _cropTypeController.text,
        farmId: widget.farmId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        // Navigate to results screen
        context.go('/diagnosis-result', extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('disease_diagnosis')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('take_photo_instruction'),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Image source buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(l10n.translate('camera')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(l10n.translate('gallery')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Crop type dropdown
            DropdownButtonFormField<String>(
              initialValue: _cropTypeController.text.isEmpty ? null : _cropTypeController.text,
              decoration: InputDecoration(
                labelText: l10n.translate('crop_type'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.grass),
              ),
              items: _ethiopianCrops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _cropTypeController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.translate('notes_optional'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.note),
                hintText: l10n.translate('describe_symptoms'),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Analyze button
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzePlant,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l10n.translate('analyze_plant'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
