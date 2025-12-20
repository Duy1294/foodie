// Unit tests for Order model
// Following Flutter docs: https://docs.flutter.dev/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/core/models/order.dart';
import 'package:foodie/core/models/menu_item.dart';

void main() {
  group('OrderStatus Enum Tests', () {
    test('should have all expected status values', () {
      expect(OrderStatus.values.length, 8);
      expect(OrderStatus.values, contains(OrderStatus.pending));
      expect(OrderStatus.values, contains(OrderStatus.confirmed));
      expect(OrderStatus.values, contains(OrderStatus.delivered));
      expect(OrderStatus.values, contains(OrderStatus.cancelled));
    });
  });

  group('PaymentMethod Enum Tests', () {
    test('should have all expected payment methods', () {
      expect(PaymentMethod.values.length, 5);
      expect(PaymentMethod.values, contains(PaymentMethod.cash));
      expect(PaymentMethod.values, contains(PaymentMethod.card));
      expect(PaymentMethod.values, contains(PaymentMethod.momo));
    });
  });

  group('OrderItem Tests', () {
    test('should create OrderItem with required fields', () {
      final orderItem = OrderItem(
        id: '1',
        menuItemId: 'menu1',
        quantity: 2,
        unitPrice: 100.0,
        subtotal: 200.0,
      );

      expect(orderItem.id, '1');
      expect(orderItem.menuItemId, 'menu1');
      expect(orderItem.quantity, 2);
      expect(orderItem.unitPrice, 100.0);
      expect(orderItem.subtotal, 200.0);
    });

    test('should create OrderItem with all fields', () {
      final menuItem = MenuItem(
        id: 'menu1',
        name: 'Test Item',
        description: 'Test',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
      );

      final orderItem = OrderItem(
        id: '1',
        menuItemId: 'menu1',
        menuItem: menuItem,
        quantity: 2,
        unitPrice: 100.0,
        subtotal: 200.0,
        specialInstructions: 'No onions',
      );

      expect(orderItem.menuItem, isNotNull);
      expect(orderItem.specialInstructions, 'No onions');
    });

    test('should convert OrderItem to JSON', () {
      final orderItem = OrderItem(
        id: '1',
        menuItemId: 'menu1',
        quantity: 2,
        unitPrice: 100.0,
        subtotal: 200.0,
      );

      final json = orderItem.toJson();

      expect(json['id'], '1');
      expect(json['menuItemId'], 'menu1');
      expect(json['quantity'], 2);
      expect(json['unitPrice'], 100.0);
      expect(json['subtotal'], 200.0);
    });

    test('should create OrderItem from JSON', () {
      final json = {
        'id': '1',
        'menuItemId': 'menu1',
        'quantity': 2,
        'unitPrice': 100.0,
        'subtotal': 200.0,
        'specialInstructions': 'No onions',
      };

      final orderItem = OrderItem.fromJson(json);

      expect(orderItem.id, '1');
      expect(orderItem.menuItemId, 'menu1');
      expect(orderItem.quantity, 2);
      expect(orderItem.unitPrice, 100.0);
      expect(orderItem.subtotal, 200.0);
      expect(orderItem.specialInstructions, 'No onions');
    });
  });

  group('Order Model Tests', () {
    test('should create Order with required fields', () {
      final order = Order(
        id: '1',
        orderNumber: 'ORD-001',
        customerId: 'customer1',
        restaurantId: 'rest1',
        items: [],
        deliveryAddress: '123 Main St',
        paymentMethod: PaymentMethod.cash,
        subtotal: 100.0,
        deliveryFee: 10.0,
        totalAmount: 110.0,
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(order.id, '1');
      expect(order.customerId, 'customer1');
      expect(order.restaurantId, 'rest1');
      expect(order.items, isEmpty);
      expect(order.status, OrderStatus.pending);
      expect(order.paymentMethod, PaymentMethod.cash);
      expect(order.totalAmount, 110.0);
    });

    test('should create Order with all fields', () {
      final orderItem = OrderItem(
        id: 'item1',
        menuItemId: 'menu1',
        quantity: 2,
        unitPrice: 100.0,
        subtotal: 200.0,
      );

      final order = Order(
        id: '1',
        orderNumber: 'ORD-002',
        customerId: 'customer1',
        restaurantId: 'rest1',
        items: [orderItem],
        deliveryAddress: '123 Main St',
        deliveryLatitude: 10.0,
        deliveryLongitude: 106.0,
        paymentMethod: PaymentMethod.card,
        subtotal: 200.0,
        deliveryFee: 20.0,
        totalAmount: 220.0,
        status: OrderStatus.confirmed,
        customerNote: 'Please hurry',
        createdAt: DateTime(2024, 1, 1),
        deliveredAt: DateTime(2024, 1, 2),
      );

      expect(order.items.length, 1);
      expect(order.deliveryLatitude, 10.0);
      expect(order.deliveryLongitude, 106.0);
      expect(order.customerNote, 'Please hurry');
      expect(order.status, OrderStatus.confirmed);
    });

    test('should convert Order to JSON', () {
      final order = Order(
        id: '1',
        orderNumber: 'ORD-003',
        customerId: 'customer1',
        restaurantId: 'rest1',
        items: [],
        deliveryAddress: '123 Main St',
        paymentMethod: PaymentMethod.cash,
        subtotal: 100.0,
        deliveryFee: 10.0,
        totalAmount: 110.0,
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = order.toJson();

      expect(json['id'], '1');
      expect(json['customerId'], 'customer1');
      expect(json['restaurantId'], 'rest1');
      expect(json['status'], 'pending');
      expect(json['paymentMethod'], 'cash');
      expect(json['totalAmount'], 110.0);
    });

    test('should create Order from JSON', () {
      final json = {
        'id': '1',
        'orderNumber': 'ORD-004',
        'customerId': 'customer1',
        'restaurantId': 'rest1',
        'items': [],
        'deliveryAddress': '123 Main St',
        'paymentMethod': 'cash',
        'subtotal': 100.0,
        'deliveryFee': 10.0,
        'discountAmount': 0.0,
        'totalAmount': 110.0,
        'status': 'pending',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final order = Order.fromJson(json);

      expect(order.id, '1');
      expect(order.customerId, 'customer1');
      expect(order.restaurantId, 'rest1');
      expect(order.status, OrderStatus.pending);
      expect(order.paymentMethod, PaymentMethod.cash);
      expect(order.totalAmount, 110.0);
    });

    test('should have statusText getter', () {
      final order = Order(
        id: '1',
        orderNumber: 'ORD-005',
        customerId: 'customer1',
        restaurantId: 'rest1',
        items: [],
        deliveryAddress: '123 Main St',
        paymentMethod: PaymentMethod.cash,
        subtotal: 100.0,
        deliveryFee: 10.0,
        totalAmount: 110.0,
        status: OrderStatus.pending,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(order.statusText, 'Đã đặt');
      
      final confirmedOrder = Order(
        id: '2',
        orderNumber: 'ORD-006',
        customerId: 'customer1',
        restaurantId: 'rest1',
        items: [],
        deliveryAddress: '123 Main St',
        paymentMethod: PaymentMethod.cash,
        subtotal: 100.0,
        deliveryFee: 10.0,
        totalAmount: 110.0,
        status: OrderStatus.delivered,
        createdAt: DateTime(2024, 1, 1),
      );
      
      expect(confirmedOrder.statusText, 'Đã giao');
    });
  });
}

