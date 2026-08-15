///
/// @file loading_indicator.dart
/// @description Standardized circular progress and shimmer loading indicators.
/// @author UI Component Specialist
///
library loading_indicator;

import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
