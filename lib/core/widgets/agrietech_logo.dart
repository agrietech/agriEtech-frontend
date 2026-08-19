import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  /// Builds the stylized bounded emblem
  Widget _buildIconBadge(double badgeSize, bool isDark) {
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF2E7D32), Color(0xFF1B5E20)]
              : const [Color(0xFF43A047), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(badgeSize * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.3 : 0.25),
            blurRadius: badgeSize * 0.2,
            offset: Offset(0, badgeSize * 0.08),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Plant/leaf motif
            Icon(
              Icons.eco,
              size: badgeSize * 0.56,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            // Distinctive golden innovation indicator
            Positioned(
              right: badgeSize * 0.16,
              top: badgeSize * 0.16,
              child: Container(
                width: badgeSize * 0.2,
                height: badgeSize * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB300),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88FFB300),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
