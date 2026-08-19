import 'package:flutter/material.dart';

class AlertFilterChips extends StatelessWidget {
  final String? selectedSeverity;
  final String? selectedHazardType;
  final Function(String?) onSeverityChanged;
  final Function(String?) onHazardTypeChanged;

  const AlertFilterChips({
    super.key,
    this.selectedSeverity,
    this.selectedHazardType,
    required this.onSeverityChanged,
    required this.onHazardTypeChanged,
  });

  static const List<String> severityLevels = [
    'CRITICAL',
    'HIGH',
    'MODERATE',
    'LOW',
  ];

  static const List<String> hazardTypes = [
    'DROUGHT',
    'FLOOD',
    'LOCUST_PEST',
    'VEGETATION_STRESS',
    'FROST',
    'HEAT_STRESS',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Severity Filter
        Text(
          'Filter by Severity',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: severityLevels.map((severity) {
              final isSelected = selectedSeverity == severity;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(_formatSeverity(severity)),
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getSeverityColor(severity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedColor: _getSeverityColor(severity).withValues(alpha: 0.2),
                  checkmarkColor: _getSeverityColor(severity),
                  onSelected: (selected) {
                    onSeverityChanged(selected ? severity : null);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Hazard Type Filter
        Text(
          'Filter by Hazard Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: hazardTypes.map((hazardType) {
              final isSelected = selectedHazardType == hazardType;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(_formatHazardType(hazardType)),
                  avatar: Icon(
                    _getHazardIcon(hazardType),
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                  ),
                  onSelected: (selected) {
                    onHazardTypeChanged(selected ? hazardType : null);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
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
    switch (hazardType) {
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

  String _formatSeverity(String severity) {
    return severity[0] + severity.substring(1).toLowerCase();
  }

  String _formatHazardType(String type) {
    return type.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
