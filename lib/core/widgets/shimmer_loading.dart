import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmer gradient effect controller for skeleton placeholder loading
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E3321) : const Color(0xFFE5EBE5);
    final highlightColor = isDark ? const Color(0xFF2A472E) : const Color(0xFFF4F8F4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Standard Skeleton Card Component matching AgriEtech card geometry
class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonCard({
    super.key,
    this.height = 84.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ShimmerLoading(
      child: Container(
        height: height,
        width: width ?? double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3321) : const Color(0xFFE2E8E2),
                borderRadius: AppRadius.radiusMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3321) : const Color(0xFFE2E8E2),
                      borderRadius: AppRadius.radiusSm,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 10,
                    width: 200,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3321) : const Color(0xFFE2E8E2),
                      borderRadius: AppRadius.radiusSm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of Skeleton Cards for full screen list loading
class SkeletonList extends StatelessWidget {
  final int count;
  final double cardHeight;

  const SkeletonList({
    super.key,
    this.count = 5,
    this.cardHeight = 84.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: count,
      itemBuilder: (context, index) => SkeletonCard(height: cardHeight),
    );
  }
}

/// Compatibility aliases for existing screens
class ListSkeleton extends StatelessWidget {
  final int count;
  final double cardHeight;

  const ListSkeleton({
    super.key,
    this.count = 5,
    this.cardHeight = 84.0,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonList(count: count, cardHeight: cardHeight);
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonList(count: 4, cardHeight: 120.0);
  }
}

class WeatherSkeleton extends StatelessWidget {
  const WeatherSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonList(count: 3, cardHeight: 160.0);
  }
}
