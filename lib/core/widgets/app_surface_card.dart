import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Enterprise standardized surface card widget for AgriEtech UI
class AppSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final Clip clipBehavior;
  final bool isGlass;
  final Color? glowColor;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.shadows,
    this.gradient,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
    this.isGlass = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? AppRadii.lg;
    final roundedBorder = BorderRadius.all(Radius.circular(radius));

    Color effectiveBg;
    if (backgroundColor != null) {
      effectiveBg = backgroundColor!;
    } else if (isGlass) {
      effectiveBg = isDark ? AppTheme.glassDark : AppTheme.glassLight;
    } else {
      effectiveBg = isDark ? AppTheme.cardDark : AppTheme.cardLight;
    }

    Color effectiveBorderColor;
    if (borderColor != null) {
      effectiveBorderColor = borderColor!;
    } else if (isGlass) {
      effectiveBorderColor = isDark ? AppTheme.glassBorderDark : AppTheme.glassBorderLight;
    } else if (glowColor != null) {
      effectiveBorderColor = glowColor!.withValues(alpha: 0.4);
    } else {
      effectiveBorderColor = isDark ? AppTheme.borderDark : AppTheme.borderLight;
    }

    List<BoxShadow> effectiveShadows;
    if (shadows != null) {
      effectiveShadows = shadows!;
    } else if (glowColor != null) {
      effectiveShadows = AppShadows.glow(glowColor!);
    } else {
      effectiveShadows = isDark ? AppShadows.soft(isDark: true) : AppShadows.card(isDark: false);
    }

    Widget contentBox = Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBg : null,
        gradient: gradient,
        borderRadius: roundedBorder,
        border: Border.all(color: effectiveBorderColor, width: 1),
        boxShadow: effectiveShadows,
      ),
      child: child,
    );

    Widget content = isGlass
        ? ClipRRect(
            borderRadius: roundedBorder,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: contentBox,
            ),
          )
        : contentBox;

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: roundedBorder,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          borderRadius: roundedBorder,
          child: content,
        ),
      );
    }

    if (margin != EdgeInsets.zero) {
      content = Padding(padding: margin, child: content);
    }

    return content;
  }
}


