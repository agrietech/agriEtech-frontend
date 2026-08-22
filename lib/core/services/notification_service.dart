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

  FirebaseMessaging? get _firebaseMessaging {
    if (kIsWeb) return null;
    try {
      return FirebaseMessaging.instance;
    } catch (e) {
      AppLogger.warning('FirebaseMessaging instance unavailable: $e');
      return null;
    }
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  Future<void> Function(String token)? _onTokenUpdate;

  void setTokenUpdateHandler(Future<void> Function(String token) handler) {
    _onTokenUpdate = handler;
  }

  /// Initialize notification service
  Future<void> initialize() async {
    if (kIsWeb) {
      AppLogger.info('Web platform detected - push notification service bypassed');
      return;
    }
    
    final messaging = _firebaseMessaging;
    if (messaging == null) {
      AppLogger.warning('FirebaseMessaging unavailable - skipping push notification initialization');
      return;
    }

    try {
      // Request permission
      final settings = await messaging.requestPermission(
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
        _fcmToken = await messaging.getToken();
        AppLogger.success('FCM Token obtained', {'token': _fcmToken});

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Setup message handlers
        _setupMessageHandlers();

        // Listen to token refresh
        messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          AppLogger.info('FCM Token refreshed', {'token': newToken});
          updateTokenOnBackend(newToken);
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize notifications', e);
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return;
    try {
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
    } catch (e) {
      AppLogger.warning('Local notifications initialization skipped: $e');
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (kIsWeb) return;
    try {
      const criticalChannel = AndroidNotificationChannel(
        'critical_alerts',
        'Critical Alerts',
        description: 'Critical weather and hazard alerts',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const highChannel = AndroidNotificationChannel(
        'high_alerts',
        'High Priority Alerts',
        description: 'High priority warnings and updates',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

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
    } catch (e) {
      AppLogger.warning('Android notification channels creation failed: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    if (kIsWeb) return;
    final messaging = _firebaseMessaging;
    if (messaging == null) return;

    try {
      // Foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background messages (when app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Terminated state (when app was killed)
      messaging.getInitialMessage().then((message) {
        if (message != null) {
          _handleTerminatedMessage(message);
        }
      });
    } catch (e) {
      AppLogger.warning('Error setting up Firebase message handlers: $e');
    }
  }

  /// Handle foreground messages (app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('Foreground message received', {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });

    await _showLocalNotification(message);
  }

  /// Handle background messages (app is in background)
  void _handleBackgroundMessage(RemoteMessage message) {
    AppLogger.info('Background message opened', {
      'title': message.notification?.title,
      'data': message.data,
    });

    _navigateFromNotification(message.data);
  }

  /// Handle terminated messages (app was closed)
  void _handleTerminatedMessage(RemoteMessage message) {
    AppLogger.info('Terminated message received', {
      'title': message.notification?.title,
      'data': message.data,
    });

    _navigateFromNotification(message.data);
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;
    final notification = message.notification;
    if (notification == null) return;

    final channelId = _getChannelId(message.data);
    final priority = _getPriority(message.data);

    try {
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
    } catch (e) {
      AppLogger.warning('Failed to show local notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped', {'payload': response.payload});

    if (response.payload != null) {
      try {
        final payload = response.payload!;
        if (payload.contains('type')) {
          String? type;
          String? id;
          
          final typeMatch = RegExp(r'type.*?[:=]\s*(\w+)').firstMatch(payload);
          if (typeMatch != null) {
            type = typeMatch.group(1);
          }
          
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

    switch (type) {
      case 'alert':
        AppLogger.info('Should navigate to alert', {'alertId': id});
        break;
      case 'risk':
        AppLogger.info('Should navigate to risk map');
        break;
      case 'diagnosis':
        AppLogger.info('Should navigate to diagnosis', {'diagnosisId': id});
        break;
      case 'sensor':
        AppLogger.info('Should navigate to sensor', {'sensorId': id});
        break;
      case 'farm':
        AppLogger.info('Should navigate to farm', {'farmId': id});
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
    if (kIsWeb) return;
    try {
      await _firebaseMessaging?.subscribeToTopic(topic);
      AppLogger.success('Subscribed to topic', {'topic': topic});
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;
    try {
      await _firebaseMessaging?.unsubscribeFromTopic(topic);
      AppLogger.success('Unsubscribed from topic', {'topic': topic});
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic', e);
    }
  }

  /// Update FCM token on backend
  Future<void> updateTokenOnBackend(String token) async {
    AppLogger.info('Updating FCM token on backend', {'token': token});
    _fcmToken = token;
    if (_onTokenUpdate != null) {
      try {
        await _onTokenUpdate!(token);
        AppLogger.success('FCM token sent to backend via callback');
      } catch (e) {
        AppLogger.warning('Failed to sync refreshed FCM token via callback', e);
      }
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    if (kIsWeb) return;
    try {
      await _localNotifications.cancelAll();
      AppLogger.info('All notifications cleared');
    } catch (e) {
      AppLogger.warning('Failed to clear local notifications: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    AppLogger.info('Background message received', {
      'title': message.notification?.title,
      'data': message.data,
    });
  }
}
