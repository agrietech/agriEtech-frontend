import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/disease_result_model.dart';
import '../../../../core/l10n/app_localizations.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  final DiseaseResultModel result;
  
  const DiagnosisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('diagnosis_result')),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Disease name card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      result.diseaseDetected == 'Healthy' || result.diseaseDetected == 'No Disease'
                          ? Icons.check_circle
                          : Icons.warning,
                      size: 64,
                      color: result.diseaseDetected == 'Healthy' || result.diseaseDetected == 'No Disease'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.diseaseDetected,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (result.confidence != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.translate('confidence')}: ${(result.confidence! * 100).toStringAsFixed(1)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: result.confidence,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          result.confidence! > 0.7 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            if (result.description != null) ...[
              _buildSection(
                title: l10n.translate('description'),
                icon: Icons.description,
                child: Text(
                  result.description!,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recommendations
            if (result.recommendations != null && result.recommendations!.isNotEmpty) ...[
              _buildSection(
                title: l10n.translate('recommendations'),
                icon: Icons.lightbulb,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.recommendations!
                      .map((rec) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rec,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Treatment
            if (result.treatment != null) ...[
              _buildSection(
                title: l10n.translate('treatment'),
                icon: Icons.medical_services,
                child: Text(
                  result.treatment!,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetaRow(
                      icon: Icons.grass,
                      label: l10n.translate('crop_type'),
                      value: result.cropType,
                    ),
                    const Divider(height: 24),
                    _buildMetaRow(
                      icon: Icons.calendar_today,
                      label: l10n.translate('date'),
                      value: _formatDate(result.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: Text(l10n.translate('diagnose_another')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
