///
/// @file login_screen.dart
/// @feature auth
/// @description Presentation Screen UI for login_screen.
/// @author UI/Feature Developer (auth)
///
library login_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('AUTH')),
      body: const Center(child: Text('login_screen - Pending Team Assignment')),
    );
  }
}
