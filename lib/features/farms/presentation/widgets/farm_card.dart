import 'package:flutter/material.dart';
import '../../../../core/models/farm_model.dart';

/// Farm Summary Card Widget
class FarmCard extends StatelessWidget {
  final FarmModel? farm;
  final String? name;
  final String? crop;
  final double? area;
  final String? woreda;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const FarmCard({
    super.key,
    this.farm,
    this.name,
    this.crop,
    this.area,
    this.woreda,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmName = farm?.farmName ?? name ?? 'Haramaya Plot #1';
    final cropType = farm?.primaryCrop ?? crop ?? 'Teff';
    final farmArea = farm?.areaHectares ?? area ?? 2.5;
    final locationName = farm?.woreda?.name ?? woreda ?? 'Haramaya, Oromia';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.place, size: 12, color: Color(0xFF6B7280)),
                            const SizedBox(width: 2),
                            Text(
                              locationName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                    color: Colors.grey.shade600,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBadge(
                  icon: Icons.grass,
                  label: 'Primary Crop',
                  value: cropType,
                  color: const Color(0xFF2E7D32),
                ),
                _buildInfoBadge(
                  icon: Icons.square_foot,
                  label: 'Area',
                  value: '${farmArea.toStringAsFixed(1)} ha',
                  color: const Color(0xFF0284C7),
                ),
                _buildInfoBadge(
                  icon: Icons.shield_outlined,
                  label: 'Risk Status',
                  value: 'Protected',
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
