///
/// @file drought_risk_screen.dart
/// @feature drought
/// @description Presentation Screen UI for drought_risk_screen.
/// @author UI/Feature Developer (drought)
///
library drought_risk_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DroughtRiskScreen extends ConsumerWidget {
  const DroughtRiskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('DROUGHT')),
      body: Center(child: Text('drought_risk_screen - Pending Team Assignment')),
    );
  }
}
