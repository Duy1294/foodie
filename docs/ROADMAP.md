# 🗺️ Kế hoạch phát triển Foodie App

## 📊 Tổng quan

Tài liệu này liệt kê các chức năng chưa hoàn thiện và kế hoạch triển khai theo thứ tự ưu tiên.

---

## ✅ Đã hoàn thành

### Core Features
- ✅ Authentication (Login, Register, Logout)
- ✅ User Profile Management
- ✅ Restaurant Listing & Details
- ✅ Menu Display
- ✅ Shopping Cart
- ✅ Order Creation & Management
- ✅ Order History
- ✅ Role-based Dashboards (Admin, Restaurant Owner, Shipper)
- ✅ Basic Settings Screens

### Backend
- ✅ RESTful API với Express.js
- ✅ MongoDB Database
- ✅ Authentication & Authorization
- ✅ Order Management
- ✅ Data Seeding với sample data

---

## 🚧 Chức năng chưa hoàn thiện

### 🔴 Priority 1: Core Features (Quan trọng nhất)

#### 1. **Đổi mật khẩu** (Tất cả roles)
- **Vị trí**: 
  - `lib/features/admin/presentation/screens/admin_settings_screen.dart:87`
  - `lib/features/restaurant/presentation/screens/restaurant_settings_screen.dart:86`
  - `lib/features/shipper/presentation/screens/shipper_settings_screen.dart:105`
- **Mô tả**: Màn hình cho phép user đổi mật khẩu
- **Cần làm**:
  - Tạo `change_password_screen.dart`
  - API endpoint: `PUT /api/v1/users/change-password`
  - Validation: mật khẩu cũ, mật khẩu mới, xác nhận mật khẩu
- **Ưu tiên**: ⭐⭐⭐⭐⭐

#### 2. **Quên mật khẩu / Reset Password**
- **Vị trí**: `lib/features/auth/presentation/screens/login_screen.dart:160`
- **Mô tả**: Flow quên mật khẩu với email verification
- **Cần làm**:
  - Tạo `forgot_password_screen.dart`
  - Tạo `reset_password_screen.dart`
  - API endpoints: `POST /api/v1/auth/forgot-password`, `POST /api/v1/auth/reset-password`
  - Email service integration
- **Ưu tiên**: ⭐⭐⭐⭐

#### 3. **Quản lý địa chỉ giao hàng**
- **Vị trí**: `lib/features/profile/presentation/screens/address_management_screen.dart:16`
- **Mô tả**: Thêm, sửa, xóa địa chỉ giao hàng
- **Cần làm**:
  - Tạo `add_edit_address_screen.dart`
  - API endpoints: `GET/POST/PUT/DELETE /api/v1/addresses`
  - Map integration để chọn địa chỉ
- **Ưu tiên**: ⭐⭐⭐⭐⭐

#### 4. **Tìm kiếm nhà hàng**
- **Vị trí**: `lib/features/restaurants/presentation/screens/restaurant_list_screen.dart:55`
- **Mô tả**: Tìm kiếm nhà hàng theo tên, địa chỉ, món ăn
- **Cần làm**:
  - Tạo search bar với filter
  - API endpoint: `GET /api/v1/restaurants/search?q=...`
  - Real-time search suggestions
- **Ưu tiên**: ⭐⭐⭐⭐

---

### 🟡 Priority 2: Admin Features ✅ HOÀN THÀNH

#### 5. **Quản lý Users** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart:99,161`
- **Mô tả**: Xem, chỉnh sửa, khóa/mở khóa tài khoản users
- **Đã hoàn thành**:
  - ✅ Tạo `admin_users_screen.dart` với filter, search, pagination
  - ✅ API endpoints: `GET/PUT/DELETE /api/v1/admin/users`
  - ✅ Filter: role, status, search
  - ✅ Actions: edit, delete, view details
- **Ưu tiên**: ⭐⭐⭐⭐

#### 6. **Quản lý Nhà hàng** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart:111,169`
- **Mô tả**: Duyệt, chỉnh sửa, xóa nhà hàng
- **Đã hoàn thành**:
  - ✅ Tạo `admin_restaurants_screen.dart` với filter, search, pagination
  - ✅ API endpoints: `GET/PUT/DELETE /api/v1/admin/restaurants`
  - ✅ Actions: approve/reject (isVerified), edit (isActive), delete
- **Ưu tiên**: ⭐⭐⭐⭐

