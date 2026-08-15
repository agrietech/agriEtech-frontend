///
/// @file risk_badge.dart
/// @description Visual indicator pill displaying hazard severity (LOW / MODERATE / HIGH / CRITICAL).
/// @author UI Component Specialist
///
library risk_badge;

import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String level;
  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // TODO: Return colored container with severity icon
    return const Chip(label: Text('LOW'));
  }
}
