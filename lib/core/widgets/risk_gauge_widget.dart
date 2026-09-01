import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// High-tech animated radial sweep risk & telemetry gauge for AgriEtech
class AppRiskGauge extends StatelessWidget {
  final double value;
  final double maxValue;
  final String label;
  final String unit;
  final String severityText;
  final Color severityColor;
  final double size;
  final List<String>? subMetrics;

  const AppRiskGauge({
    super.key,
    required this.value,
    this.maxValue = 100.0,
    required this.label,
    required this.unit,
    required this.severityText,
    required this.severityColor,
    this.size = 170.0,
    this.subMetrics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 0.72,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: normalized),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size * 0.72),
                    painter: _GaugeArcPainter(
                      progress: animValue,
                      activeColor: severityColor,
                      trackColor: isDark ? const Color(0xFF1B2E1E) : Colors.grey.shade200,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: size * 0.18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1E2E1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          unit,
                          style: TextStyle(
                            fontSize: size * 0.075,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.15),
            borderRadius: AppRadii.roundedPill,
            border: Border.all(color: severityColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                severityText,
                style: TextStyle(
                  color: severityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        if (subMetrics != null && subMetrics!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: subMetrics!.map((metric) {
              return Text(
                metric,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _GaugeArcPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _GaugeArcPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;
    const startAngle = pi * 0.85;
    const sweepTotal = pi * 1.3;
    const strokeWidth = 10.0;

    // Track Arc
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // Active Progress Arc
    if (progress > 0.01) {
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepTotal * progress,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