#### 7. **Quản lý Đơn hàng** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart:127,177`
- **Mô tả**: Xem tất cả đơn hàng, can thiệp khi cần
- **Đã hoàn thành**:
  - ✅ Tạo `admin_orders_screen.dart` với filter theo status
  - ✅ API endpoint: `GET /api/v1/admin/orders`
  - ✅ Filter: status, pagination
  - ✅ Click vào order để xem chi tiết
- **Ưu tiên**: ⭐⭐⭐⭐

#### 8. **Quản lý Shippers** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart:139,185`
- **Mô tả**: Xem, chỉnh sửa thông tin shipper
- **Đã hoàn thành**:
  - ✅ Tạo `admin_shippers_screen.dart` với filter, search, pagination
  - ✅ API endpoints: `GET/PUT /api/v1/admin/shippers`
  - ✅ Actions: edit shipper info (fullName, phone, isActive, isVerified)
- **Ưu tiên**: ⭐⭐⭐

#### 9. **Thống kê & Báo cáo** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_dashboard_screen.dart:193`
- **Mô tả**: Xem báo cáo doanh thu, đơn hàng
- **Đã hoàn thành**:
  - ✅ Tạo `admin_analytics_screen.dart`
  - ✅ Hiển thị: total users, restaurants, orders, shippers
  - ✅ Hiển thị: total revenue, pending/delivered orders
  - ✅ Hiển thị: active/verified restaurants
- **Ưu tiên**: ⭐⭐⭐

#### 10. **Cài đặt hệ thống** (Admin) ✅
- **Vị trí**: `lib/features/admin/presentation/screens/admin_settings_screen.dart`
- **Mô tả**: Cấu hình hệ thống
- **Đã hoàn thành**:
  - ✅ **Thông báo hệ thống**: `admin_notification_settings_screen.dart` - Toggle các loại notifications
  - ✅ **Bảo mật**: `admin_security_settings_screen.dart` - Password policy, 2FA, session timeout
  - ✅ **Thanh toán**: `admin_payment_settings_screen.dart` - Enable/disable payment methods
  - ✅ **Giao hàng**: `admin_delivery_settings_screen.dart` - Cấu hình phí giao hàng
- **Ưu tiên**: ⭐⭐⭐

---

### 🟢 Priority 3: Restaurant Owner Features

#### 11. **Quản lý Menu** (Restaurant Owner)
- **Vị trí**: `lib/features/restaurant/presentation/screens/restaurant_settings_screen.dart:43`
- **Mô tả**: Thêm, sửa, xóa món ăn
- **Cần làm**:
  - Tạo `restaurant_menu_management_screen.dart`
  - Tạo `add_edit_menu_item_screen.dart`
  - API endpoints: `GET/POST/PUT/DELETE /api/v1/restaurants/menu`
  - Image upload
- **Ưu tiên**: ⭐⭐⭐⭐⭐

#### 12. **Thông tin Nhà hàng** (Restaurant Owner)
- **Vị trí**: `lib/features/restaurant/presentation/screens/restaurant_settings_screen.dart:35`
- **Mô tả**: Chỉnh sửa thông tin nhà hàng
- **Cần làm**:
  - Tạo `restaurant_info_screen.dart`
  - API endpoint: `PUT /api/v1/restaurants/:id`
  - Image upload (logo, cover)
- **Ưu tiên**: ⭐⭐⭐⭐

#### 13. **Cài đặt Giao hàng** (Restaurant Owner)
- **Vị trí**: `lib/features/restaurant/presentation/screens/restaurant_settings_screen.dart:51`
- **Mô tả**: Phí giao hàng, đơn tối thiểu, khu vực
- **Cần làm**:
  - Tạo `restaurant_delivery_settings_screen.dart`
  - API endpoint: `PUT /api/v1/restaurants/:id/delivery`
- **Ưu tiên**: ⭐⭐⭐

#### 14. **Giờ mở cửa** (Restaurant Owner)
- **Vị trí**: `lib/features/restaurant/presentation/screens/restaurant_settings_screen.dart:59`
- **Mô tả**: Thiết lập giờ mở/đóng cửa
- **Cần làm**:
  - Tạo `restaurant_opening_hours_screen.dart`
  - API endpoint: `PUT /api/v1/restaurants/:id/hours`
- **Ưu tiên**: ⭐⭐⭐

---

### 🔵 Priority 4: Shipper Features ✅ **COMPLETED**

#### 15. **Thông tin Phương tiện** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_vehicle_info_screen.dart`
- **Mô tả**: Thông tin xe, biển số
- **Đã làm**:
  - ✅ Tạo `shipper_vehicle_info_screen.dart`
  - ✅ API endpoint: `PUT /api/v1/shippers/vehicle`
  - ✅ Form với dropdown cho loại phương tiện, text fields cho biển số, hãng, model
