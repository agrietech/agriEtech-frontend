import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Enterprise reusable empty state presentation widget with rich visual styling
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = iconColor ?? AppTheme.primaryColor;

    return Center(
      child: SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Halo Icon Badge
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  border: Border.all(
                    color: primary.withValues(alpha: isDark ? 0.35 : 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 46,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : const Color(0xFF1E2E1E),
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  height: 1.45,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Optional Primary Action Button
              if (actionLabel != null && onAction != null)
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(
                    actionLabel!,
                    style: AppTypography.subtitle,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.roundedMd,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Canonical design system alias
typedef AppEmptyStateView = EmptyStateView;
