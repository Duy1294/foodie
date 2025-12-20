import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/order.dart';
import 'api_service.dart';
import 'order_item_data.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

// Top-level function for background parsing (required by compute())
List<Order> _parseOrders(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}

class OrderService {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  Future<Order> createOrder({
    required String restaurantId,
    required List<OrderItemData> items,
    required String deliveryAddress,
    required String paymentMethod,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? customerNote,
    double? deliveryFee,
  }) async {
    try {
      // Calculate totals
      double subtotal = 0;
      for (var item in items) {
        subtotal += item.unitPrice * item.quantity;
      }

      final finalDeliveryFee = deliveryFee ?? 0;

      final response = await _apiService.post(
        ApiConstants.orders,
        data: {
          'restaurantId': restaurantId,
          'items': items.map((item) => {
                'menuItemId': item.menuItemId,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'subtotal': item.unitPrice * item.quantity,
                if (item.specialInstructions != null)
                  'specialInstructions': item.specialInstructions,
              }).toList(),
          'deliveryAddress': deliveryAddress,
          'deliveryLatitude': deliveryLatitude,
          'deliveryLongitude': deliveryLongitude,
          'paymentMethod': paymentMethod,
          'subtotal': subtotal,
          'deliveryFee': finalDeliveryFee,
          'totalAmount': subtotal + finalDeliveryFee,
          if (customerNote != null) 'customerNote': customerNote,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final order = Order.fromJson(data['data']);
        
        // Sync order to Firestore for real-time updates
        try {
          await _firestoreService.syncOrderToFirestore(order.toJson());
          
          // Subscribe to order notifications
          await _notificationService.subscribeToOrderNotifications(order.id);
        } catch (e) {
          debugPrint('⚠️ Failed to sync order to Firestore: $e');
          // Continue even if Firestore sync fails
        }
        
        return order;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
  
  /// Watch order status in real-time using Firestore
  Stream<OrderStatus> watchOrderStatus(String orderId) {
    return _firestoreService.watchOrderStatus(orderId);
  }
  
  /// Watch order in real-time using Firestore
  Stream<Map<String, dynamic>?> watchOrder(String orderId) {
    return _firestoreService.watchOrder(orderId);
  }
  
  /// Watch driver location in real-time
  Stream<Map<String, dynamic>?> watchDriverLocation(String orderId) {
    return _firestoreService.watchDriverLocation(orderId);
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _apiService.get(ApiConstants.orders);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final ordersList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(ordersList);
        // Use compute() to parse in background isolate
        return compute(_parseOrders, jsonString);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting orders: $e');
      rethrow;
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _apiService.get(ApiConstants.orderDetail(orderId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        try {
          final orderJson = data['data'] as Map<String, dynamic>;
          return Order.fromJson(orderJson);
        } catch (e) {
          print('❌ Error parsing order detail: $e');
          print('📋 Order JSON: ${data['data'].toString().substring(0, 500)}');
          rethrow;
        }
      }
      throw Exception('Order not found');
    } catch (e) {
      print('❌ Error getting order by ID: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      // Use updateOrderStatus to cancel order
      await _apiService.put(
        ApiConstants.updateOrderStatus(orderId),
        data: {'status': 'cancelled'},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get available orders for drivers (orders without driver assigned)
  Future<List<Order>> getAvailableOrders() async {
    try {
      final response = await _apiService.get(ApiConstants.availableOrders);
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final ordersList = data['data'] as List;
        return ordersList.map((json) {
          try {
            final orderJson = json as Map<String, dynamic>;
            return Order.fromJson(orderJson);
          } catch (e) {
            print('❌ Error parsing available order: $e');
            rethrow;
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error getting available orders: $e');
      rethrow;
    }
  }

  /// Driver accepts an order
  Future<Order> acceptOrder(String orderId) async {
    try {
      final response = await _apiService.post(ApiConstants.acceptOrder(orderId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final orderJson = data['data'] as Map<String, dynamic>;
        return Order.fromJson(orderJson);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('❌ Error accepting order: $e');
      rethrow;
    }
  }

  /// Update order status
  Future<Order> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateOrderStatus(orderId),
        data: {'status': status},
      );
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        final orderJson = data['data'] as Map<String, dynamic>;
        return Order.fromJson(orderJson);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('❌ Error updating order status: $e');
      rethrow;
    }
  }
}

