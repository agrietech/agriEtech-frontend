import 'package:flutter/material.dart';
import '../models/diagnosis_models.dart';

class DiagnosisStatisticsCard extends StatelessWidget {
  final DiagnosisStatistics statistics;

  const DiagnosisStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diagnosis Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    statistics.total,
                    Colors.blue,
                    Icons.biotech,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Success',
                    statistics.success,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Pending',
                    statistics.pending,
                    Colors.orange,
                    Icons.hourglass_empty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Failed',
                    statistics.failed,
                    Colors.red,
                    Icons.error,
                  ),
                ),
              ],
            ),

            // Crop Distribution (if available)
            if (statistics.byCrop != null && statistics.byCrop!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'By Crop',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statistics.byCrop!.entries
                    .map((entry) => _buildChip(
                          context,
                          entry.key,
                          entry.value,
                          Colors.green,
                        ))
                    .toList(),
              ),
            ],

            // Disease Distribution (if available)
            if (statistics.byDisease != null &&
                statistics.byDisease!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'By Disease',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statistics.byDisease!.entries
                    .map((entry) => _buildChip(
                          context,
                          entry.key,
                          entry.value,
                          Colors.red,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, int count, Color color) {
    return Chip(
      label: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
    );
  }
}
