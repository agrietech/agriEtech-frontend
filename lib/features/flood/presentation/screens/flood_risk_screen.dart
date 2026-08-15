///
/// @file flood_risk_screen.dart
/// @feature flood
/// @description Presentation Screen UI for flood_risk_screen.
/// @author UI/Feature Developer (flood)
///
library flood_risk_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FloodRiskScreen extends ConsumerWidget {
  const FloodRiskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FLOOD')),
      body: const Center(child: Text('flood_risk_screen - Pending Team Assignment')),
    );
  }
}
