import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

// Top-level function for background parsing (required by compute())
Map<String, dynamic> _parseCartData(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get subtotal => menuItem.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal() {
    _loadCart();
  }

  final StorageService _storage = StorageService();
  Restaurant? _restaurant;
  final List<CartItem> _items = [];

  Restaurant? get restaurant => _restaurant;
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get deliveryFee => _restaurant?.deliveryFee ?? 0;
  double get total => subtotal + deliveryFee;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  Future<void> _loadCart() async {
    try {
      final cartJson = _storage.getString(AppConstants.keyCart);
      if (cartJson != null) {
        // Use compute() to parse in background isolate
        final cartData = await compute(_parseCartData, cartJson);
        
        if (cartData['restaurant'] != null) {
          _restaurant = Restaurant.fromJson(cartData['restaurant']);
        }
        
        if (cartData['items'] != null) {
          _items.clear();
          final itemsList = cartData['items'] as List;
          for (var itemJson in itemsList) {
            _items.add(CartItem.fromJson(itemJson));
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final cartData = {
        'restaurant': _restaurant?.toJson(),
        'items': _items.map((item) => item.toJson()).toList(),
      };
      await _storage.setString(AppConstants.keyCart, jsonEncode(cartData));
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> addItem(MenuItem menuItem, {int quantity = 1, String? specialInstructions}) async {
    // Check if restaurant matches
    if (_restaurant != null && _restaurant!.id != menuItem.restaurantId) {
      // Clear cart if different restaurant
      await clearCart();
    }

    // Set restaurant if cart is empty
    if (_restaurant == null) {
      // TODO: Load restaurant from API
      // For now, we'll need to set it when adding first item
    }

    // Find existing item
    final existingIndex = _items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      _items[existingIndex].quantity += quantity;
      if (specialInstructions != null) {
        _items[existingIndex].specialInstructions = specialInstructions;
      }
    } else {
      // Add new item
      _items.add(CartItem(
        menuItem: menuItem,
        quantity: quantity,
        specialInstructions: specialInstructions,
      ));
    }

    await _saveCart();
  }

  Future<void> updateItemQuantity(String menuItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(menuItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      await _saveCart();
    }
  }

  Future<void> removeItem(String menuItemId) async {
    _items.removeWhere((item) => item.menuItem.id == menuItemId);
    
    // Clear restaurant if cart is empty
    if (_items.isEmpty) {
      _restaurant = null;
    }
    
    await _saveCart();
  }

  Future<void> setRestaurant(Restaurant restaurant) async {
    if (_restaurant?.id != restaurant.id && _items.isNotEmpty) {
      // Different restaurant, clear cart
      await clearCart();
    }
    _restaurant = restaurant;
    await _saveCart();
  }

  Future<void> clearCart() async {
    _items.clear();
    _restaurant = null;
    await _storage.remove(AppConstants.keyCart);
    notifyListeners();
  }
}

