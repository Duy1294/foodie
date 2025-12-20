import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

enum NotificationType {
  @JsonValue('order_placed')
  orderPlaced,
  @JsonValue('order_confirmed')
  orderConfirmed,
  @JsonValue('order_preparing')
  orderPreparing,
  @JsonValue('order_ready')
  orderReady,
  @JsonValue('order_on_the_way')
  orderOnTheWay,
  @JsonValue('order_delivered')
  orderDelivered,
  @JsonValue('order_cancelled')
  orderCancelled,
  @JsonValue('new_order')
  newOrder,
  @JsonValue('order_accepted_by_driver')
  orderAcceptedByDriver,
  @JsonValue('driver_assigned')
  driverAssigned,
  @JsonValue('order_available')
  orderAvailable,
  @JsonValue('order_ready_for_pickup')
  orderReadyForPickup,
  @JsonValue('promotion')
  promotion,
  @JsonValue('system')
  system,
}

@JsonSerializable()
class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String? orderId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.orderId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    String? orderId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