- **Ưu tiên**: ⭐⭐⭐

#### 16. **Vị trí hiện tại** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_location_screen.dart`
- **Mô tả**: Cập nhật vị trí GPS
- **Đã làm**:
  - ✅ Tạo `shipper_location_screen.dart` với GPS integration
  - ✅ API endpoint: `POST /api/v1/shippers/location`
  - ✅ Sử dụng `geolocator` package để lấy vị trí hiện tại
  - ✅ Hiển thị vĩ độ, kinh độ, thời gian cập nhật cuối
- **Ưu tiên**: ⭐⭐⭐⭐

#### 17. **Cài đặt giao hàng** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_settings_screen.dart`
- **Mô tả**: 
  - **Thông báo đơn hàng** ✅: `shipper_notification_settings_screen.dart`
  - **Giờ làm việc** ✅: `shipper_working_hours_screen.dart`
  - **Khu vực giao hàng** ✅: `shipper_delivery_areas_screen.dart`
- **Đã làm**:
  - ✅ Tạo các màn hình tương ứng
  - ✅ API endpoints: `/shippers/settings/notifications`, `/shippers/settings/working-hours`, `/shippers/settings/delivery-areas`
  - ✅ Working hours với time picker cho từng ngày trong tuần
  - ✅ Delivery areas với add/remove functionality
- **Ưu tiên**: ⭐⭐⭐

#### 18. **Thống kê** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_analytics_screen.dart`
- **Mô tả**: Xem thống kê thu nhập, đơn hàng
- **Đã làm**:
  - ✅ Tạo `shipper_analytics_screen.dart`
  - ✅ Hiển thị: tổng đơn, đơn hôm nay, đang giao, đã hoàn thành, thu nhập, đánh giá
  - ✅ Tính toán từ orders của shipper
- **Ưu tiên**: ⭐⭐⭐

#### 19. **Quản lý đơn hàng** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_orders_screen.dart`
- **Mô tả**: Xem và quản lý đơn hàng theo trạng thái
- **Đã làm**:
  - ✅ Tạo `shipper_orders_screen.dart` với filter theo status
  - ✅ Các tab: Đơn hàng mới, Đơn đang giao, Lịch sử giao hàng
  - ✅ Navigation từ dashboard
- **Ưu tiên**: ⭐⭐⭐⭐

#### 20. **Online Status** (Shipper) ✅
- **Vị trí**: `lib/features/shipper/presentation/screens/shipper_dashboard_screen.dart`
- **Mô tả**: Bật/tắt trạng thái online để nhận đơn
- **Đã làm**:
  - ✅ Toggle switch trong dashboard
  - ✅ API endpoint: `PUT /api/v1/shippers/online-status`
  - ✅ Cập nhật real-time
- **Ưu tiên**: ⭐⭐⭐⭐

---

### 🟣 Priority 5: User Experience ✅ **COMPLETED**

#### 19. **Thông báo** (Tất cả roles) ✅
- **Vị trí**: `lib/features/notifications/presentation/screens/notifications_screen.dart`
- **Mô tả**: Xem thông báo đơn hàng, khuyến mãi cho tất cả roles
- **Đã hoàn thành**:
  - ✅ Tạo `Notification` model và `NotificationService`
  - ✅ Backend routes: `GET/PUT/DELETE /api/v1/notifications`
  - ✅ Tạo `NotificationsScreen` với filter (all/unread/read)
  - ✅ Tích hợp vào Profile Screen, Admin Dashboard, Restaurant Dashboard, Shipper Dashboard
  - ✅ Tự động tạo notifications khi:
    - Customer đặt đơn → Restaurant nhận thông báo
    - Restaurant xác nhận đơn → Customer nhận thông báo
    - Shipper nhận đơn → Restaurant và Customer nhận thông báo
    - Order status thay đổi → Tất cả liên quan nhận thông báo
  - ✅ Mark as read, delete, mark all as read
- **Ưu tiên**: ⭐⭐⭐

#### 20. **Cài đặt** (Customer)
- **Vị trí**: `lib/features/profile/presentation/screens/settings_screen.dart`
- **Mô tả**: 
  - **Ngôn ngữ** (line 22): Chọn ngôn ngữ
  - **Giao diện** (line 36): Chọn theme (light/dark)
  - **Thông báo** (line 50): Bật/tắt notifications
  - **Quyền riêng tư** (line 61): Privacy settings
  - **Điều khoản** (line 93): Terms of service
  - **Chính sách bảo mật** (line 106): Privacy policy
- **Cần làm**:
  - Implement các settings
  - Localization support
  - Theme provider
