import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/role_utils.dart';
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
        actions: [
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.biotech_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No diagnoses available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload plant images to get started',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
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
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load diagnoses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            ref.read(diagnosisListProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: RoleUtils.canCreateDiagnosis(user?.role)
          ? FloatingActionButton.extended(
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  diagnosis.cropIdentified!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],

              if (diagnosis.diseaseName != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Disease',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  diagnosis.diseaseName!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],

              if (diagnosis.confidenceScore != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Confidence',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: diagnosis.confidenceScore! / 100,
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${diagnosis.confidenceScore!.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],

              if (diagnosis.treatment != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Treatment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    diagnosis.treatment!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],

              if (diagnosis.preventionTips != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Prevention Tips',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    diagnosis.preventionTips!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],

              const SizedBox(height: 24),

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
                    DateTime.parse(diagnosis.createdAt)),
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
