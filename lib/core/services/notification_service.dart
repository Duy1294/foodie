import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'api_service.dart';
import '../constants/api_constants.dart';
import '../models/notification.dart' as models;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize notification service
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize local notifications
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
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      _initialized = true;
      debugPrint('✅ Notification service initialized');

      // Setup Firebase messaging handlers
      _setupFirebaseMessagingHandlers();
    } catch (e) {
      debugPrint('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  void _setupFirebaseMessagingHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notification opened: ${message.data}');
      _handleNotificationTap(message);
    });
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    // TODO: Navigate based on notification type
    // Example: if (data['type'] == 'order') navigate to order detail
    debugPrint('📬 Notification data: $data');
  }

  /// Show order status notification
  Future<void> showOrderStatusNotification({
    required String orderId,
    required String orderNumber,
    required String status,
    String? message,
  }) async {
    final statusMessages = {
      'pending': 'Đơn hàng #$orderNumber đã được đặt',
      'confirmed': 'Đơn hàng #$orderNumber đã được xác nhận',
      'preparing': 'Đơn hàng #$orderNumber đang được chuẩn bị',
      'ready': 'Đơn hàng #$orderNumber đã sẵn sàng',
      'picked_up': 'Tài xế đã lấy đơn hàng #$orderNumber',
      'on_the_way': 'Đơn hàng #$orderNumber đang trên đường giao',
      'delivered': 'Đơn hàng #$orderNumber đã được giao thành công',
      'cancelled': 'Đơn hàng #$orderNumber đã bị hủy',
    };

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      orderId.hashCode,
      'Cập nhật đơn hàng',
      message ?? statusMessages[status] ?? 'Đơn hàng #$orderNumber đã được cập nhật',
      details,
      payload: 'order:$orderId',
    );
  }

  /// Subscribe to order notifications
  Future<void> subscribeToOrderNotifications(String orderId) async {
    try {
      await FirebaseService().subscribeToTopic('order_$orderId');
      debugPrint('✅ Subscribed to order notifications: $orderId');
    } catch (e) {
      debugPrint('❌ Error subscribing to order notifications: $e');
    }
  }

  /// Unsubscribe from order notifications
  Future<void> unsubscribeFromOrderNotifications(String orderId) async {
    try {
      await FirebaseService().unsubscribeFromTopic('order_$orderId');
      debugPrint('✅ Unsubscribed from order notifications: $orderId');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from order notifications: $e');
    }
  }

  /// Get notifications from backend API
  Future<List<models.Notification>> getNotifications() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get(ApiConstants.notifications);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final notificationsList = data['data'] as List;
        return notificationsList.map((json) {
          try {
            final notificationJson = json as Map<String, dynamic>;
            return models.Notification.fromJson(notificationJson);
          } catch (e) {
            debugPrint('❌ Error parsing notification: $e');
            debugPrint('📋 Notification JSON: $json');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting notifications: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.put(ApiConstants.markNotificationRead(notificationId));
      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final apiService = ApiService();
      await apiService.put(ApiConstants.markAllNotificationsRead);
      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final apiService = ApiService();
      await apiService.delete('${ApiConstants.notifications}/$notificationId');
      debugPrint('✅ Deleted notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      rethrow;
    }
  }
}
