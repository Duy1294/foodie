import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/models/notification.dart' as models;
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<models.Notification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'all'; // 'all', 'unread', 'read'

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(models.Notification notification) async {
    if (notification.isRead) return;

    try {
      await _notificationService.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await _loadNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu tất cả là đã đọc'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNotification(models.Notification notification) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Bạn có chắc muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _notificationService.deleteNotification(notification.id);
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNotificationTap(models.Notification notification) {
    // Mark as read if not read
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Navigate based on notification type
    if (notification.orderId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: notification.orderId!,
          ),
        ),
      );
    }
  }

  IconData _getNotificationIcon(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.orderPlaced:
      case models.NotificationType.orderConfirmed:
      case models.NotificationType.orderPreparing:
      case models.NotificationType.orderReady:
      case models.NotificationType.orderOnTheWay:
      case models.NotificationType.orderDelivered:
      case models.NotificationType.orderCancelled:
        return Icons.receipt_long;
      case models.NotificationType.newOrder:
      case models.NotificationType.orderAcceptedByDriver:
      case models.NotificationType.driverAssigned:
        return Icons.restaurant;
      case models.NotificationType.orderAvailable:
      case models.NotificationType.orderReadyForPickup:
        return Icons.delivery_dining;
      case models.NotificationType.promotion:
        return Icons.local_offer;
      case models.NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.orderPlaced:
      case models.NotificationType.orderConfirmed:
        return Colors.blue;
      case models.NotificationType.orderPreparing:
        return Colors.orange;
      case models.NotificationType.orderReady:
      case models.NotificationType.orderReadyForPickup:
        return Colors.teal;
      case models.NotificationType.orderOnTheWay:
        return Colors.purple;
      case models.NotificationType.orderDelivered:
        return Colors.green;
      case models.NotificationType.orderCancelled:
        return Colors.red;
      case models.NotificationType.newOrder:
      case models.NotificationType.orderAcceptedByDriver:
      case models.NotificationType.driverAssigned:
        return Colors.amber;
      case models.NotificationType.orderAvailable:
        return Colors.cyan;
      case models.NotificationType.promotion:
        return Colors.pink;
      case models.NotificationType.system:
        return Colors.grey;
    }
  }

  List<models.Notification> get _filteredNotifications {
    switch (_filter) {
      case 'unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'read':
        return _notifications.where((n) => n.isRead).toList();
      default:
        return _notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả đã đọc',
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Tất cả'),
              ),
              const PopupMenuItem(
                value: 'unread',
                child: Text('Chưa đọc'),
              ),
              const PopupMenuItem(
                value: 'read',
                child: Text('Đã đọc'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lỗi: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == 'unread'
                                ? 'Không có thông báo chưa đọc'
                                : _filter == 'read'
                                    ? 'Không có thông báo đã đọc'
                                    : 'Không có thông báo',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) {
                          final notification = _filteredNotifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                            onDelete: () => _deleteNotification(notification),
                            getIcon: _getNotificationIcon,
                            getColor: _getNotificationColor,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final IconData Function(models.NotificationType) getIcon;
  final Color Function(models.NotificationType) getColor;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.getIcon,
    required this.getColor,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = getColor(notification.type);
    final icon = getIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue.shade50,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

