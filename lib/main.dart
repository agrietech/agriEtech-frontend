///
/// @file main.dart
/// @description Flutter Application Entry Point for AgriEtech Early Warning Platform.
/// @responsibility Initializes Flutter bindings and boots root application.
/// @author Team Lead / Frontend Core
///
library main;

import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgriEtechApp());
}
