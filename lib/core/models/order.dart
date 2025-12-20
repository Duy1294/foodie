import 'package:json_annotation/json_annotation.dart';
import 'menu_item.dart';

part 'order.g.dart';

// Helper function for enum decoding - compatible with json_serializable
T $enumDecode<T extends Enum>(
  Map<T, String> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  final sourceString = source.toString();
  for (final MapEntry<T, String> entry in enumValues.entries) {
    if (entry.value == sourceString) {
      return entry.key;
    }
  }

  if (unknownValue != null) {
    return unknownValue;
  }

  throw ArgumentError(
    '`$source` is not one of the supported values: '
    '${enumValues.values.join(', ')}',
  );
}

enum OrderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('preparing')
  preparing,
  @JsonValue('ready')
  ready,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('on_the_way')
  onTheWay,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('wallet')
  wallet,
  @JsonValue('momo')
  momo,
  @JsonValue('zalopay')
  zalopay,
}

@JsonSerializable()
class OrderItem {
  final String id;
  final String menuItemId;
  final MenuItem? menuItem;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.menuItemId,
    this.menuItem,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String restaurantId;
  final String? driverId;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? customerNote;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.restaurantId,
    this.driverId,
    required this.status,
    required this.subtotal,
    this.deliveryFee = 0,
    this.discountAmount = 0,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.customerNote,
    required this.items,
    required this.createdAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Đã đặt';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.ready:
        return 'Sẵn sàng giao';
      case OrderStatus.pickedUp:
        return 'Đã lấy hàng';
      case OrderStatus.onTheWay:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

