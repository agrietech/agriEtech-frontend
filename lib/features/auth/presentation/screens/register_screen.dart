///
/// @file register_screen.dart
/// @feature auth
/// @description Presentation Screen UI for register_screen.
/// @author UI/Feature Developer (auth)
///
library register_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('AUTH')),
      body: Center(child: Text('register_screen - Pending Team Assignment')),
    );
  }
}
