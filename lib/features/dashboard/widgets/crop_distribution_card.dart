import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/dashboard_models.dart';

/// Card showing distribution of cultivated crops across registered farms
class CropDistributionCard extends StatelessWidget {
  final FarmSummary farmSummary;

  const CropDistributionCard({
    super.key,
    required this.farmSummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final crops = farmSummary.cropDistribution ?? {
      'WHEAT': 6,
      'TEFF': 4,
      'MAIZE': 3,
      'BARLEY': 2,
      'PULSES': 1,
    };

    final totalCount = crops.values.fold(0, (sum, count) => sum + count);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/farms'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pie_chart_outline,
                          size: 18,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active Crop Distribution',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${crops.length} primary varieties across ${farmSummary.totalFarms > 0 ? farmSummary.totalFarms : totalCount} registered farm plots',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),

              // Segmented Proportional Progress Bar
              if (totalCount > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: crops.entries.map((entry) {
                        final flex = (entry.value / totalCount * 100).round();
                        return Expanded(
                          flex: flex > 0 ? flex : 1,
                          child: Container(
                            color: _getCropColor(entry.key),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 14),

              // Crop Legend Pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: crops.entries.map((entry) {
                  final color = _getCropColor(entry.key);
                  final pct = totalCount > 0 ? (entry.value / totalCount * 100).round() : 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatCropName(entry.key),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCropColor(String cropKey) {
    switch (cropKey.toUpperCase()) {
      case 'WHEAT':
        return const Color(0xFFD97706); // Amber gold
      case 'TEFF':
        return const Color(0xFF92400E); // Warm brown
      case 'MAIZE':
        return const Color(0xFFEAB308); // Golden yellow
      case 'BARLEY':
        return const Color(0xFF0D9488); // Teal green
      case 'COFFEE':
        return const Color(0xFF78350F); // Deep roast
      case 'PULSES':
      case 'LEGUMES':
        return const Color(0xFF16A34A); // Emerald green
      case 'ENSET':
        return const Color(0xFF15803D); // Forest green
      default:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  String _formatCropName(String cropKey) {
    switch (cropKey.toUpperCase()) {
      case 'WHEAT':
        return 'Wheat (ስንዴ)';
      case 'TEFF':
        return 'Teff (ጤፍ)';
      case 'MAIZE':
        return 'Maize (በቆሎ)';
      case 'BARLEY':
        return 'Barley (ገብስ)';
      case 'COFFEE':
        return 'Coffee (ቡና)';
      case 'ENSET':
        return 'Enset (እንሰት)';
      case 'PULSES':
        return 'Pulses (ጥራጥሬ)';
      default:
        return cropKey[0].toUpperCase() + cropKey.substring(1).toLowerCase();
    }
  }
}
