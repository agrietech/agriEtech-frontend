import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/role_utils.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../core/utils/date_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/diagnosis_models.dart';
import '../providers/diagnosis_provider.dart';
import '../widgets/diagnosis_card.dart';
import '../widgets/diagnosis_statistics_card.dart';
import 'create_diagnosis_screen.dart';

class DiagnosisListScreen extends ConsumerWidget {
  const DiagnosisListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diagnosesAsync = ref.watch(diagnosisListProvider);
    final statistics = ref.watch(diagnosisStatisticsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Diagnosis'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(diagnosisListProvider.notifier).refresh();
              ref.invalidate(diagnosisStatisticsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_off),
            tooltip: 'Clear Filters',
            onPressed: () {
              ref.read(diagnosisListProvider.notifier).clearFilters();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(diagnosisListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Statistics Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DiagnosisStatisticsCard(statistics: statistics),
              ),
            ),

            // Diagnosis List
            diagnosesAsync.when(
              data: (diagnoses) {
                if (diagnoses.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateView(
                      icon: Icons.biotech_outlined,
                      title: 'No Plant Health Scans',
                      message: 'Take or upload photos of crop leaves displaying lesions, rust, or discoloration to receive instant AI pathogen diagnosis and organic treatment protocols.',
                      actionLabel: 'Scan Crop Leaf',
                      onAction: () => context.push('/diagnosis/create'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final diagnosis = diagnoses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: DiagnosisCard(
                            diagnosis: diagnosis,
                            onTap: () => _showDiagnosisDetails(
                              context,
                              diagnosis,
                            ),
                          ),
                        );
                      },
                      childCount: diagnoses.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: ListSkeleton(count: 3),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: AppErrorView(
                  icon: Icons.biotech_rounded,
                  title: 'Failed to load diagnoses',
                  message: error.toString(),
                  onRetry: () => ref.read(diagnosisListProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleUtils.canCreateDiagnosis(user?.role)
          ? FloatingActionButton.extended(
              heroTag: 'fab_diagnosis_list',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDiagnosisScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('New Diagnosis'),
            )
          : null,
    );
  }

  void _showDiagnosisDetails(BuildContext context, DiagnosisModel diagnosis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  diagnosis.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status
              _buildDetailRow(
                context,
                'Status',
                _getStatusDisplay(diagnosis.diagnosisStatus),
                _getStatusColor(diagnosis.diagnosisStatus),
              ),

              if (diagnosis.cropIdentified != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Identified Crop',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  diagnosis.cropIdentifiedAm != null
                      ? '${diagnosis.cropIdentified!} (${diagnosis.cropIdentifiedAm!})'
                      : diagnosis.cropIdentified!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
                ),
              ],

              if (diagnosis.diseaseName != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Disease / Pathogen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  diagnosis.diseaseName!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (diagnosis.diseaseNameAm != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    diagnosis.diseaseNameAm!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
                if (diagnosis.pathogen != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pathogen: ${diagnosis.pathogen}',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                  ),
                ],
              ],

              if (diagnosis.confidenceScore != null) ...[
                const SizedBox(height: 16),
                Text(
                  'AI Confidence Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final rawScore = diagnosis.confidenceScore ?? 0.94;
                    final pct = rawScore > 1.0 ? rawScore : rawScore * 100.0;
                    return Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (pct / 100.0).clamp(0.0, 1.0),
                            backgroundColor: Colors.grey[200],
                            color: pct >= 80 ? Colors.green : (pct >= 60 ? Colors.orange : Colors.red),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ],

              if (diagnosis.treatment != null || diagnosis.treatmentAm != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Recommended Treatment (ህክምና)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (diagnosis.treatmentEn != null || diagnosis.treatment != null)
                        Text(
                          diagnosis.treatmentEn ?? diagnosis.treatment!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), height: 1.4),
                        ),
                      if (diagnosis.treatmentAm != null) ...[
                        const Divider(height: 16),
                        Text(
                          diagnosis.treatmentAm!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (diagnosis.preventionTips != null || diagnosis.preventionAm != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Prevention Guidelines (መከላከያ ዘዴዎች)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFCE8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFEF08A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (diagnosis.preventionEn != null || diagnosis.preventionTips != null)
                        Text(
                          diagnosis.preventionEn ?? diagnosis.preventionTips!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF713F12), height: 1.4),
                        ),
                      if (diagnosis.preventionAm != null) ...[
                        const Divider(height: 16),
                        Text(
                          diagnosis.preventionAm!,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF713F12), fontWeight: FontWeight.w600, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Metadata
              if (diagnosis.farm != null)
                _buildDetailRow(
                  context,
                  'Farm',
                  diagnosis.farm!.farmName,
                  null,
                ),
              _buildDetailRow(
                context,
                'Date',
                DateFormatter.formatDateTime(
                    DateTime.tryParse(diagnosis.createdAt) ?? DateTime.now()),
                null,
              ),
              if (diagnosis.aiModel != null)
                _buildDetailRow(
                  context,
                  'AI Engine',
                  diagnosis.aiModel!,
                  null,
                ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
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
}
