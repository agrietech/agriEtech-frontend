import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/risk_provider.dart';
import '../models/risk_models.dart';
import '../widgets/risk_assessment_card.dart';
import '../../../core/utils/date_formatter.dart';

class RiskMapScreen extends ConsumerStatefulWidget {
  const RiskMapScreen({super.key});

  @override
  ConsumerState<RiskMapScreen> createState() => _RiskMapScreenState();
}

class _RiskMapScreenState extends ConsumerState<RiskMapScreen> {
  String? _selectedHazardFilter;
  String? _selectedRiskFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(riskAssessmentsProvider.notifier).loadAssessments();
    });
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.deepOrange;
      case 'MODERATE':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getHazardIcon(String hazardType) {
    switch (hazardType.toUpperCase()) {
      case 'DROUGHT':
        return Icons.water_drop_outlined;
      case 'FLOOD':
        return Icons.flood;
      case 'LOCUST_PEST':
        return Icons.bug_report;
      case 'VEGETATION_STRESS':
        return Icons.grass;
      case 'FROST':
        return Icons.ac_unit;
      case 'HEAT_STRESS':
        return Icons.wb_sunny;
      default:
        return Icons.warning;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Risk Data',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Hazard type filter
                  Text(
                    'Hazard Type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedHazardFilter == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedHazardFilter = null);
                          setState(() => _selectedHazardFilter = null);
                          ref.read(riskAssessmentsProvider.notifier).loadAssessments();
                        },
                      ),
                      ...HazardTypeUtils.allHazardTypes.map((hazardType) {
                        return FilterChip(
                          label: Text(HazardTypeUtils.getDisplayName(hazardType)),
                          selected: _selectedHazardFilter == hazardType,
                          onSelected: (selected) {
                            setModalState(() => _selectedHazardFilter = selected ? hazardType : null);
                            setState(() => _selectedHazardFilter = selected ? hazardType : null);
                            ref.read(riskAssessmentsProvider.notifier).loadAssessments(
                              hazardType: _selectedHazardFilter,
                              riskLevel: _selectedRiskFilter,
                            );
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Risk level filter
                  Text(
                    'Risk Level',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedRiskFilter == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedRiskFilter = null);
                          setState(() => _selectedRiskFilter = null);
                          ref.read(riskAssessmentsProvider.notifier).loadAssessments();
                        },
                      ),
                      ...['LOW', 'MODERATE', 'HIGH', 'CRITICAL'].map((riskLevel) {
                        return FilterChip(
                          label: Text(RiskLevelUtils.getDisplayName(riskLevel)),
                          selected: _selectedRiskFilter == riskLevel,
                          onSelected: (selected) {
                            setModalState(() => _selectedRiskFilter = selected ? riskLevel : null);
                            setState(() => _selectedRiskFilter = selected ? riskLevel : null);
                            ref.read(riskAssessmentsProvider.notifier).loadAssessments(
                              hazardType: _selectedHazardFilter,
                              riskLevel: _selectedRiskFilter,
                            );
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final riskState = ref.watch(riskAssessmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risk Map'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: riskState.isLoading
                ? null
                : () => ref.read(riskAssessmentsProvider.notifier).refreshAssessments(),
          ),
        ],
      ),
      body: _buildBody(context, riskState),
    );
  }

  Widget _buildBody(BuildContext context, RiskAssessmentsState state) {
    final theme = Theme.of(context);

    if (state.isLoading && !state.hasAssessments) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading risk data...'),
          ],
        ),
      );
    }

    if (state.hasError && !state.hasAssessments) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load risk data',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.message ?? 'Unknown error',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.read(riskAssessmentsProvider.notifier).loadAssessments(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary cards
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.primaryColor.withValues(alpha: 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                icon: Icons.assessment,
                label: 'Total',
                value: state.assessments.length.toString(),
                color: theme.primaryColor,
              ),
              _StatCard(
                icon: Icons.dangerous,
                label: 'Critical',
                value: state.riskLevelCounts['CRITICAL']?.toString() ?? '0',
                color: Colors.red,
              ),
              _StatCard(
                icon: Icons.error,
                label: 'High',
                value: state.riskLevelCounts['HIGH']?.toString() ?? '0',
                color: Colors.deepOrange,
              ),
              _StatCard(
                icon: Icons.warning,
                label: 'Moderate',
                value: state.riskLevelCounts['MODERATE']?.toString() ?? '0',
                color: Colors.orange,
              ),
            ],
          ),
        ),

        // Risk assessments list
        Expanded(
          child: state.assessments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No risk assessments found',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(riskAssessmentsProvider.notifier).refreshAssessments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.assessments.length,
                    itemBuilder: (context, index) {
                      final assessment = state.assessments[index];
                      return RiskAssessmentCard(
                        assessment: assessment,
                        onTap: () => _showAssessmentDetails(assessment),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _showAssessmentDetails(RiskAssessment assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getRiskColor(assessment.riskLevel).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getHazardIcon(assessment.hazardType),
                          color: _getRiskColor(assessment.riskLevel),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              HazardTypeUtils.getDisplayName(assessment.hazardType),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              RiskLevelUtils.getDisplayName(assessment.riskLevel),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _getRiskColor(assessment.riskLevel),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _DetailItem(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: assessment.woreda?.name ?? 'Unknown',
                  ),
                  const SizedBox(height: 12),
                  
                  _DetailItem(
                    icon: Icons.trending_up,
                    label: 'Risk Score',
                    value: '${(assessment.riskScore * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 12),
                  
                  _DetailItem(
                    icon: Icons.verified,
                    label: 'Confidence',
                    value: '${(assessment.confidence * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 12),
                  
                  if (assessment.affectedPopulation != null) ...[
                    _DetailItem(
                      icon: Icons.people,
                      label: 'Affected Population',
                      value: assessment.affectedPopulation!.toString(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  _DetailItem(
                    icon: Icons.access_time,
                    label: 'Assessed',
                    value: DateFormatter.formatDateWithContext(assessment.assessedAt),
                  ),
                  
                  if (assessment.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assessment.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
