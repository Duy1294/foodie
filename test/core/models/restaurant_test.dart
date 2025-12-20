// Unit tests for Restaurant model
// Following Flutter docs: https://docs.flutter.dev/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/core/models/restaurant.dart';

void main() {
  group('Restaurant Model Tests', () {
    test('should create Restaurant with required fields', () {
      final restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        address: '123 Main St',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.address, '123 Main St');
      expect(restaurant.deliveryFee, 0);
      expect(restaurant.minimumOrder, 0);
      expect(restaurant.ratingAverage, 0);
      expect(restaurant.isActive, true);
      expect(restaurant.isVerified, false);
    });

    test('should create Restaurant with all fields', () {
      final restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'A great restaurant',
        address: '123 Main St',
        latitude: 10.0,
        longitude: 106.0,
        phone: '123456789',
        email: 'test@restaurant.com',
        logoUrl: 'https://example.com/logo.jpg',
        coverImageUrl: 'https://example.com/cover.jpg',
        deliveryFee: 20.0,
        minimumOrder: 50.0,
        ratingAverage: 4.5,
        ratingCount: 100,
        isActive: true,
        isVerified: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.description, 'A great restaurant');
      expect(restaurant.latitude, 10.0);
      expect(restaurant.longitude, 106.0);
      expect(restaurant.phone, '123456789');
      expect(restaurant.email, 'test@restaurant.com');
      expect(restaurant.deliveryFee, 20.0);
      expect(restaurant.minimumOrder, 50.0);
      expect(restaurant.ratingAverage, 4.5);
      expect(restaurant.ratingCount, 100);
      expect(restaurant.isActive, true);
      expect(restaurant.isVerified, true);
    });

    test('should convert Restaurant to JSON', () {
      final restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        address: '123 Main St',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = restaurant.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test Restaurant');
      expect(json['address'], '123 Main St');
      expect(json['deliveryFee'], 0);
      expect(json['minimumOrder'], 0);
      expect(json['isActive'], true);
      expect(json['isVerified'], false);
    });

    test('should create Restaurant from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Restaurant',
        'address': '123 Main St',
        'deliveryFee': 20.0,
        'minimumOrder': 50.0,
        'ratingAverage': 4.5,
        'ratingCount': 100,
        'isActive': true,
        'isVerified': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final restaurant = Restaurant.fromJson(json);

      expect(restaurant.id, '1');
      expect(restaurant.name, 'Test Restaurant');
      expect(restaurant.address, '123 Main St');
      expect(restaurant.deliveryFee, 20.0);
      expect(restaurant.minimumOrder, 50.0);
      expect(restaurant.ratingAverage, 4.5);
      expect(restaurant.ratingCount, 100);
      expect(restaurant.isActive, true);
      expect(restaurant.isVerified, true);
    });

    test('should create copy of Restaurant with changes', () {
      final restaurant = Restaurant(
        id: '1',
        name: 'Test Restaurant',
        address: '123 Main St',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedRestaurant = restaurant.copyWith(
        name: 'Updated Restaurant',
        deliveryFee: 25.0,
        isVerified: true,
      );

      expect(updatedRestaurant.id, restaurant.id);
      expect(updatedRestaurant.name, 'Updated Restaurant');
      expect(updatedRestaurant.deliveryFee, 25.0);
      expect(updatedRestaurant.isVerified, true);
      expect(updatedRestaurant.address, restaurant.address);
    });
  });
}

