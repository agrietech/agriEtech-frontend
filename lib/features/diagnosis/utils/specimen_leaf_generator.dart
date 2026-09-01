import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Specimen pathology model for demonstration and testing without physical camera
class CropLeafSpecimen {
  final String id;
  final String cropName;
  final String cropNameAm;
  final String diseaseName;
  final String diseaseNameAm;
  final String severity;
  final String description;
  final Color primaryColor;
  final Color lesionColor;

  const CropLeafSpecimen({
    required this.id,
    required this.cropName,
    required this.cropNameAm,
    required this.diseaseName,
    required this.diseaseNameAm,
    required this.severity,
    required this.description,
    required this.primaryColor,
    required this.lesionColor,
  });

  /// Generate high-resolution PNG image bytes for this specimen
  Future<Uint8List> generateImageBytes({int width = 512, int height = 512}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // 1. Background studio matte
    final bgPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

    // 2. Leaf boundary shape
    final leafPaint = Paint()..color = primaryColor;
    final leafPath = Path();
    leafPath.moveTo(width * 0.5, height * 0.1);
    leafPath.quadraticBezierTo(width * 0.85, height * 0.45, width * 0.55, height * 0.88);
    leafPath.quadraticBezierTo(width * 0.5, height * 0.95, width * 0.45, height * 0.88);
    leafPath.quadraticBezierTo(width * 0.15, height * 0.45, width * 0.5, height * 0.1);
    leafPath.close();

    // Draw shadow
    canvas.drawShadow(leafPath, Colors.black, 12.0, true);
    canvas.drawPath(leafPath, leafPaint);

    // 3. Central & Lateral Veins
    final veinPaint = Paint()
      ..color = Colors.lightGreenAccent.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centralVein = Path();
    centralVein.moveTo(width * 0.5, height * 0.1);
    centralVein.lineTo(width * 0.5, height * 0.9);
    canvas.drawPath(centralVein, veinPaint);

    // Lateral veins
    for (int i = 1; i <= 6; i++) {
      final y = height * (0.2 + i * 0.09);
      final veinL = Path()
        ..moveTo(width * 0.5, y)
        ..quadraticBezierTo(width * 0.35, y - 15, width * 0.25, y + 20);
      final veinR = Path()
        ..moveTo(width * 0.5, y)
        ..quadraticBezierTo(width * 0.65, y - 15, width * 0.75, y + 20);
      canvas.drawPath(veinL, veinPaint);
      canvas.drawPath(veinR, veinPaint);
    }

    // 4. Disease Pathological Lesions & Pustules
    final lesionPaint = Paint()..color = lesionColor;
    final haloPaint = Paint()..color = Colors.yellow.shade700.withValues(alpha: 0.4);

    if (id == 'wheat_stripe_rust' || id == 'teff_rust') {
      // Linear stripe pustules
      for (double xOffset in [-40, -15, 10, 35]) {
        for (int j = 0; j < 12; j++) {
          final px = width * 0.5 + xOffset;
          final py = height * (0.25 + j * 0.05);
          canvas.drawOval(
            Rect.fromCenter(center: Offset(px, py), width: 8, height: 18),
            haloPaint,
          );
          canvas.drawOval(
            Rect.fromCenter(center: Offset(px, py), width: 5, height: 12),
            lesionPaint,
          );
        }
      }
    } else if (id == 'maize_lethal_necrosis') {
      // Chlorotic mottling & necrotic patches
      final patches = [
        Offset(width * 0.42, height * 0.35),
        Offset(width * 0.58, height * 0.45),
        Offset(width * 0.38, height * 0.60),
        Offset(width * 0.62, height * 0.65),
      ];
      for (final p in patches) {
        canvas.drawCircle(p, 28, haloPaint);
        canvas.drawCircle(p, 18, lesionPaint);
      }
    } else if (id == 'coffee_leaf_rust') {
      // Powdery orange spots
      final spots = [
        Offset(width * 0.35, height * 0.4),
        Offset(width * 0.65, height * 0.45),
        Offset(width * 0.45, height * 0.6),
        Offset(width * 0.55, height * 0.72),
        Offset(width * 0.38, height * 0.78),
      ];
      for (final s in spots) {
        canvas.drawCircle(s, 22, haloPaint);
        canvas.drawCircle(s, 14, lesionPaint);
      }
    } else if (id == 'tomato_late_blight') {
      // Large dark water-soaked necrotic lesions
      final blights = [
        Offset(width * 0.45, height * 0.42),
        Offset(width * 0.60, height * 0.55),
        Offset(width * 0.35, height * 0.70),
      ];
      for (final b in blights) {
        canvas.drawCircle(b, 35, haloPaint);
        canvas.drawCircle(b, 24, Paint()..color = const Color(0xFF3E2723));
      }
    }

    // 5. Specimen HUD Stamp
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'AGRIETECH AI PATHOLOGY SPECIMEN\n$cropName • $diseaseName',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(16, height - 36));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

/// Standard Ethiopian Agricultural Specimens Library
class SpecimenLibrary {
  static const List<CropLeafSpecimen> specimens = [
    CropLeafSpecimen(
      id: 'wheat_stripe_rust',
      cropName: 'Wheat',
      cropNameAm: 'ስንዴ',
      diseaseName: 'Wheat Stripe Rust (Puccinia striiformis)',
      diseaseNameAm: 'የስንዴ ቢጫ ዝገት በሽታ',
      severity: 'HIGH',
      description: 'Yellow-orange pustules aligned in linear stripes along leaf veins causing severe chlorosis.',
      primaryColor: Color(0xFF43A047),
      lesionColor: Color(0xFFE65100),
    ),
    CropLeafSpecimen(
      id: 'maize_lethal_necrosis',
      cropName: 'Maize',
      cropNameAm: 'በቆሎ',
      diseaseName: 'Maize Lethal Necrosis (MLND)',
      diseaseNameAm: 'የበቆሎ ገዳይ ኔክሮሲስ ቫይረስ',
      severity: 'CRITICAL',
      description: 'Chlorotic mottling and leaf margin necrosis progressing to whole-plant dieback.',
      primaryColor: Color(0xFF558B2F),
      lesionColor: Color(0xFFBF360C),
    ),
    CropLeafSpecimen(
      id: 'coffee_leaf_rust',
      cropName: 'Coffee',
      cropNameAm: 'ቡና',
      diseaseName: 'Coffee Leaf Rust (Hemileia vastatrix)',
      diseaseNameAm: 'የቡና ቅጠል ዝገት (ሄሚሊያ)',
      severity: 'HIGH',
      description: 'Powdery orange-yellow spore lesions on the lower leaf surface with upper chlorotic spots.',
      primaryColor: Color(0xFF2E7D32),
      lesionColor: Color(0xFFFF8F00),
    ),
    CropLeafSpecimen(
      id: 'teff_rust',
      cropName: 'Teff',
      cropNameAm: 'ጤፍ',
      diseaseName: 'Teff Rust (Uromyces eragrostidis)',
      diseaseNameAm: 'የጤፍ ዝገት በሽታ',
      severity: 'MODERATE',
      description: 'Small reddish-brown pustules scattered across thin grass-like teff leaves.',
      primaryColor: Color(0xFF689F38),
      lesionColor: Color(0xFF8D6E63),
    ),
    CropLeafSpecimen(
      id: 'tomato_late_blight',
      cropName: 'Potato / Tomato',
      cropNameAm: 'ድንች / ቲማቲም',
      diseaseName: 'Late Blight (Phytophthora infestans)',
      diseaseNameAm: 'የድንችና ቲማቲም የቅጠል ማረር በሽታ',
      severity: 'HIGH',
      description: 'Dark water-soaked lesions expanding rapidly during cool, humid weather.',
      primaryColor: Color(0xFF388E3C),
      lesionColor: Color(0xFF212121),
    ),
    CropLeafSpecimen(
      id: 'healthy_leaf',
      cropName: 'Barley (Healthy Control)',
      cropNameAm: 'ገብስ (ጤናማ ሰብል)',
      diseaseName: 'Healthy Vigorous Leaf (No Foliar Pathology)',
      diseaseNameAm: 'ጤናማ የገብስ ቅጠል (ምንም ዓይነት በሽታ አልተገኘም)',
      severity: 'NONE',
      description: 'Uniform vibrant green pigmentation with intact vein structure and zero chlorosis.',
      primaryColor: Color(0xFF2E7D32),
      lesionColor: Color(0xFF2E7D32),
    ),
  ];
}
