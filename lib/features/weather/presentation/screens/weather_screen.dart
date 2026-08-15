///
/// @file weather_screen.dart
/// @feature weather
/// @description Presentation Screen UI for weather_screen.
/// @author UI/Feature Developer (weather)
///
library weather_screen;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('WEATHER')),
      body: Center(child: Text('weather_screen - Pending Team Assignment')),
    );
  }
}
