import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/specimen_leaf_generator.dart';

/// Result returned when a photo/specimen is acquired
class ScannerAcquisitionResult {
  final Uint8List imageBytes;
  final String? suggestedCrop;
  final String sourceLabel;

  const ScannerAcquisitionResult({
    required this.imageBytes,
    this.suggestedCrop,
    required this.sourceLabel,
  });
}

/// Silicon Valley-grade Interactive AI Crop Leaf Camera & Pathology Scanner
class AiLeafScannerModal extends StatefulWidget {
  final ValueChanged<ScannerAcquisitionResult> onImageAcquired;
  final String? initialCropType;

  const AiLeafScannerModal({
    super.key,
    required this.onImageAcquired,
    this.initialCropType,
  });

  /// Static helper to display the scanner modal sheet
  static Future<ScannerAcquisitionResult?> show(BuildContext context, {String? initialCropType}) {
    return showModalBottomSheet<ScannerAcquisitionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiLeafScannerModal(
        initialCropType: initialCropType,
        onImageAcquired: (res) {
          Navigator.of(ctx).pop(res);
        },
      ),
    );
  }

  @override
  State<AiLeafScannerModal> createState() => _AiLeafScannerModalState();
}

class _AiLeafScannerModalState extends State<AiLeafScannerModal>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _laserAnimController;
  late Animation<double> _laserPositionAnim;

  bool _isTorchOn = false;
  bool _isLoading = false;
  String _statusMessage = 'Align crop leaf inside viewfinder reticle';
  CropLeafSpecimen _selectedSpecimen = SpecimenLibrary.specimens.first;

  @override
  void initState() {
    super.initState();
    _laserAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserPositionAnim = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserAnimController.dispose();
    super.dispose();
  }

  /// Check if the current platform supports native hardware camera
  bool get _isNativeMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Capture photo via hardware camera with smart permission and desktop fallback
  Future<void> _captureFromCamera() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _statusMessage = 'Accessing optical camera sensor...';
    });

    try {
      if (_isNativeMobilePlatform) {
        final status = await Permission.camera.request();
        if (status.isPermanentlyDenied) {
          _showSettingsDialog();
          setState(() => _isLoading = false);
          return;
        }
      }

      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 88,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        widget.onImageAcquired(
          ScannerAcquisitionResult(
            imageBytes: bytes,
            suggestedCrop: widget.initialCropType,
            sourceLabel: 'Camera Shutter',
          ),
        );
      } else {
        setState(() {
          _statusMessage = 'Camera acquisition cancelled';
        });
      }
    } catch (e) {
      // Platform without camera hardware or desktop simulator
      setState(() {
        _statusMessage = 'Camera not detected on this device. Fallback to image selector.';
      });
      _fallbackToGalleryOrSpecimen('Hardware camera is not available on this platform/device ($e).');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Pick from gallery or local file system
  Future<void> _pickFromGallery() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _statusMessage = 'Opening local photo gallery...';
    });

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 88,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        widget.onImageAcquired(
          ScannerAcquisitionResult(
            imageBytes: bytes,
            suggestedCrop: widget.initialCropType,
            sourceLabel: 'Photo Gallery',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open image picker: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Instant pathology test using generated agricultural specimen
  Future<void> _acquireSpecimen(CropLeafSpecimen specimen) async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating ${specimen.cropName} pathology specimen...';
    });

    try {
      final bytes = await specimen.generateImageBytes();
      widget.onImageAcquired(
        ScannerAcquisitionResult(
          imageBytes: bytes,
          suggestedCrop: specimen.cropName,
          sourceLabel: 'Specimen: ${specimen.diseaseName}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Specimen generator error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fallbackToGalleryOrSpecimen(String reason) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.camera_indoor, color: Color(0xFF2E7D32)),
            SizedBox(width: 10),
            Text('Camera Sensor Notice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A physical camera sensor is not active on this environment (e.g. desktop simulator or restricted permissions).',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can easily:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text('1. Pick any crop leaf photo from your storage files.\n2. Tap a preloaded Ethiopian disease specimen to test the Dual-AI diagnosis immediately.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _pickFromGallery();
            },
            child: const Text('Open Gallery / Files'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _acquireSpecimen(_selectedSpecimen);
            },
            icon: const Icon(Icons.biotech, size: 16),
            label: const Text('Use Selected Specimen'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera Permission Needed'),
        content: const Text(
          'EthioFarm needs camera access to scan and diagnose plant leaves. Please enable camera access in app settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: mediaQuery.size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner, color: Color(0xFF4ADE80), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Plant Pathology Camera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Dual-AI Optical Analysis (Plant.id & Gemini 2.5)',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    color: _isTorchOn ? Colors.amberAccent : Colors.white60,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isTorchOn = !_isTorchOn);
                  },
                  tooltip: 'Toggle Flash Light',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 20),

          // Main Viewfinder Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                children: [
                  // Viewfinder Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background grid lines
                          CustomPaint(
                            painter: _ViewfinderGridPainter(),
                          ),

                          // Leaf silhouette targeting watermark
                          Center(
                            child: Opacity(
                              opacity: 0.25,
                              child: Icon(
                                Icons.eco,
                                size: 160,
                                color: _selectedSpecimen.primaryColor,
                              ),
                            ),
                          ),

                          // Animated Optical Scanning Laser
                          AnimatedBuilder(
                            animation: _laserPositionAnim,
                            builder: (context, child) {
                              return Positioned(
                                top: _laserPositionAnim.value * 280,
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Color(0xFF4ADE80),
                                        Color(0xFF86EFAC),
                                        Color(0xFF4ADE80),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF4ADE80).withValues(alpha: 0.6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // HUD Corner Targeting Reticles
                          const Positioned(
                            top: 18,
                            left: 18,
                            child: _CornerBracket(top: true, left: true),
                          ),
                          const Positioned(
                            top: 18,
                            right: 18,
                            child: _CornerBracket(top: true, left: false),
                          ),
                          const Positioned(
                            bottom: 18,
                            left: 18,
                            child: _CornerBracket(top: false, left: true),
                          ),
                          const Positioned(
                            bottom: 18,
                            right: 18,
                            child: _CornerBracket(top: false, left: false),
                          ),

                          // Central Focus Crosshair
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF4ADE80).withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Status banner overlay
                          Positioned(
                            bottom: 14,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF4ADE80),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.info_outline, color: Color(0xFF4ADE80), size: 14),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _statusMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Specimen Rapid-Testing Carousel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.biotech, color: Color(0xFF86EFAC), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Ethiopian Crop Specimens (Fast Test):',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${SpecimenLibrary.specimens.length} Available',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: SpecimenLibrary.specimens.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final spec = SpecimenLibrary.specimens[index];
                final isSelected = spec.id == _selectedSpecimen.id;
                return ActionChip(
                  avatar: Icon(
                    spec.id == 'healthy_leaf' ? Icons.check_circle_outline : Icons.coronavirus_outlined,
                    size: 14,
                    color: isSelected ? Colors.white : const Color(0xFF86EFAC),
                  ),
                  label: Text(
                    '${spec.cropName} (${spec.cropNameAm})',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4ADE80) : Colors.white12,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSpecimen = spec);
                    _acquireSpecimen(spec);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Control Panel: Gallery, Big Shutter Capture, Specimen Run
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.photo_library_outlined, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: _isLoading ? null : _pickFromGallery,
                      tooltip: 'Choose from Gallery',
                    ),
                    const SizedBox(height: 4),
                    const Text('Gallery', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),

                // Center Main Shutter Capture Button
                GestureDetector(
                  onTap: _isLoading ? null : _captureFromCamera,
                  child: Container(
                    width: 76,
                    height: 76,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF4ADE80), width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ADE80).withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF1E293B),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Specimen Quick-Scan Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.biotech_outlined, color: Color(0xFF86EFAC)),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: _isLoading ? null : () => _acquireSpecimen(_selectedSpecimen),
                      tooltip: 'Use Selected Specimen',
                    ),
                    const SizedBox(height: 4),
                    const Text('Specimen', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// HUD Corner Bracket Reticle
class _CornerBracket extends StatelessWidget {
  final bool top;
  final bool left;

  const _CornerBracket({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: Color(0xFF4ADE80), width: 3) : BorderSide.none,
          bottom: !top ? const BorderSide(color: Color(0xFF4ADE80), width: 3) : BorderSide.none,
          left: left ? const BorderSide(color: Color(0xFF4ADE80), width: 3) : BorderSide.none,
          right: !left ? const BorderSide(color: Color(0xFF4ADE80), width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}

/// Viewfinder Rule-of-Thirds Grid Painter
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    final dx = size.width / 3;
    final dy = size.height / 3;

    canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    canvas.drawLine(Offset(dx * 2, 0), Offset(dx * 2, size.height), paint);
    canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    canvas.drawLine(Offset(0, dy * 2), Offset(size.width, dy * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
