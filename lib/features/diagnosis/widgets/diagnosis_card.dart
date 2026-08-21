import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/diagnosis_models.dart';

class DiagnosisCard extends StatelessWidget {
  final DiagnosisModel diagnosis;
  final VoidCallback? onTap;

  const DiagnosisCard({
    super.key,
    required this.diagnosis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(diagnosis.diagnosisStatus);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.network(
                    diagnosis.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusDisplay(diagnosis.diagnosisStatus),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop and Disease
                  if (diagnosis.cropIdentified != null) ...[
                    Row(
                      children: [
                        Icon(Icons.grass, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          diagnosis.cropIdentified!,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (diagnosis.diseaseName != null) ...[
                    Text(
                      diagnosis.diseaseName!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B5E20),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (diagnosis.diseaseNameAm != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        diagnosis.diseaseNameAm!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ] else ...[
                    Text(
                      'Diagnosis in progress...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Confidence Score
                  if (diagnosis.confidenceScore != null) ...[
                    Builder(
                      builder: (context) {
                        final rawScore = diagnosis.confidenceScore!;
                        final pct = rawScore > 1.0 ? rawScore : rawScore * 100.0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (pct / 100.0).clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey[200],
                                    color: _getConfidenceColor(pct),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${pct.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ],

                  // Treatment preview
                  if (diagnosis.treatment != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Text(
                        diagnosis.treatment!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Farm and Date
                  Row(
                    children: [
                      if (diagnosis.farm != null) ...[
                        Icon(Icons.agriculture,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            diagnosis.farm!.farmName,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatRelative(
                            DateTime.tryParse(diagnosis.createdAt) ?? DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'SUCCESS':
        return Colors.green;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'SUCCESS':
        return 'Success';
      case 'FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }
}
