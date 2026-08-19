import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../models/alert_models.dart';
import '../providers/alert_provider.dart';

class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _woredaNameController = TextEditingController();
  final _actionItemsController = TextEditingController();

  String _selectedHazardType = 'DROUGHT';
  String _selectedSeverity = 'HIGH';
  int _priority = 1;
  bool _isSubmitting = false;

  final List<String> _hazardTypes = [
    'DROUGHT',
    'FLOOD',
    'LOCUST_PEST',
    'VEGETATION_STRESS',
    'FROST',
    'HEAT_STRESS',
  ];

  final List<String> _severityLevels = [
    'LOW',
    'MODERATE',
    'HIGH',
    'CRITICAL',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _woredaNameController.dispose();
    _actionItemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Alert'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Alert Type Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Hazard Type
                    DropdownButtonFormField<String>(
                      initialValue: _selectedHazardType,
                      decoration: const InputDecoration(
                        labelText: 'Hazard Type',
                        prefixIcon: Icon(Icons.warning_amber),
                        border: OutlineInputBorder(),
                      ),
                      items: _hazardTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_formatHazardType(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedHazardType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Severity Level
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSeverity,
                      decoration: InputDecoration(
                        labelText: 'Severity Level',
                        prefixIcon: Icon(
                          Icons.signal_cellular_alt,
                          color: _getSeverityColor(_selectedSeverity),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: _severityLevels.map((severity) {
                        return DropdownMenuItem(
                          value: severity,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(severity),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_formatSeverity(severity)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSeverity = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Priority
                    DropdownButtonFormField<int>(
                      initialValue: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.priority_high),
                        border: OutlineInputBorder(),
                        helperText: '1 = Highest, 5 = Lowest',
                      ),
                      items: [1, 2, 3, 4, 5].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text('Priority $priority'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _priority = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Content',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Alert Title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                        helperText: 'Brief headline for the alert',
                      ),
                      maxLength: 100,
                      validator: (value) => Validators.validateRequired(
                        value,
                        'Alert title',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Message
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Alert Message',
                        prefixIcon: Icon(Icons.message),
                        border: OutlineInputBorder(),
                        helperText: 'Detailed warning message',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      maxLength: 500,
                      validator: (value) => Validators.validateRequired(
                        value,
                        'Alert message',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Items
                    TextFormField(
                      controller: _actionItemsController,
                      decoration: const InputDecoration(
                        labelText: 'Action Items (Optional)',
                        prefixIcon: Icon(Icons.checklist),
                        border: OutlineInputBorder(),
                        helperText:
                            'Recommended actions, one per line',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      maxLength: 300,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location (Optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Woreda Name
                    TextFormField(
                      controller: _woredaNameController,
                      decoration: const InputDecoration(
                        labelText: 'Woreda Name',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                        helperText: 'Leave empty for all woredas',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitAlert,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Creating...' : 'Create Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getSeverityColor(_selectedSeverity),
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            const Card(
              color: Color(0xFFE8F5E9),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alert will be dispatched via push notifications and WebSocket to all affected users.',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAlert() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Parse action items
      final actionItems = _actionItemsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final request = CreateAlertRequest(
        hazardType: _selectedHazardType,
        severity: _selectedSeverity,
        headline: _titleController.text.trim(),
        message: _messageController.text.trim(),
        woredaName: _woredaNameController.text.trim().isEmpty
            ? null
            : _woredaNameController.text.trim(),
        actionItems: actionItems,
        priority: _priority,
        language: 'en',
      );

      // Create alert
      final repository = ref.read(alertRepositoryProvider);
      await repository.createAlert(request);

      // Refresh alert list
      ref.invalidate(alertListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert created and dispatched successfully'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create alert: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatSeverity(String severity) {
    return severity[0] + severity.substring(1).toLowerCase();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return const Color(0xFFD32F2F);
      case 'HIGH':
        return const Color(0xFFF4511E);
      case 'MODERATE':
        return const Color(0xFFFB8C00);
      case 'LOW':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }
}
