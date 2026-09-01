library error_view;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardized enterprise error presentation view with retry action
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final String? actionLabel;
  final IconData? icon;
  final bool isCompact;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.actionLabel,
    this.icon,
  }) : isCompact = false;

  const AppErrorView.compact({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.actionLabel,
    this.icon,
  }) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isCompact) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.error_outline_rounded,
                size: 28,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
              ],
              Text(
                message,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: Text(actionLabel ?? 'Retry', style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.errorColor.withValues(alpha: isDark ? 0.2 : 0.1),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 38,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title ?? 'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontSize: 13.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(actionLabel ?? 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.roundedMd,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized alias
typedef ErrorView = AppErrorView;

