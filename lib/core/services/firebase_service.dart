import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level function for handling background messages
/// Must be a top-level function, not a class method
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _initialized = false;
  FirebaseMessaging? _messaging;

  /// Initialize Firebase
  Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      rethrow;
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> initMessaging() async {
    if (!_initialized) {
      await init();
    }

    try {
      _messaging = FirebaseMessaging.instance;

      // Request permission
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint('❌ User declined notification permission');
      }

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 Foreground message received: ${message.messageId}');
        debugPrint('Title: ${message.notification?.title}');
        debugPrint('Body: ${message.notification?.body}');
        debugPrint('Data: ${message.data}');
      });

      // Handle notification taps (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📬 Notification opened app: ${message.messageId}');
        debugPrint('Data: ${message.data}');
      });

      // Check if app was opened from a terminated state
      RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📭 App opened from terminated state');
        debugPrint('Data: ${initialMessage.data}');
      }

      // Get FCM token
      String? token = await _messaging!.getToken();
      if (token != null) {
        debugPrint('📱 FCM Token: $token');
        // TODO: Send token to backend
      }

      // Listen for token refresh
      _messaging!.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Send new token to backend
      });
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
      rethrow;
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    if (_messaging == null) {
      await initMessaging();
    }
    return await _messaging?.getToken();
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) {
      await initMessaging();
    }
    await _messaging?.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) {
      await initMessaging();
    }
    await _messaging?.unsubscribeFromTopic(topic);
    debugPrint('✅ Unsubscribed from topic: $topic');
  }

  bool get isInitialized => _initialized;
}

