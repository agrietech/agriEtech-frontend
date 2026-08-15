///
/// @file add_farm_screen.dart
/// @feature farms
/// @description Presentation Screen UI for add_farm_screen.
/// @author UI/Feature Developer (farms)
///
library add_farm_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddFarmScreen extends ConsumerWidget {
  const AddFarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('FARMS')),
      body: const Center(child: Text('add_farm_screen - Pending Team Assignment')),
    );
  }
}
