///
/// @file farm_list_screen.dart
/// @feature farms
/// @description Presentation Screen UI for farm_list_screen.
/// @author UI/Feature Developer (farms)
///
library farm_list_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmListScreen extends ConsumerWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FARMS')),
      body: const Center(child: Text('farm_list_screen - Pending Team Assignment')),
    );
  }
}
