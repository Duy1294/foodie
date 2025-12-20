# 👥 TÀI KHOẢN VÀ PHÂN QUYỀN

## 📋 Tài khoản mẫu

Sau khi chạy `npm run seed`, các tài khoản sau đã được tạo:

### 🔴 Admin
- **Email:** `admin@foodie.com`
- **Password:** `admin123`
- **Tên:** Admin Quản Trị
- **Quyền:** Quản trị hệ thống toàn quyền

### 🏪 Restaurant Owner
- **Email:** `owner@foodie.com`
- **Password:** `password123`
- **Tên:** Nguyễn Minh Tuấn
- **Quyền:** Quản lý nhà hàng, menu, đơn hàng

### 🚚 Shipper 1
- **Email:** `shipper1@foodie.com`
- **Password:** `shipper123`
- **Tên:** Nguyễn Văn A
- **Quyền:** Giao hàng, nhận đơn hàng

### 🚚 Shipper 2
- **Email:** `shipper2@foodie.com`
- **Password:** `shipper123`
- **Tên:** Trần Văn B
- **Quyền:** Giao hàng, nhận đơn hàng

### 👤 Customer 1
- **Email:** `khach1@foodie.com`
- **Password:** `password123`
- **Tên:** Trần Thị Hương
- **Quyền:** Đặt hàng, xem đơn hàng

### 👤 Customer 2
- **Email:** `khach2@foodie.com`
- **Password:** `password123`
- **Tên:** Lê Văn Đức
- **Quyền:** Đặt hàng, xem đơn hàng

### 👤 Customer 3
- **Email:** `khach3@foodie.com`
- **Password:** `password123`
- **Tên:** Phạm Thị Mai
- **Quyền:** Đặt hàng, xem đơn hàng

## 🎯 Phân quyền theo Role

### Admin Dashboard
**Route:** `/admin/dashboard`

**Chức năng:**
- Quản lý Users (xem, chỉnh sửa, khóa/mở khóa)
- Quản lý Nhà hàng (duyệt, chỉnh sửa, xóa)
- Quản lý Đơn hàng (xem tất cả, can thiệp)
- Quản lý Shippers
- Thống kê & Báo cáo
- Cài đặt hệ thống

**Settings:** `/admin/settings`
- Thông báo hệ thống
- Bảo mật
- Thanh toán
- Giao hàng
- Thông tin cá nhân
- Đổi mật khẩu

### Restaurant Owner Dashboard
**Route:** `/restaurant/dashboard`

**Chức năng:**
- Xem thống kê đơn hàng, doanh thu
- Quản lý Menu (thêm, sửa, xóa món)
- Xử lý đơn hàng
- Thông tin Nhà hàng
- Thống kê

**Settings:** `/restaurant/settings`
- Thông tin Nhà hàng
- Quản lý Menu
- Cài đặt Giao hàng
- Giờ mở cửa
- Thông tin cá nhân
- Đổi mật khẩu

### Shipper Dashboard
**Route:** `/shipper/dashboard`

**Chức năng:**
- Bật/tắt trạng thái online
- Xem đơn hàng mới
- Xem đơn đang giao
- Lịch sử giao hàng
- Thống kê thu nhập

**Settings:** `/shipper/settings`
- Thông tin cá nhân
- Phương tiện
- Vị trí hiện tại
- Thông báo đơn hàng
- Giờ làm việc
- Khu vực giao hàng
- Thống kê

### Customer
**Route:** `/home` (Home Screen)

**Chức năng:**
- Xem danh sách nhà hàng
- Đặt hàng
- Xem đơn hàng
- Quản lý địa chỉ
- Profile

**Settings:** `/profile/settings`
- Thông tin cá nhân
- Địa chỉ giao hàng
- Thông báo
- Cài đặt

## 🔄 Routing Logic

App tự động route dựa trên role sau khi đăng nhập:

```dart
switch (user.role) {
  case UserRole.admin:
    → AdminDashboardScreen
  case UserRole.restaurantOwner:
    → RestaurantDashboardScreen
  case UserRole.driver:
    → ShipperDashboardScreen
  case UserRole.customer:
    → HomeScreen (customer)
}
```

## 📱 Navigation

### Từ Profile Screen
- Nếu là Admin/Restaurant Owner/Shipper → Hiển thị link đến Dashboard
- Click vào "Cài đặt" → Route đến Settings tương ứng với role

### Từ Dashboard
- Click vào Settings icon → Route đến Settings screen
- Các action tiles → Route đến các màn hình tương ứng

## 🧪 Test các Role

1. **Test Admin:**
   - Đăng nhập: `admin@foodie.com` / `admin123`
   - Sẽ vào Admin Dashboard
   - Có thể quản lý tất cả

2. **Test Restaurant Owner:**
   - Đăng nhập: `owner@foodie.com` / `password123`
   - Sẽ vào Restaurant Dashboard
   - Có thể quản lý nhà hàng, menu, đơn hàng

3. **Test Shipper:**
   - Đăng nhập: `shipper1@foodie.com` / `shipper123`
   - Sẽ vào Shipper Dashboard
   - Có thể nhận đơn hàng, giao hàng

4. **Test Customer:**
   - Đăng nhập: `khach1@foodie.com` / `password123`
   - Sẽ vào Home Screen
   - Có thể đặt hàng, xem đơn hàng

## 📝 Lưu ý

- Tất cả passwords đã được hash đúng cách
- Các accounts đã được verify và active
- Routing tự động dựa trên role
- Settings screen khác nhau cho mỗi role

