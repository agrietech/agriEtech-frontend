import 'package:flutter/material.dart';

/// Ethiopian Agricultural Season & Horizon Period Selector Widget
class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String>? onPeriodSelected;
  final List<String>? customPeriods;

  const PeriodSelector({
    super.key,
    this.selectedPeriod = 'Kiremt',
    this.onPeriodSelected,
    this.customPeriods,
  });

  static const List<String> defaultPeriods = [
    'Belg (Feb-May)',
    'Kiremt (Jun-Sep)',
    'Bega (Oct-Jan)',
    'Dekadal (10d)',
    'Annual',
  ];

  @override
  Widget build(BuildContext context) {
    final periods = customPeriods ?? defaultPeriods;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: periods.map((period) {
          final isSelected = period.toLowerCase().contains(selectedPeriod.toLowerCase()) ||
              period == selectedPeriod;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onPeriodSelected?.call(period),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
