///
/// @file farm_detail_screen.dart
/// @feature farms
/// @description Presentation Screen UI for farm_detail_screen.
/// @author UI/Feature Developer (farms)
///
library farm_detail_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmDetailScreen extends ConsumerWidget {
  const FarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FARMS')),
      body: const Center(child: Text('farm_detail_screen - Pending Team Assignment')),
    );
  }
}
