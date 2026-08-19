import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/models/drought_risk_model.dart';

/// Radial SPI Drought Index Gauge Widget
class DroughtGauge extends StatelessWidget {
  final DroughtRiskModel? riskModel;
  final double? spiValue;
  final String? droughtClass;

  const DroughtGauge({
    super.key,
    this.riskModel,
    this.spiValue,
    this.droughtClass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spi = riskModel?.spiValue ?? spiValue ?? -1.45;
    final classification =
        riskModel?.droughtClass ?? droughtClass ?? _classifySpi(spi);

    final color = _getSpiColor(spi);

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Standardized Precipitation Index (SPI)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  classification,
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
            height: 150,
            child: CustomPaint(
              painter: _SpiGaugePainter(spi: spi),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      spi.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'SPI-30 / SPI-90',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRangeTag('<-2.0 Extreme', const Color(0xFFDC2626)),
              _buildRangeTag('-1.5 Severe', const Color(0xFFF97316)),
              _buildRangeTag('-1.0 Moderate', const Color(0xFFF59E0B)),
              _buildRangeTag('Normal', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  static String _classifySpi(double spi) {
    if (spi <= -2.0) return 'EXTREME DROUGHT';
    if (spi <= -1.5) return 'SEVERE DROUGHT';
    if (spi <= -1.0) return 'MODERATE DROUGHT';
    if (spi < 1.0) return 'NEAR NORMAL';
    return 'WET CONDITIONS';
  }

  static Color _getSpiColor(double spi) {
    if (spi <= -2.0) return const Color(0xFFDC2626);
    if (spi <= -1.5) return const Color(0xFFF97316);
    if (spi <= -1.0) return const Color(0xFFF59E0B);
    if (spi < 1.0) return const Color(0xFF10B981);
    return const Color(0xFF3B82F6);
  }

  Widget _buildRangeTag(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}

class _SpiGaugePainter extends CustomPainter {
  final double spi;

  _SpiGaugePainter({required this.spi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.75);
    final radius = size.height * 0.65;

    const startAngle = math.pi * 0.8;
    const sweepAngle = math.pi * 1.4;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Normalize SPI from [-3.0, 3.0] to [0.0, 1.0]
    final normalized = ((spi + 3.0) / 6.0).clamp(0.0, 1.0);
    final activeSweep = sweepAngle * normalized;

    final activePaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFDC2626), // Extreme Drought
          Color(0xFFF97316), // Severe
          Color(0xFFF59E0B), // Moderate
          Color(0xFF10B981), // Normal
          Color(0xFF3B82F6), // Wet
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpiGaugePainter oldDelegate) =>
      oldDelegate.spi != spi;
}
