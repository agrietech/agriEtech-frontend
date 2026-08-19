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
  await Firebase.initializeApp();
  AppLogger.info('Background message received', {
    'title': message.notification?.title,
    'data': message.data,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize environment configuration
    await AppEnv.init();
    AppLogger.info('Environment initialized: ${AppEnv.appEnv}');

    // Initialize Firebase
    try {
      if (AppEnv.firebaseApiKey.isNotEmpty) {
        await Firebase.initializeApp();
        AppLogger.info('Firebase initialized');
        
        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        
        // Initialize notification service
        await NotificationService().initialize();
        AppLogger.info('Notification service initialized');
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

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

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

