import 'dart:ui' show FlutterView, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';
import 'core/utils/responsive.dart';
import 'core/services/notification_service.dart';
import 'core/storage/app_preferences.dart';
import 'app.dart';

/// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    AppLogger.info('Background message received', {
      'title': message.notification?.title,
      'data': message.data,
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment configuration
    await AppEnv.init();
    AppLogger.info('Environment initialized: ${AppEnv.appEnv}');

    // Initialize Firebase (Mobile/Desktop push notifications)
    try {
      if (!kIsWeb && AppEnv.firebaseApiKey.isNotEmpty) {
        await Firebase.initializeApp();
        AppLogger.info('Firebase initialized');
        
        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        
        // Initialize notification service
        await NotificationService().initialize();
        AppLogger.info('Notification service initialized');
      } else if (kIsWeb) {
        AppLogger.info('Running on Web platform - Firebase push notifications bypassed');
      } else {
        AppLogger.warning('Firebase not configured - push notifications disabled');
      }
    } catch (e) {
      AppLogger.warning('Firebase initialization failed - continuing without push notifications', e);
      // Continue without push notifications
    }

    // Initialize Hive for local storage
    await Hive.initFlutter();
    AppLogger.info('Hive initialized');

    // Set preferred orientations and system UI overlay (Mobile only)
    if (!kIsWeb) {
      // Lock rotation on phones only; tablets and desktop are free to rotate.
      // This runs before the first frame, so there is no BuildContext yet and
      // metrics come from the platform view directly.
      //
      // If the engine has not reported metrics yet (physicalSize still zero on
      // a cold start) we keep the historical portrait lock rather than guess,
      // so the fallback is never worse than the previous behaviour.
      final FlutterView? view = PlatformDispatcher.instance.implicitView;
      final Size physical = view?.physicalSize ?? Size.zero;
      final bool metricsUnavailable = physical.isEmpty;
      final double shortestSide =
          metricsUnavailable ? 0 : physical.shortestSide / view!.devicePixelRatio;
      final bool isPhone =
          metricsUnavailable || shortestSide < Breakpoints.phoneShortestSide;

      if (metricsUnavailable) {
        AppLogger.warning(
          'Window metrics unavailable at startup - defaulting to portrait lock',
        );
      }

      await SystemChrome.setPreferredOrientations(
        isPhone
            ? const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
            : const [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ],
      );

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }

    // Restore user preferences (language, theme) before the first frame so the
    // app never flashes English/system-theme before switching.
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      AppLogger.info('Preferences loaded');
    } catch (e) {
      AppLogger.warning('SharedPreferences unavailable - using session defaults', e);
    }

    AppLogger.info('EthioFarm app starting...');

    runApp(
      ProviderScope(
        overrides: [
          if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const EthioFarmApp(),
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    
    // Run minimal app in case of initialization failure
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to start the application:\n${e.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text('Close App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

