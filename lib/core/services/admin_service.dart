import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import '../models/order.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

// Top-level functions for background parsing (required by compute())
List<User> _parseUsers(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}

List<Restaurant> _parseRestaurants(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<Restaurant>((json) => Restaurant.fromJson(json)).toList();
}

List<Order> _parseOrders(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}

class AdminService {
  final ApiService _apiService = ApiService();

  // ==================== USERS MANAGEMENT ====================

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        ApiConstants.adminUsers,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final usersList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(usersList);
        // Use compute() to parse in background isolate
        final users = compute(_parseUsers, jsonString);
        
        return {
          'users': await users,
          'total': data['total'] as int? ?? 0,
          'page': data['page'] as int? ?? 1,
          'pages': data['pages'] as int? ?? 1,
        };
      }
      return {'users': <User>[], 'total': 0, 'page': 1, 'pages': 1};
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get(ApiConstants.adminUserDetail(userId));
      final data = response.data;
      
      if (data is Map && data.containsKey('data')) {
        return User.fromJson(data['data']);
      }
      throw Exception('User not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser({
    required String userId,
    String? fullName,
    String? phone,
    String? role,
    bool? isActive,
    bool? isVerified,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.adminUserDetail(userId),
        data: {
          if (fullName != null) 'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (role != null) 'role': role,
          if (isActive != null) 'isActive': isActive,
          if (isVerified != null) 'isVerified': isVerified,
        },
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return User.fromJson(data['data']);
      }
      throw Exception('Failed to update user');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete(ApiConstants.adminUserDetail(userId));
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESTAURANTS MANAGEMENT ====================

  Future<Map<String, dynamic>> getRestaurants({
    int page = 1,
    int limit = 20,
    bool? isActive,
    bool? isVerified,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (isVerified != null) queryParams['isVerified'] = isVerified.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        ApiConstants.adminRestaurants,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final restaurantsList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(restaurantsList);
        // Use compute() to parse in background isolate
        final restaurants = compute(_parseRestaurants, jsonString);
        
        return {
          'restaurants': await restaurants,
          'total': data['total'] as int? ?? 0,
          'page': data['page'] as int? ?? 1,
          'pages': data['pages'] as int? ?? 1,
        };
      }
      return {'restaurants': <Restaurant>[], 'total': 0, 'page': 1, 'pages': 1};
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRestaurant({
    required String restaurantId,
    bool? isActive,
    bool? isVerified,
  }) async {
    try {
      await _apiService.put(
        ApiConstants.adminRestaurantDetail(restaurantId),
        data: {
          if (isActive != null) 'isActive': isActive,
          if (isVerified != null) 'isVerified': isVerified,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      await _apiService.delete(ApiConstants.adminRestaurantDetail(restaurantId));
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ORDERS MANAGEMENT ====================

  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? restaurantId,
    String? customerId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (restaurantId != null) queryParams['restaurantId'] = restaurantId;
      if (customerId != null) queryParams['customerId'] = customerId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.get(
        ApiConstants.adminOrders,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final ordersList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(ordersList);
        // Use compute() to parse in background isolate
        final orders = compute(_parseOrders, jsonString);
        
        return {
          'orders': await orders,
          'total': data['total'] as int? ?? 0,
          'page': data['page'] as int? ?? 1,
          'pages': data['pages'] as int? ?? 1,
        };
      }
      return {'orders': <Order>[], 'total': 0, 'page': 1, 'pages': 1};
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SHIPPERS MANAGEMENT ====================

  Future<Map<String, dynamic>> getShippers({
    int page = 1,
    int limit = 20,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _apiService.get(
        ApiConstants.adminShippers,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final shippersList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(shippersList);
        // Use compute() to parse in background isolate
        final shippers = compute(_parseUsers, jsonString);
        
        return {
          'shippers': await shippers,
          'total': data['total'] as int? ?? 0,
          'page': data['page'] as int? ?? 1,
          'pages': data['pages'] as int? ?? 1,
        };
      }
      return {'shippers': <User>[], 'total': 0, 'page': 1, 'pages': 1};
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateShipper({
    required String shipperId,
    String? fullName,
    String? phone,
    bool? isActive,
    bool? isVerified,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConstants.adminShipperDetail(shipperId),
        data: {
          if (fullName != null) 'fullName': fullName,
          if (phone != null) 'phone': phone,
          if (isActive != null) 'isActive': isActive,
          if (isVerified != null) 'isVerified': isVerified,
        },
      );
      
      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return User.fromJson(data['data']);
      }
      throw Exception('Failed to update shipper');
    } catch (e) {
      rethrow;
    }
  }
}

