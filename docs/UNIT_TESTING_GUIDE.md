# 🧪 Unit Testing Guide - Hướng dẫn Unit Test

## 📊 Test sẽ hiển thị như nào?

### 1. **Khi chạy test trong Terminal:**

```bash
flutter test
```

**Output sẽ hiển thị:**
```
00:02 +1: All tests passed!
```

**Nếu có test fail:**
```
00:02 +1 -1: Some tests failed.
  Failed tests:
    1) Counter value should be incremented
       Expected: <1>
       Actual: <0>
```

### 2. **Khi chạy test trong VS Code/IntelliJ:**

- ✅ **Green checkmark** nếu test pass
- ❌ **Red X** nếu test fail
- 📊 **Test coverage** hiển thị % code được test

### 3. **Test Report:**

```
Test Results:
✅ test/core/models/user_test.dart: 5/5 passed
✅ test/core/services/cart_service_test.dart: 8/8 passed
✅ test/core/services/auth_service_test.dart: 6/6 passed
Total: 19/19 passed (100%)
```

---

## ✅ Test có tính vào dự án không?

**CÓ!** Test là một phần quan trọng của dự án:

### 1. **Code Coverage (Độ phủ code)**
- Đo lường % code được test
- Target: **70%+ coverage** cho production apps
- Có thể xem bằng: `flutter test --coverage`

### 2. **CI/CD Integration**
- Test tự động chạy khi push code
- Đảm bảo code quality
- Ngăn chặn bugs

### 3. **Documentation**
- Test là documentation sống
- Giải thích cách code hoạt động
- Ví dụ sử dụng code

---

## 📝 Báo cáo như nào?

### 1. **Test Summary Report:**

```markdown
# Unit Test Report

## Test Coverage: 75%

### Models (100%)
- ✅ User model: 5/5 tests passed
- ✅ Order model: 4/4 tests passed
- ✅ Restaurant model: 3/3 tests passed

### Services (70%)
- ✅ AuthService: 6/6 tests passed
- ✅ CartService: 8/8 tests passed
- ⚠️ OrderService: 4/6 tests passed (2 skipped - need mock)

### Total: 30/32 tests passed (93.75%)
```

### 2. **Code Coverage Report:**

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Sẽ tạo file HTML report:**
- `coverage/html/index.html` - Xem coverage trong browser
- Hiển thị % coverage cho từng file
- Highlight code chưa được test

---

## 🎯 Nếu làm theo docs cơ bản thì sẽ test phần nào?

Theo [Flutter Unit Testing Documentation](https://docs.flutter.dev/cookbook/testing/unit/introduction), nên test:

### 1. **Models (Quan trọng nhất - Dễ nhất)**

**Test:**
- ✅ `fromJson()` - Parse JSON thành object
- ✅ `toJson()` - Convert object thành JSON
- ✅ `copyWith()` - Tạo copy với thay đổi

**Ví dụ:**
- `User` model
- `Order` model
- `Restaurant` model
- `MenuItem` model

### 2. **Business Logic Classes**

**Test:**
- ✅ Methods tính toán
- ✅ Validation logic
- ✅ State changes

**Ví dụ:**
- `CartItem` - Tính subtotal
- `CartService` - Add/remove items, tính total
- Utility functions

### 3. **Services (Cần mock dependencies)**

**Test:**
- ✅ Business logic trong services
- ✅ Error handling
- ✅ Data transformation

**Ví dụ:**
- `AuthService` - Login/register logic (với mock API)
- `CartService` - Cart operations
- `OrderService` - Order calculations

---

## 📋 Kế hoạch Test cho Foodie

### Phase 1: Models (Dễ nhất - Ưu tiên cao)

1. ✅ `User` model
2. ✅ `Order` model
3. ✅ `Restaurant` model
4. ✅ `MenuItem` model
5. ✅ `CartItem` model

### Phase 2: Business Logic (Trung bình)

1. ✅ `CartItem.subtotal` calculation
2. ✅ `CartService` operations
3. ✅ Order calculations

### Phase 3: Services (Khó - Cần mock)

1. ⚠️ `AuthService` (cần mock ApiService, StorageService)
2. ⚠️ `OrderService` (cần mock ApiService)
3. ⚠️ `RestaurantService` (cần mock ApiService)

---

## 🎯 Target cho Course

**Minimum requirements:**
- ✅ 5-10 unit tests
- ✅ Test ít nhất 2 models
- ✅ Test ít nhất 1 service hoặc business logic class
- ✅ 50%+ code coverage

**Recommended:**
- ✅ 20+ unit tests
- ✅ Test tất cả models
- ✅ Test business logic classes
- ✅ 70%+ code coverage

---

## 📊 Test Structure

```
test/
├── core/
│   ├── models/
│   │   ├── user_test.dart
│   │   ├── order_test.dart
│   │   └── restaurant_test.dart
│   └── services/
│       ├── cart_service_test.dart
│       └── auth_service_test.dart
└── widget_test.dart (existing)
```

---

**Last Updated:** 2025-01-XX

