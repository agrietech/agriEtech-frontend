import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/logger.dart';

/// Firebase Cloud Messaging service for push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      AppLogger.info('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        AppLogger.success('FCM Token obtained', {'token': _fcmToken});

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Setup message handlers
        _setupMessageHandlers();

        // Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          AppLogger.info('FCM Token refreshed', {'token': newToken});
          // TODO: Send new token to backend
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize notifications', e);
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channels for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    // Critical alerts channel
    const criticalChannel = AndroidNotificationChannel(
      'critical_alerts',
      'Critical Alerts',
      description: 'Critical weather and hazard alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // High priority alerts
    const highChannel = AndroidNotificationChannel(
      'high_alerts',
      'High Priority Alerts',
      description: 'High priority warnings and updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // General notifications
    const generalChannel = AndroidNotificationChannel(
      'general',
      'General Notifications',
      description: 'General updates and information',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    final plugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await plugin?.createNotificationChannel(criticalChannel);
    await plugin?.createNotificationChannel(highChannel);
    await plugin?.createNotificationChannel(generalChannel);
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Terminated state (when app was killed)
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleTerminatedMessage(message);
      }
    });
  }

  /// Handle foreground messages (app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('Foreground message received', {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Handle background messages (app is in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Background message opened', {
      'title': message.notification?.title,
      'data': message.data,
    });

    // Navigate to appropriate screen based on data
    _navigateFromNotification(message.data);
  }

  /// Handle terminated messages (app was closed)
  void _handleTerminatedMessage(RemoteMessage message) {
    AppLogger.info('Terminated message received', {
      'title': message.notification?.title,
      'data': message.data,
    });

    // Navigate to appropriate screen
    _navigateFromNotification(message.data);
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channelId = _getChannelId(message.data);
    final priority = _getPriority(message.data);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == 'critical_alerts'
              ? 'Critical Alerts'
              : channelId == 'high_alerts'
                  ? 'High Priority Alerts'
                  : 'General Notifications',
          importance: priority == 'critical'
              ? Importance.max
              : priority == 'high'
                  ? Importance.high
                  : Importance.defaultImportance,
          priority: priority == 'critical'
              ? Priority.max
              : priority == 'high'
                  ? Priority.high
                  : Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: priority == 'critical'
              ? const Color(0xFFD32F2F)
              : priority == 'high'
                  ? const Color(0xFFF57C00)
                  : const Color(0xFF1976D2),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped', {'payload': response.payload});

    if (response.payload != null) {
      // Parse payload and navigate
      try {
        // Payload is stored as string representation of map
        // Extract type and id from the string
        final payload = response.payload!;
        
        // Simple parsing - in production, use proper JSON parsing
        if (payload.contains('type')) {
          String? type;
          String? id;
          
          // Extract type - simple pattern matching
          final typeMatch = RegExp(r'type.*?[:=]\s*(\w+)').firstMatch(payload);
          if (typeMatch != null) {
            type = typeMatch.group(1);
          }
          
          // Extract id - simple pattern matching
          final idMatch = RegExp(r'id.*?[:=]\s*([a-zA-Z0-9-]+)').firstMatch(payload);
          if (idMatch != null) {
            id = idMatch.group(1);
          }
          
          if (type != null) {
            _navigateFromNotification({'type': type, 'id': id});
          }
        }
      } catch (e) {
        AppLogger.error('Failed to parse notification payload', e);
      }
    }
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    AppLogger.info('Navigating from notification', {'type': type, 'id': id});

    // Navigation is handled through notification callback
    // App can listen to this and navigate using GoRouter
    // For now, just log the navigation intent
    
    switch (type) {
      case 'alert':
        AppLogger.info('Should navigate to alert', {'alertId': id});
        // Router will handle: context.go('/alerts/$id')
        break;
      case 'risk':
        AppLogger.info('Should navigate to risk map');
        // Router will handle: context.go('/risk-map')
        break;
      case 'diagnosis':
        AppLogger.info('Should navigate to diagnosis', {'diagnosisId': id});
        // Router will handle: context.go('/diagnosis/$id')
        break;
      case 'sensor':
        AppLogger.info('Should navigate to sensor', {'sensorId': id});
        // Router will handle: context.go('/sensors/$id')
        break;
      case 'farm':
        AppLogger.info('Should navigate to farm', {'farmId': id});
        // Router will handle: context.go('/farms/$id')
        break;
      default:
        AppLogger.warning('Unknown notification type', {'type': type});
    }
  }

  /// Get channel ID based on notification priority
  String _getChannelId(Map<String, dynamic> data) {
    final priority = data['priority'] as String?;
    if (priority == 'critical') return 'critical_alerts';
    if (priority == 'high') return 'high_alerts';
    return 'general';
  }

  /// Get priority from notification data
  String _getPriority(Map<String, dynamic> data) {
    return data['priority'] as String? ?? 'normal';
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.success('Subscribed to topic', {'topic': topic});
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.success('Unsubscribed from topic', {'topic': topic});
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic', e);
    }
  }

  /// Update FCM token on backend
  Future<void> updateTokenOnBackend(String token) async {
    // This will be called from auth provider after login
    AppLogger.info('Updating FCM token on backend', {'token': token});
    // TODO: Implement API call to update device token
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    AppLogger.info('All notifications cleared');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message received', {
    'title': message.notification?.title,
    'data': message.data,
  });
}


