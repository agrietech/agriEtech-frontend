import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Display variant for the AgriEtech logo
enum LogoVariant {
  /// Vertical layout with hero icon badge and 3-segment wordmark below
  stacked,

  /// Horizontal layout for app bars and headers
  horizontal,

  /// Pure 3-segment "agri" + "E" + "tech" wordmark only (minimalist)
  wordmark,

  /// Compact icon badge only
  iconOnly,
}

/// A bounded, branded logo widget for AgriEtech featuring a 3-segment signature:
/// "agri" (nature/agriculture) + "E" (early warning/innovation) + "tech" (technology)
class AgriEtechLogo extends StatelessWidget {
  final LogoVariant variant;
  final double size;
  final bool showTagline;
  final Color? customTextColor;
  final Color? customEColor;
  final String? customTagline;

  const AgriEtechLogo({
    super.key,
    this.variant = LogoVariant.stacked,
    this.size = 72,
    this.showTagline = true,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  });

  /// Factory constructor for hero stacked logo (Hero splash / Auth / Onboarding)
  const AgriEtechLogo.hero({
    super.key,
    this.size = 96,
    this.showTagline = true,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.stacked;

  /// Factory constructor for standard cards and dialogs
  const AgriEtechLogo.standard({
    super.key,
    this.size = 64,
    this.showTagline = true,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.stacked;

  /// Factory constructor for hero stacked logo
  const AgriEtechLogo.stacked({
    super.key,
    this.size = 72,
    this.showTagline = true,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.stacked;

  /// Factory constructor for horizontal app bar logo
  const AgriEtechLogo.horizontal({
    super.key,
    this.size = 48,
    this.showTagline = false,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.horizontal;

  /// Factory constructor for compact navbar / header branding
  const AgriEtechLogo.appBar({
    super.key,
    this.size = 38,
    this.showTagline = false,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.horizontal;

  /// Factory constructor for wordmark-only (pure 3-segment design)
  const AgriEtechLogo.wordmark({
    super.key,
    this.size = 32,
    this.showTagline = false,
    this.customTextColor,
    this.customEColor,
    this.customTagline,
  }) : variant = LogoVariant.wordmark;

  /// Factory constructor for compact icon badge
  const AgriEtechLogo.iconOnly({
    super.key,
    this.size = 48,
  })  : variant = LogoVariant.iconOnly,
        showTagline = false,
        customTextColor = null,
        customEColor = null,
        customTagline = null;

  /// Factory constructor for micro favicon / badge
  const AgriEtechLogo.compact({
    super.key,
    this.size = 28,
  })  : variant = LogoVariant.iconOnly,
        showTagline = false,
        customTextColor = null,
        customEColor = null,
        customTagline = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (variant) {
      case LogoVariant.iconOnly:
        return _buildIconBadge(size, isDark);
      case LogoVariant.wordmark:
        return _buildWordmark(fontSize: size, isDark: isDark);
      case LogoVariant.horizontal:
        return _buildHorizontalLayout(context, isDark);
      case LogoVariant.stacked:
        return _buildStackedLayout(context, isDark);
    }
  }

  /// Builds the custom vector-drawn Ethiopian Agricultural & Tech Emblem
  Widget _buildIconBadge(double badgeSize, bool isDark) {
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0D2818), Color(0xFF1B5E20), Color(0xFF0F381E)]
              : const [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF14532D)],
        ),
        borderRadius: BorderRadius.circular(badgeSize * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: isDark ? 0.4 : 0.28),
            blurRadius: badgeSize * 0.25,
            offset: Offset(0, badgeSize * 0.1),
          ),
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            blurRadius: badgeSize * 0.15,
            offset: Offset(0, -badgeSize * 0.02),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(badgeSize * 0.26),
        child: CustomPaint(
          size: Size(badgeSize, badgeSize),
          painter: _EthiopianAgriEmblemPainter(),
        ),
      ),
    );
  }

  /// Builds the 3-segment typography wordmark: [agri] + [E] + [tech]
  Widget _buildWordmark({
    required double fontSize,
    required bool isDark,
  }) {
    // 1. "agri" - Deep Organic Forest Green
    final agriColor = customTextColor ?? (isDark ? const Color(0xFFC8E6C9) : const Color(0xFF1B5E20));

    // 2. "E" - Golden Amber Innovation Accent
    final eColor = customEColor ?? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100));

    // 3. "tech" - Vibrant Agricultural Emerald Green
    final techColor = customTextColor ?? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32));

    return RichText(
      text: TextSpan(
        children: [
          // Segment 1: agri
          TextSpan(
            text: 'agri',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: agriColor,
              letterSpacing: -0.6,
            ),
          ),
          // Segment 2: E (Highlighted capital)
          TextSpan(
            text: 'E',
            style: TextStyle(
              fontSize: fontSize * 1.06,
              fontWeight: FontWeight.w900,
              color: eColor,
              letterSpacing: -0.2,
            ),
          ),
          // Segment 3: tech
          TextSpan(
            text: 'tech',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: techColor,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the subtitle tagline badge
  Widget _buildTaglineBadge(bool isDark) {
    final tagline = customTagline ?? 'EARLY WARNING PLATFORM';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2E1E)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2E7D32).withValues(alpha: 0.5)
              : const Color(0xFF81C784).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Text(
        tagline,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  /// Stacked layout (Centered hero branding)
  Widget _buildStackedLayout(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBadge(size, isDark),
        SizedBox(height: size * 0.2),
        _buildWordmark(
          fontSize: size * 0.42,
          isDark: isDark,
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          _buildTaglineBadge(isDark),
        ],
      ],
    );
  }

  /// Horizontal layout (Navbar / AppBar compact branding)
  Widget _buildHorizontalLayout(BuildContext context, bool isDark) {
    final badgeSize = size * 0.7;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIconBadge(badgeSize, isDark),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWordmark(
              fontSize: badgeSize * 0.62,
              isDark: isDark,
            ),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                customTagline ?? 'Early Warning Platform',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Custom Vector Painter rendering an authentic Ethiopian Agricultural, Cultural & Technological Emblem:
/// 1. Golden Teff & Wheat Sheaf (Rich Cereal Agronomy)
/// 2. Selit (Sesame Pod & Grain Cluster - World-Renowned Ethiopian Export)
/// 3. Blue Nile River (Abay - Life-Giving Water & Basin Valley)
/// 4. Ethiopian Emerald Coffee Leaf with Ruby Cherries (Buna Birthplace)
/// 5. Radiant Aksumite Sunburst & Stepped Geometry (Millennia of Civilization)
/// 6. AgTech Early-Warning Orbital Waves & Telemetry Core (Predictive Intelligence)
class _EthiopianAgriEmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Background Aksumite Solar Geometric Rays (Millennia Civilization)
    final rayPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.14)
      ..strokeWidth = 1.2
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final p1 = Offset(
        center.dx + (w * 0.12) * math.cos(angle),
        center.dy + (h * 0.12) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (w * 0.46) * math.cos(angle),
        center.dy + (h * 0.46) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, rayPaint);
    }

    // 2. Terraced Highland Hills & Valleys (Base Ethiopian Terrain)
    final hillPath = Path();
    hillPath.moveTo(0, h);
    hillPath.lineTo(0, h * 0.70);
    hillPath.quadraticBezierTo(w * 0.32, h * 0.58, w * 0.62, h * 0.72);
    hillPath.quadraticBezierTo(w * 0.82, h * 0.80, w, h * 0.68);
    hillPath.lineTo(w, h);
    hillPath.close();

    final hillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F381E), Color(0xFF1B5E20), Color(0xFF0B2912)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.58, w, h * 0.42));

    canvas.drawPath(hillPath, hillPaint);

    // 3. The Blue Nile (Abay) River & Great Basin Waters
    final riverPath = Path();
    riverPath.moveTo(w * 0.28, h * 0.62);
    riverPath.cubicTo(
      w * 0.42, h * 0.70,
      w * 0.48, h * 0.82,
      w * 0.60, h * 1.00,
    );
    riverPath.lineTo(w * 0.72, h * 1.00);
    riverPath.cubicTo(
      w * 0.58, h * 0.82,
      w * 0.50, h * 0.68,
      w * 0.36, h * 0.62,
    );
    riverPath.close();

    final riverPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.28, h * 0.62, w * 0.44, h * 0.38))
      ..style = PaintingStyle.fill;

    canvas.drawPath(riverPath, riverPaint);

    // 4. Golden Teff & Wheat Ear (Left Curve)
    final grainPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE082), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(w * 0.44, h * 0.88);
    stemPath.quadraticBezierTo(w * 0.38, h * 0.54, w * 0.28, h * 0.22);
    canvas.drawPath(stemPath, stemPaint);

    // Teff / Wheat kernels along the stalk
    final grainOffsets = [
      Offset(w * 0.24, h * 0.26),
      Offset(w * 0.33, h * 0.31),
      Offset(w * 0.22, h * 0.37),
      Offset(w * 0.36, h * 0.43),
      Offset(w * 0.25, h * 0.49),
      Offset(w * 0.40, h * 0.55),
      Offset(w * 0.30, h * 0.62),
    ];

    for (int i = 0; i < grainOffsets.length; i++) {
      final p = grainOffsets[i];
      final grainSize = w * (0.052 + (i * 0.004));
      final isRightSide = i % 2 == 1;

      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(isRightSide ? 0.45 : -0.55);

      final grainOval = Rect.fromCenter(
        center: Offset.zero,
        width: grainSize * 1.8,
        height: grainSize * 0.85,
      );
      canvas.drawOval(grainOval, grainPaint);
      canvas.restore();
    }

    // 5. Selit (Sesame Pod & Seeds - Humera / Gondar Gold)
    final selitPodPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFCA8A04)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.16, h * 0.50, w * 0.16, h * 0.24))
      ..style = PaintingStyle.fill;

    // Sesame capsule pod
    final selitPath = Path();
    selitPath.moveTo(w * 0.22, h * 0.72);
    selitPath.quadraticBezierTo(w * 0.14, h * 0.60, w * 0.20, h * 0.48);
    selitPath.quadraticBezierTo(w * 0.26, h * 0.60, w * 0.22, h * 0.72);
    selitPath.close();
    canvas.drawPath(selitPath, selitPodPaint);

    // Individual Sesame Seeds
    final seedPaint = Paint()
      ..color = const Color(0xFFFFFBEB)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.19, h * 0.54), width: w * 0.035, height: w * 0.02),
      seedPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.21, h * 0.62), width: w * 0.035, height: w * 0.02),
      seedPaint,
    );

    // 6. Ethiopian Emerald Coffee Leaf with Ruby Cherries (Buna Heritage)
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4ADE80), Color(0xFF16A34A), Color(0xFF15803D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(w * 0.45, h * 0.3, w * 0.45, h * 0.5))
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    leafPath.moveTo(w * 0.50, h * 0.72);
    leafPath.cubicTo(
      w * 0.58, h * 0.58,
      w * 0.82, h * 0.48,
      w * 0.80, h * 0.34,
    );
    leafPath.cubicTo(
      w * 0.68, h * 0.38,
      w * 0.54, h * 0.52,
      w * 0.50, h * 0.72,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // Leaf Vein
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final veinPath = Path();
    veinPath.moveTo(w * 0.52, h * 0.70);
    veinPath.quadraticBezierTo(w * 0.66, h * 0.50, w * 0.78, h * 0.36);
    canvas.drawPath(veinPath, veinPaint);

    // Ruby Red Coffee Cherries (Buna Fruit)
    final cherryPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.52, h * 0.64), radius: w * 0.04))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.52, h * 0.64), w * 0.038, cherryPaint);
    canvas.drawCircle(Offset(w * 0.57, h * 0.68), w * 0.034, cherryPaint);

    // 7. AgTech Telemetry & Satellite Orbital Waves (Early Warning)
    final telemetryPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.85)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(
      center: Offset(w * 0.76, h * 0.22),
      radius: w * 0.16,
    );
    canvas.drawArc(arcRect, math.pi * 0.65, math.pi * 0.85, false, telemetryPaint);

    final telemetryInnerPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcInnerRect = Rect.fromCircle(
      center: Offset(w * 0.76, h * 0.22),
      radius: w * 0.09,
    );
    canvas.drawArc(arcInnerRect, math.pi * 0.65, math.pi * 0.85, false, telemetryInnerPaint);

    // 8. Central Beacon Star (Ethiopian Solar / Innovation Core)
    final beaconCenter = Offset(w * 0.76, h * 0.22);
    final beaconGlow = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconCenter, w * 0.08, beaconGlow);

    final beaconCore = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconCenter, w * 0.04, beaconCore);

    final beaconDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconCenter, w * 0.02, beaconDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
