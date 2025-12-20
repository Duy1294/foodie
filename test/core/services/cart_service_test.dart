// Unit tests for CartService
// Following Flutter docs: https://docs.flutter.dev/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/core/services/cart_service.dart';
import 'package:foodie/core/models/menu_item.dart';
import 'package:foodie/core/models/restaurant.dart';

void main() {
  // Initialize Flutter binding for services that use platform channels
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CartItem Tests', () {
    test('should calculate subtotal correctly', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final cartItem = CartItem(
        menuItem: menuItem,
        quantity: 2,
      );

      expect(cartItem.subtotal, 200.0);
    });

    test('should create CartItem from JSON', () {
      final json = {
        'menuItem': {
          'id': '1',
          'name': 'Test Item',
          'description': 'Test Description',
          'price': 100.0,
          'restaurantId': 'rest1',
          'isAvailable': true,
          'isPopular': false,
          'createdAt': '2024-01-01T00:00:00.000Z',
        },
        'quantity': 2,
        'specialInstructions': 'No onions',
      };

      final cartItem = CartItem.fromJson(json);

      expect(cartItem.menuItem.id, '1');
      expect(cartItem.quantity, 2);
      expect(cartItem.specialInstructions, 'No onions');
    });

    test('should convert CartItem to JSON', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final cartItem = CartItem(
        menuItem: menuItem,
        quantity: 2,
        specialInstructions: 'No onions',
      );

      final json = cartItem.toJson();

      expect(json['quantity'], 2);
      expect(json['specialInstructions'], 'No onions');
      expect(json['menuItem']['id'], '1');
    });
  });

  group('CartService Tests', () {
    late CartService cartService;

    setUp(() {
      // Note: CartService is a singleton, so state persists between tests
      // For unit tests, we'll test the logic without clearing (which requires platform)
      cartService = CartService();
      // Don't call clearCart() as it requires platform channels
      // Note: Cart may not be empty if previous tests added items
    });

    test('should calculate subtotal correctly', () async {
      // Test that subtotal calculation works
      final menuItem = MenuItem(
        id: 'test-1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      // Get initial count
      final initialCount = cartService.itemCount;
      
      await cartService.addItem(menuItem, quantity: 2);
      
      // Verify item was added
      expect(cartService.itemCount, greaterThan(initialCount));
      // Verify subtotal includes the new item
      expect(cartService.subtotal, greaterThanOrEqualTo(200.0));
    });

    test('should add item to cart and calculate correctly', () async {
      final menuItem = MenuItem(
        id: 'test-add-1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final initialCount = cartService.itemCount;
      final initialSubtotal = cartService.subtotal;

      await cartService.addItem(menuItem, quantity: 2);

      expect(cartService.itemCount, initialCount + 2);
      expect(cartService.subtotal, initialSubtotal + 200.0);
    });

    test('should calculate total correctly with multiple items', () async {
      final menuItem1 = MenuItem(
        id: 'test-multi-1',
        name: 'Item 1',
        description: 'Description 1',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final menuItem2 = MenuItem(
        id: 'test-multi-2',
        name: 'Item 2',
        description: 'Description 2',
        price: 50.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final initialCount = cartService.itemCount;
      final initialSubtotal = cartService.subtotal;

      await cartService.addItem(menuItem1, quantity: 2);
      await cartService.addItem(menuItem2, quantity: 3);

      expect(cartService.itemCount, initialCount + 5);
      expect(cartService.subtotal, initialSubtotal + 350.0); // (100*2) + (50*3) = 350
    });

    test('should remove item from cart', () async {
      final menuItem = MenuItem(
        id: 'test-remove-1',
        name: 'Test Item',
        description: 'Test Description',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
        isAvailable: true,
      );

      final initialCount = cartService.itemCount;
      await cartService.addItem(menuItem, quantity: 2);
      expect(cartService.itemCount, initialCount + 2);

      await cartService.removeItem(menuItem.id);
      expect(cartService.itemCount, initialCount);
    });
  });
}

