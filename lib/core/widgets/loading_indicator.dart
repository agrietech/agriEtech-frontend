import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppLoadingSize { small, medium, large }

/// Standardized enterprise loading indicator for AgriEtech Platform
class AppLoadingIndicator extends StatelessWidget {
  final AppLoadingSize size;
  final String? message;
  final Color? color;
  final double? strokeWidth;

  const AppLoadingIndicator({
    super.key,
    this.size = AppLoadingSize.medium,
    this.message,
    this.color,
    this.strokeWidth,
  });

  const AppLoadingIndicator.small({
    super.key,
    this.message,
    this.color,
    this.strokeWidth = 2.0,
  }) : size = AppLoadingSize.small;

  const AppLoadingIndicator.large({
    super.key,
    this.message,
    this.color,
    this.strokeWidth = 3.5,
  }) : size = AppLoadingSize.large;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double dimension;
    double defaultStroke;
    switch (size) {
      case AppLoadingSize.small:
        dimension = 18.0;
        defaultStroke = 2.0;
        break;
      case AppLoadingSize.large:
        dimension = 44.0;
        defaultStroke = 3.5;
        break;
      case AppLoadingSize.medium:
        dimension = 28.0;
        defaultStroke = 2.5;
        break;
    }


    final spinner = SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth ?? defaultStroke,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
        backgroundColor: effectiveColor.withValues(alpha: 0.15),
      ),
    );

    if (message == null) {
      return Center(child: spinner);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          spinner,
          const SizedBox(height: AppSpacing.sm),
          Text(
            message!,
            style: TextStyle(
              fontSize: size == AppLoadingSize.small ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Backward compatibility alias
typedef LoadingIndicator = AppLoadingIndicator;

