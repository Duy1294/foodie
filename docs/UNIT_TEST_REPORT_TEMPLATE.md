# 📊 Unit Test Report Template

## 📈 Test Summary

**Date:** [Date]
**Total Tests:** [X]
**Passed:** [X]
**Failed:** [X]
**Skipped:** [X]
**Success Rate:** [X]%

---

## 📋 Test Results by Category

### Models Tests
- ✅ User Model: 5/5 passed (100%)
- ✅ Order Model: [X]/[X] passed
- ✅ Restaurant Model: [X]/[X] passed
- ✅ MenuItem Model: [X]/[X] passed

### Services Tests
- ✅ CartService: 8/8 passed (100%)
- ⚠️ AuthService: [X]/[X] passed
- ⚠️ OrderService: [X]/[X] passed

### Business Logic Tests
- ✅ CartItem calculations: [X]/[X] passed
- ✅ Order calculations: [X]/[X] passed

---

## 📊 Code Coverage

**Overall Coverage:** [X]%

### By Module:
- Models: [X]%
- Services: [X]%
- Utils: [X]%

---

## ✅ Test Examples

### 1. User Model Test
```dart
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
  expect(user.role, UserRole.customer);
});
```

### 2. CartService Test
```dart
test('should calculate subtotal correctly', () async {
  final menuItem = MenuItem(/* ... */);
  await cartService.addItem(menuItem, quantity: 2);

  expect(cartService.subtotal, 200.0);
});
```

---

## 🎯 Recommendations

1. ✅ **Completed:** Models tests
2. ⚠️ **In Progress:** Services tests (cần mock dependencies)
3. ❌ **Pending:** Integration tests

---

## 📝 Notes

- Tests follow Flutter docs pattern: https://docs.flutter.dev/cookbook/testing/unit/introduction
- All tests use `flutter_test` package
- Tests are organized by feature/module

---

**Last Updated:** [Date]