- **Ưu tiên**: ⭐⭐

#### 21. **Hỗ trợ** (Customer)
- **Vị trí**: `lib/features/profile/presentation/screens/profile_screen.dart:167`
- **Mô tả**: FAQ, liên hệ hỗ trợ
- **Cần làm**:
  - Tạo `help_support_screen.dart`
  - FAQ section
  - Contact form
- **Ưu tiên**: ⭐⭐

---

### ⚪ Priority 6: Advanced Features

#### 22. **Reviews & Ratings**
- **Mô tả**: Đánh giá nhà hàng, món ăn
- **Cần làm**:
  - Tạo `review_screen.dart`
  - API endpoints: `GET/POST /api/v1/reviews`
  - Star ratings, comments, photos
- **Ưu tiên**: ⭐⭐⭐

#### 23. **Vouchers & Promotions**
- **Mô tả**: Mã giảm giá, khuyến mãi
- **Cần làm**:
  - Tạo `vouchers_screen.dart`
  - API endpoints: `GET/POST /api/v1/vouchers`
  - Apply voucher in checkout
- **Ưu tiên**: ⭐⭐⭐

#### 24. **Payment Integration**
- **Mô tả**: Tích hợp payment gateways (Momo, ZaloPay, VNPay)
- **Cần làm**:
  - Payment SDK integration
  - Webhook handling
  - Payment history
- **Ưu tiên**: ⭐⭐⭐⭐

#### 25. **Real-time Order Tracking**
- **Mô tả**: Theo dõi đơn hàng real-time
- **Cần làm**:
  - WebSocket/Socket.io integration
  - Map integration
  - Push notifications
- **Ưu tiên**: ⭐⭐⭐⭐

#### 26. **Chat Support**
- **Mô tả**: Chat với nhà hàng, shipper
- **Cần làm**:
  - Real-time chat
  - Message history
  - File sharing
- **Ưu tiên**: ⭐⭐

---

## 📅 Kế hoạch triển khai

### Phase 1: Core Features (Tuần 1-2)
1. ✅ Đổi mật khẩu
2. ✅ Quản lý địa chỉ giao hàng
3. ✅ Tìm kiếm nhà hàng
4. ✅ Quên mật khẩu

### Phase 2: Admin Features (Tuần 3-4) ✅ HOÀN THÀNH
5. ✅ Quản lý Users - Backend routes + Flutter screen với filter, edit, delete
6. ✅ Quản lý Nhà hàng - Backend routes + Flutter screen với approve/reject, edit, delete
7. ✅ Quản lý Đơn hàng - Backend routes + Flutter screen với filter theo status
8. ✅ Quản lý Shippers - Backend routes + Flutter screen với edit shipper info
9. ✅ Thống kê & Báo cáo - Flutter screen với tổng quan stats
10. ✅ Cài đặt hệ thống - 4 screens: Notifications, Security, Payment, Delivery

### Phase 3: Restaurant Owner Features (Tuần 5-6)
10. ✅ Quản lý Menu
11. ✅ Thông tin Nhà hàng
12. ✅ Cài đặt Giao hàng
13. ✅ Giờ mở cửa

### Phase 4: Shipper Features (Tuần 7)
14. ✅ Thông tin Phương tiện
15. ✅ Vị trí hiện tại (GPS tracking)
16. ✅ Cài đặt giao hàng
17. ✅ Thống kê

### Phase 5: User Experience (Tuần 8)
18. ✅ Thông báo
19. ✅ Cài đặt (Language, Theme)
20. ✅ Hỗ trợ

### Phase 6: Advanced Features (Tuần 9-10)
21. ✅ Reviews & Ratings
22. ✅ Vouchers & Promotions
23. ✅ Payment Integration
24. ✅ Real-time Order Tracking

---

## 🛠️ Technical Debt

### Backend
- [ ] Implement logout endpoint (`POST /api/v1/auth/logout`)
- [ ] Add image upload service
- [ ] Add email service for password reset
- [ ] Add WebSocket support for real-time updates
- [ ] Add payment gateway integration
- [ ] Add notification service (FCM)

### Frontend
- [ ] Add error handling improvements
- [ ] Add loading states
- [ ] Add offline support
- [ ] Add image caching
- [ ] Add localization (i18n)
- [ ] Add theme provider
- [ ] Add state management improvements

### Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests

---

## 📝 Notes

- Ưu tiên các tính năng core trước
- Mỗi phase nên có testing và review
- Cập nhật documentation sau mỗi feature
- Backup database trước khi deploy

---

**Last Updated**: 2025-12-19

