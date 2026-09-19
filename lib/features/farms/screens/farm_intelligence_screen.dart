import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/repositories/farm_repository.dart';
import '../../../core/widgets/error_view.dart';

final farmIntelligenceProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, farmId) async {
  final repository = ref.watch(farmRepositoryProvider);
  final results = await Future.wait([
    repository.getPlanningData(ApiConstants.farmRotationPlan(farmId)),
    repository.getPlanningData(ApiConstants.farmPlantingCalendar(farmId)),
    repository.getPlanningData(ApiConstants.farmInputRequirements(farmId)),
    repository.getPlanningData(ApiConstants.farmAnalytics(farmId)),
    repository.getPlanningData(ApiConstants.farmBenchmarks(farmId)),
  ]);
  return {
    'rotation': results[0],
    'calendar': results[1],
    'inputs': results[2],
    'analytics': results[3],
    'benchmarks': results[4]
  };
});

class FarmIntelligenceScreen extends ConsumerWidget {
  final String farmId;
  const FarmIntelligenceScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(farmIntelligenceProvider(farmId));
    return Scaffold(
      appBar: AppBar(title: const Text('Farm plan & performance')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
            title: 'Farm intelligence is unavailable',
            message: error.toString(),
            actionLabel: 'Try again',
            onRetry: () => ref.invalidate(farmIntelligenceProvider(farmId))),
        data: (sections) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(farmIntelligenceProvider(farmId)),
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _Section(
                title: 'Crop rotation plan',
                data: sections['rotation'] as Map<String, dynamic>),
            _Section(
                title: 'Planting calendar',
                data: sections['calendar'] as Map<String, dynamic>),
            _Section(
                title: 'Input requirements',
                data: sections['inputs'] as Map<String, dynamic>),
            _Section(
                title: 'Farm performance',
                data: sections['analytics'] as Map<String, dynamic>),
            _Section(
                title: 'Peer benchmarks',
                data: sections['benchmarks'] as Map<String, dynamic>),
          ]),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  const _Section({required this.title, required this.data});
  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((entry) => entry.value != null).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: entries.isEmpty
            ? const [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No data is available yet.'))
              ]
            : entries
                .map((entry) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child:
                        Text('${_label(entry.key)}: ${_format(entry.value)}')))
                .toList(),
      ),
    );
  }

  static String _label(String value) => value
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
      .replaceAll('_', ' ')
      .trim();
  static String _format(dynamic value) =>
      value is Map || value is List ? value.toString() : '$value';
}
