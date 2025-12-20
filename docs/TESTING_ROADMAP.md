# 🧪 Testing Roadmap - Kế hoạch Test

**Ngày tạo:** 2025-01-XX  
**Tham khảo:** [Flutter Testing Cookbook](https://docs.flutter.dev/cookbook/testing)

---

## 📊 Tình trạng hiện tại

### ✅ Đã có:
- ✅ **User Model Tests** - 5 tests (100% coverage cho core methods)
- ✅ **CartService Tests** - 4 tests (Core operations)
- ✅ **CartItem Tests** - 3 tests (Calculations, JSON)

**Tổng:** 12 tests đã pass

---

## 🎯 Các test nên làm tiếp

### Priority 1: Models Tests (Dễ nhất - Ưu tiên cao) ⭐⭐⭐⭐⭐

#### 1. **Order Model Tests** 
**File:** `test/core/models/order_test.dart`

**Tests cần làm:**
- ✅ Create Order với required fields
- ✅ Create Order với all fields
- ✅ Convert Order to JSON
- ✅ Create Order from JSON
- ✅ Test OrderStatus enum
- ✅ Test PaymentMethod enum
- ✅ Test OrderItem calculations

**Ưu tiên:** ⭐⭐⭐⭐⭐ (Quan trọng nhất)

---

#### 2. **Restaurant Model Tests**
**File:** `test/core/models/restaurant_test.dart`

**Tests cần làm:**
- ✅ Create Restaurant với required fields
- ✅ Create Restaurant với all fields
- ✅ Convert Restaurant to JSON
- ✅ Create Restaurant from JSON
- ✅ Test copyWith method

**Ưu tiên:** ⭐⭐⭐⭐

---

#### 3. **MenuItem Model Tests**
**File:** `test/core/models/menu_item_test.dart`

**Tests cần làm:**
- ✅ Create MenuItem với required fields
- ✅ Create MenuItem với all fields
- ✅ Convert MenuItem to JSON
- ✅ Create MenuItem from JSON
- ✅ Test copyWith method

**Ưu tiên:** ⭐⭐⭐⭐

---

### Priority 2: Widget Tests (Theo Flutter Cookbook) ⭐⭐⭐⭐

**Cookbook:** [Widget tests](https://docs.flutter.dev/cookbook/testing/widget/introduction)

#### 4. **Login Screen Widget Test**
**File:** `test/features/auth/presentation/screens/login_screen_test.dart`

**Tests cần làm:**
- ✅ Widget renders correctly
- ✅ Text fields are displayed
- ✅ Login button is displayed
- ✅ Google Sign-In button is displayed
- ✅ Form validation works
- ✅ Error messages display correctly

**Ưu tiên:** ⭐⭐⭐⭐

---

#### 5. **Restaurant Card Widget Test**
**File:** `test/features/restaurants/presentation/widgets/restaurant_card_test.dart`

**Tests cần làm:**
- ✅ Widget displays restaurant name
- ✅ Widget displays rating
- ✅ Widget displays delivery fee
- ✅ Tap navigates to detail screen

**Ưu tiên:** ⭐⭐⭐

---

#### 6. **Cart Screen Widget Test**
**File:** `test/features/cart/presentation/screens/cart_screen_test.dart`

**Tests cần làm:**
- ✅ Widget displays cart items
- ✅ Widget displays total
- ✅ Empty cart message displays
- ✅ Checkout button works

**Ưu tiên:** ⭐⭐⭐

---

### Priority 3: Mocking Tests (Nâng cao) ⭐⭐⭐

**Cookbook:** [Mock dependencies](https://docs.flutter.dev/cookbook/testing/mocking)

#### 7. **AuthService Tests với Mock**
**File:** `test/core/services/auth_service_test.dart`

**Tests cần làm:**
- ✅ Login với mock ApiService
- ✅ Register với mock ApiService
- ✅ Logout clears user data
- ✅ Error handling

**Cần:** Mock ApiService, Mock StorageService

**Ưu tiên:** ⭐⭐⭐

---

#### 8. **OrderService Tests với Mock**
**File:** `test/core/services/order_service_test.dart`

**Tests cần làm:**
- ✅ Create order với mock ApiService
- ✅ Calculate totals correctly
- ✅ Get orders với mock ApiService
- ✅ Error handling

**Cần:** Mock ApiService, Mock FirestoreService

**Ưu tiên:** ⭐⭐⭐

---

### Priority 4: Integration Tests (Nâng cao nhất) ⭐⭐

**Cookbook:** [Integration tests](https://docs.flutter.dev/cookbook/testing/integration)

#### 9. **Authentication Flow Integration Test**
**File:** `integration_test/auth_flow_test.dart`

**Tests cần làm:**
- ✅ Complete login flow
- ✅ Complete register flow
- ✅ Complete logout flow

**Ưu tiên:** ⭐⭐

---

#### 10. **Order Flow Integration Test**
**File:** `integration_test/order_flow_test.dart`

**Tests cần làm:**
- ✅ Browse restaurants → Add to cart → Checkout → Place order
- ✅ Complete order flow end-to-end

**Ưu tiên:** ⭐⭐

---

## 📋 Kế hoạch thực hiện

### Phase 1: Models Tests (Tuần 1) - **QUAN TRỌNG NHẤT**

1. ✅ Order Model Tests (6-8 tests)
2. ✅ Restaurant Model Tests (5-6 tests)
3. ✅ MenuItem Model Tests (5-6 tests)

**Target:** 16-20 tests mới

---

### Phase 2: Widget Tests (Tuần 2)

1. ✅ Login Screen Widget Test (5-6 tests)
2. ✅ Restaurant Card Widget Test (4-5 tests)
3. ✅ Cart Screen Widget Test (4-5 tests)

**Target:** 13-16 tests mới

---

### Phase 3: Mocking Tests (Tuần 3)

1. ✅ AuthService Tests với Mock (4-5 tests)
2. ✅ OrderService Tests với Mock (4-5 tests)

**Target:** 8-10 tests mới

---

### Phase 4: Integration Tests (Tuần 4)

1. ✅ Authentication Flow (2-3 tests)
2. ✅ Order Flow (2-3 tests)

**Target:** 4-6 tests mới

---

## 🎯 Target tổng thể

### Hiện tại:
- **12 tests** (User model: 5, CartService: 7)

### Sau khi hoàn thành:
- **Models Tests:** +16-20 tests
- **Widget Tests:** +13-16 tests
- **Mocking Tests:** +8-10 tests
- **Integration Tests:** +4-6 tests

**Tổng:** **53-64 tests** (tăng từ 12 lên 53-64)

---

## 📊 Test Coverage Goal

### Hiện tại:
- Models: ~20% (chỉ có User)
- Services: ~10% (chỉ có CartService)
- Widgets: ~0%

### Target:
- Models: **80%+** (tất cả models)
- Services: **50%+** (core services)
- Widgets: **30%+** (key screens)

---

## 🎓 So với Flutter Cookbook

Theo [Flutter Testing Cookbook](https://docs.flutter.dev/cookbook/testing):

### ✅ Đã có:
- ✅ Unit tests (theo [Unit tests guide](https://docs.flutter.dev/cookbook/testing/unit/introduction))
- ✅ Test groups
- ✅ Test structure

### ⚠️ Cần bổ sung:
- ⚠️ Widget tests (theo [Widget tests guide](https://docs.flutter.dev/cookbook/testing/widget/introduction))
- ⚠️ Mocking (theo [Mocking guide](https://docs.flutter.dev/cookbook/testing/mocking))
- ⚠️ Integration tests (theo [Integration tests guide](https://docs.flutter.dev/cookbook/testing/integration))

---

## 🚀 Bắt đầu từ đâu?

### Khuyến nghị: Bắt đầu với Models Tests

**Lý do:**
1. ✅ **Dễ nhất** - Không cần mock
2. ✅ **Quan trọng** - Models là foundation
3. ✅ **Nhanh** - Có thể làm nhiều tests trong thời gian ngắn
4. ✅ **Theo Cookbook** - Đúng pattern từ Flutter docs

**Bắt đầu với:**
1. Order Model Tests (quan trọng nhất)
2. Restaurant Model Tests
3. MenuItem Model Tests

---

**Last Updated:** 2025-01-XX

