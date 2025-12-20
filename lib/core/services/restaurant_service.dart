import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart';
import 'api_service.dart';

// Top-level functions for background parsing (required by compute())
List<Restaurant> _parseRestaurants(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<Restaurant>((json) => Restaurant.fromJson(json)).toList();
}

List<MenuItem> _parseMenuItems(String responseBody) {
  final parsed = (jsonDecode(responseBody) as List<Object?>)
      .cast<Map<String, Object?>>();
  return parsed.map<MenuItem>((json) => MenuItem.fromJson(json)).toList();
}

class RestaurantService {
  final ApiService _apiService = ApiService();

  Future<List<Restaurant>> getRestaurants({
    String? search,
    double? minRating,
    double? maxDeliveryFee,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating;
      }
      if (maxDeliveryFee != null) {
        queryParams['maxDeliveryFee'] = maxDeliveryFee;
      }

      final response = await _apiService.get(
        ApiConstants.restaurants,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final restaurantsList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(restaurantsList);
        // Use compute() to parse in background isolate
        return compute(_parseRestaurants, jsonString);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Restaurant> getRestaurantById(String id) async {
    try {
      final response = await _apiService.get(
        ApiConstants.restaurantDetail(id),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final restaurantJson = data['data'] as Map<String, dynamic>;
        // Handle openingHours separately
        final restaurant = Restaurant.fromJson(restaurantJson);
        if (restaurantJson.containsKey('openingHours')) {
          return restaurant.copyWith(
            openingHours: restaurantJson['openingHours'] as Map<String, dynamic>?,
          );
        }
        return restaurant;
      }
      throw Exception('Restaurant not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MenuItem>> getRestaurantMenu(String restaurantId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.restaurantMenu(restaurantId),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final menuItemsList = data['data'] as List;
        return menuItemsList.map((json) => MenuItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // ==================== RESTAURANT OWNER METHODS ====================

  /// Get restaurant owned by current user
  Future<Restaurant?> getMyRestaurant() async {
    try {
      final response = await _apiService.get(
        ApiConstants.myRestaurant,
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final restaurantJson = data['data'] as Map<String, dynamic>;
        final restaurant = Restaurant.fromJson(restaurantJson);
        // Handle openingHours separately
        if (restaurantJson.containsKey('openingHours')) {
          return restaurant.copyWith(
            openingHours: restaurantJson['openingHours'] as Map<String, dynamic>?,
          );
        }
        return restaurant;
      }
      return null;
    } catch (e) {
      // If 404, return null (restaurant not found)
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  /// Get all menu items for restaurant owner (including unavailable)
  Future<List<MenuItem>> getRestaurantMenuForOwner(String restaurantId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.restaurantMenuManage(restaurantId),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final menuItemsList = data['data'] as List;
        // Convert to JSON string for background parsing
        final jsonString = jsonEncode(menuItemsList);
        // Use compute() to parse in background isolate
        return compute(_parseMenuItems, jsonString);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Add menu item
  Future<MenuItem> addMenuItem(String restaurantId, MenuItem menuItem) async {
    try {
      final response = await _apiService.post(
        ApiConstants.restaurantMenu(restaurantId),
        data: menuItem.toJson(),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return MenuItem.fromJson(data['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Update menu item
  Future<MenuItem> updateMenuItem(String restaurantId, String menuItemId, MenuItem menuItem) async {
    try {
      final response = await _apiService.put(
        ApiConstants.restaurantMenuItem(restaurantId, menuItemId),
        data: menuItem.toJson(),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return MenuItem.fromJson(data['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String restaurantId, String menuItemId) async {
    try {
      await _apiService.delete(
        ApiConstants.restaurantMenuItem(restaurantId, menuItemId),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update restaurant info
  Future<Restaurant> updateRestaurant(String restaurantId, Restaurant restaurant) async {
    try {
      final response = await _apiService.put(
        ApiConstants.restaurantDetail(restaurantId),
        data: restaurant.toJson(),
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return Restaurant.fromJson(data['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Update delivery settings
  Future<Restaurant> updateDeliverySettings(String restaurantId, {
    double? deliveryFee,
    double? minimumOrder,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (deliveryFee != null) data['deliveryFee'] = deliveryFee;
      if (minimumOrder != null) data['minimumOrder'] = minimumOrder;

      final response = await _apiService.put(
        ApiConstants.restaurantDelivery(restaurantId),
        data: data,
      );

      final responseData = response.data;
      if (responseData is Map && responseData.containsKey('data')) {
        return Restaurant.fromJson(responseData['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }

  /// Update opening hours
  Future<Restaurant> updateOpeningHours(String restaurantId, Map<String, Map<String, String>> openingHours) async {
    try {
      final response = await _apiService.put(
        ApiConstants.restaurantHours(restaurantId),
        data: {'openingHours': openingHours},
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        return Restaurant.fromJson(data['data']);
      }
      throw Exception('Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
}

