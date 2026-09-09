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
                child: Column(
                  children: [
                    DiagnosisStatisticsCard(statistics: statistics),
                    const SizedBox(height: 12),
                    _buildLiveTelemetryBanner(context, ref),
                  ],
                ),
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
              onPressed: () => context.push('/diagnosis/create'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('New Diagnosis'),
            )
          : null,
    );
  }

  void _showDiagnosisDetails(BuildContext context, DiagnosisModel diagnosis) {
    context.push('/diagnosis/${diagnosis.id}', extra: diagnosis);
  }

  Widget _buildLiveTelemetryBanner(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(diagnosisTelemetryMetaProvider);
    final DateTime? lastFetched = meta['lastFetched'] as DateTime?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final formattedTime = lastFetched != null
        ? DateFormatter.formatDateTime(lastFetched)
        : 'Connecting to live engine...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142416) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: isDark ? 0.3 : 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stream, size: 16, color: Color(0xFF16A34A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'LIVE TELEMETRY STREAM',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified National Agronomic Pathology & Diagnostic Engine',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Fetched from source: $formattedTime',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync, size: 18, color: Color(0xFF16A34A)),
            tooltip: 'Sync with Live Sources',
            onPressed: () {
              ref.read(diagnosisListProvider.notifier).refresh();
              ref.invalidate(diagnosisStatisticsProvider);
            },
          ),
        ],
      ),
    );
  }
}
