///
/// @file period_toggle.dart
/// @description Reusable segmented button widget (Daily / Dekadal / Monthly / Seasonal).
/// @author UI Component Specialist
///
library period_toggle;

import 'package:flutter/material.dart';

enum TimePeriod { daily, dekadal, monthly, seasonal }

class PeriodToggle extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;

  const PeriodToggle({
    super.key,
    this.selectedPeriod = 'Daily',
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: 'Daily',
          label: Text('Daily'),
          icon: Icon(Icons.today_rounded, size: 16),
        ),
        ButtonSegment<String>(
          value: 'Dekadal',
          label: Text('10-Day'),
          icon: Icon(Icons.date_range_rounded, size: 16),
        ),
        ButtonSegment<String>(
          value: 'Monthly',
          label: Text('Monthly'),
          icon: Icon(Icons.calendar_month_rounded, size: 16),
        ),
        ButtonSegment<String>(
          value: 'Seasonal',
          label: Text('Seasonal'),
          icon: Icon(Icons.eco_rounded, size: 16),
        ),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty && onPeriodChanged != null) {
          onPeriodChanged!(newSelection.first);
        }
      },
      style: ButtonStyle(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }
}
