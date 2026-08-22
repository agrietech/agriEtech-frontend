import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/config/env.dart';
import 'core/utils/logger.dart';
import 'core/services/notification_service.dart';
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
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
    }

    AppLogger.info('AgriEtech app starting...');

    runApp(
      const ProviderScope(
        child: AgriEtechApp(),
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

