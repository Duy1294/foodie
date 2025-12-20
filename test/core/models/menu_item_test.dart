// Unit tests for MenuItem model
// Following Flutter docs: https://docs.flutter.dev/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/core/models/menu_item.dart';

void main() {
  group('MenuItem Model Tests', () {
    test('should create MenuItem with required fields', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(menuItem.id, '1');
      expect(menuItem.name, 'Test Item');
      expect(menuItem.price, 100.0);
      expect(menuItem.restaurantId, 'rest1');
      expect(menuItem.isAvailable, true);
      expect(menuItem.isPopular, false);
    });

    test('should create MenuItem with all fields', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        description: 'A delicious item',
        price: 100.0,
        restaurantId: 'rest1',
        categoryId: 'cat1',
        imageUrl: 'https://example.com/image.jpg',
        isAvailable: true,
        isPopular: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(menuItem.id, '1');
      expect(menuItem.name, 'Test Item');
      expect(menuItem.description, 'A delicious item');
      expect(menuItem.price, 100.0);
      expect(menuItem.restaurantId, 'rest1');
      expect(menuItem.categoryId, 'cat1');
      expect(menuItem.imageUrl, 'https://example.com/image.jpg');
      expect(menuItem.isAvailable, true);
      expect(menuItem.isPopular, true);
    });

    test('should convert MenuItem to JSON', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = menuItem.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Item');
      expect(json['price'], 100.0);
      expect(json['restaurantId'], 'rest1');
      expect(json['isAvailable'], true);
      expect(json['isPopular'], false);
    });

    test('should create MenuItem from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Item',
        'description': 'A delicious item',
        'price': 100.0,
        'restaurantId': 'rest1',
        'categoryId': 'cat1',
        'imageUrl': 'https://example.com/image.jpg',
        'isAvailable': true,
        'isPopular': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final menuItem = MenuItem.fromJson(json);

      expect(menuItem.id, '1');
      expect(menuItem.name, 'Test Item');
      expect(menuItem.description, 'A delicious item');
      expect(menuItem.price, 100.0);
      expect(menuItem.restaurantId, 'rest1');
      expect(menuItem.categoryId, 'cat1');
      expect(menuItem.imageUrl, 'https://example.com/image.jpg');
      expect(menuItem.isAvailable, true);
      expect(menuItem.isPopular, true);
    });

    test('should create copy of MenuItem with changes', () {
      final menuItem = MenuItem(
        id: '1',
        name: 'Test Item',
        price: 100.0,
        restaurantId: 'rest1',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedMenuItem = menuItem.copyWith(
        name: 'Updated Item',
        price: 150.0,
        isAvailable: false,
      );

      expect(updatedMenuItem.id, menuItem.id);
      expect(updatedMenuItem.name, 'Updated Item');
      expect(updatedMenuItem.price, 150.0);
      expect(updatedMenuItem.isAvailable, false);
      expect(updatedMenuItem.restaurantId, menuItem.restaurantId);
    });
  });
}

