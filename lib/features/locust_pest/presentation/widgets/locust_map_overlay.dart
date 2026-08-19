import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/locust_alert_model.dart';

/// Desert Locust Proximity & Swarm Radar Overlay Widget
class LocustMapOverlay extends StatelessWidget {
  final LocustAlertModel? alert;
  final double? distanceKm;
  final String? riskLevel;
  final bool? activeInfestation;

  const LocustMapOverlay({
    super.key,
    this.alert,
    this.distanceKm,
    this.riskLevel,
    this.activeInfestation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dist = alert?.swarmDistanceKm ?? distanceKm ?? 38.5;
    final risk = alert?.riskLevel ?? riskLevel ?? (dist < 50 ? 'HIGH' : 'MODERATE');
    final isInfested = alert?.activeInfestation ?? activeInfestation ?? (dist < 25);
    final source = alert?.swarmSource ?? 'Somali-Ogaden Border';

    final isCritical = dist <= 50;
    final color = isCritical ? const Color(0xFFDC2626) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.radar, size: 20, color: color),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FAO Desert Locust Radar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'Origin: $source',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isInfested ? 'ACTIVE SWARM' : '$risk RISK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _LocustRadarPainter(distanceKm: dist, isAlert: isCritical),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dist.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Proximity to Farm Boundary',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCritical
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isCritical
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFDCFCE7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  size: 18,
                  color: isCritical ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCritical
                        ? 'Swarm within 50 km zone. Immediate biopesticide standby recommended.'
                        : 'Swarm outside 50 km threshold. Regular surveillance active.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCritical ? const Color(0xFF991B1B) : const Color(0xFF166534),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocustRadarPainter extends CustomPainter {
  final double distanceKm;
  final bool isAlert;

  _LocustRadarPainter({required this.distanceKm, required this.isAlert});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 10;

    final ringPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw radar rings (25km, 50km, 100km)
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3.0), ringPaint);
    }

    // Crosshairs
    final crossPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), crossPaint);
    canvas.drawLine(
        Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), crossPaint);

    // Swarm blip
    const blipAngle = math.pi * 0.35;
    final normalizedDist = (distanceKm / 100.0).clamp(0.15, 0.95);
    final blipRadius = maxRadius * normalizedDist;
    final blipOffset = Offset(
      center.dx + blipRadius * math.cos(blipAngle),
      center.dy + blipRadius * math.sin(blipAngle),
    );

    final blipGlow = Paint()
      ..color = (isAlert ? const Color(0xFFDC2626) : const Color(0xFFF59E0B))
          .withValues(alpha: 0.35);
    canvas.drawCircle(blipOffset, 12, blipGlow);

    final blipPaint = Paint()
      ..color = isAlert ? const Color(0xFFDC2626) : const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(blipOffset, 5, blipPaint);
  }

  @override
  bool shouldRepaint(covariant _LocustRadarPainter oldDelegate) =>
      oldDelegate.distanceKm != distanceKm || oldDelegate.isAlert != isAlert;
}
