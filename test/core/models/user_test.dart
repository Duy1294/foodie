// Unit tests for User model
// Following Flutter docs: https://docs.flutter.dev/cookbook/testing/unit/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:foodie/core/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('should create User with required fields', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        fullName: 'Test User',
        role: UserRole.customer,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.id, '1');
      expect(user.email, 'test@test.com');
      expect(user.fullName, 'Test User');
      expect(user.role, UserRole.customer);
      expect(user.isVerified, false);
      expect(user.isActive, true);
    });

    test('should create User with all fields', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        phone: '123456789',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        role: UserRole.restaurantOwner,
        isVerified: true,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      expect(user.id, '1');
      expect(user.email, 'test@test.com');
      expect(user.phone, '123456789');
      expect(user.fullName, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.role, UserRole.restaurantOwner);
      expect(user.isVerified, true);
      expect(user.isActive, true);
    });

    test('should convert User to JSON', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        fullName: 'Test User',
        role: UserRole.customer,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['email'], 'test@test.com');
      expect(json['fullName'], 'Test User');
      expect(json['role'], 'customer');
    });

    test('should create User from JSON', () {
      final json = {
        'id': '1',
        'email': 'test@test.com',
        'fullName': 'Test User',
        'role': 'customer',
        'isVerified': false,
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.email, 'test@test.com');
      expect(user.fullName, 'Test User');
      expect(user.role, UserRole.customer);
    });

    test('should create copy of User with changes', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        fullName: 'Test User',
        role: UserRole.customer,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedUser = user.copyWith(
        fullName: 'Updated Name',
        phone: '123456789',
      );

      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
      expect(updatedUser.fullName, 'Updated Name');
      expect(updatedUser.phone, '123456789');
      expect(updatedUser.role, user.role);
    });
  });
}

