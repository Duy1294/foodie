import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Watch order status in real-time
  Stream<OrderStatus> watchOrderStatus(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return OrderStatus.pending;
      }
      final data = snapshot.data();
      final status = data?['status'] as String? ?? 'pending';
      return OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => OrderStatus.pending,
      );
    });
  }

  /// Watch order in real-time
  Stream<Map<String, dynamic>?> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Update order status in Firestore
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Order status updated: $orderId -> $status');
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      rethrow;
    }
  }

  /// Watch driver location in real-time
  Stream<Map<String, dynamic>?> watchDriverLocation(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('driver_location')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    });
  }

  /// Update driver location
  Future<void> updateDriverLocation({
    required String orderId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('driver_location')
          .add({
        'driverId': userId,
        'latitude': latitude,
        'longitude': longitude,
        if (heading != null) 'heading': heading,
        if (speed != null) 'speed': speed,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Driver location updated for order: $orderId');
    } catch (e) {
      debugPrint('❌ Error updating driver location: $e');
      rethrow;
    }
  }

  /// Watch pending orders count for restaurant
  Stream<int> watchPendingOrdersCount(String restaurantId) {
    return _firestore
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Watch orders for user
  Stream<List<Map<String, dynamic>>> watchUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Sync order from backend to Firestore
  Future<void> syncOrderToFirestore(Map<String, dynamic> orderData) async {
    try {
      final orderId = orderData['id'] as String? ?? orderData['_id'] as String;
      await _firestore.collection('orders').doc(orderId).set({
        ...orderData,
        'id': orderId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Order synced to Firestore: $orderId');
    } catch (e) {
      debugPrint('❌ Error syncing order to Firestore: $e');
      rethrow;
    }
  }
}

