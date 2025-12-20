# TÀI LIỆU YÊU CẦU - ỨNG DỤNG ĐẶT ĐỒ ĂN (FOODIE)

## 1. PHÂN QUYỀN NGƯỜI DÙNG

### 1.1. Khách hàng (Customer)
**Quyền truy cập:**
- Xem danh sách nhà hàng/quán ăn
- Tìm kiếm nhà hàng và món ăn
- Xem chi tiết menu, giá cả, đánh giá
- Thêm món vào giỏ hàng
- Đặt hàng và thanh toán
- Theo dõi trạng thái đơn hàng real-time
- Xem lịch sử đơn hàng
- Đánh giá và nhận xét nhà hàng/tài xế
- Quản lý địa chỉ giao hàng
- Quản lý thông tin cá nhân
- Xem voucher/khuyến mãi
- Áp dụng mã giảm giá

**Hạn chế:**
- Không thể chỉnh sửa menu nhà hàng
- Không thể xem thông tin tài chính của nhà hàng
- Không thể quản lý đơn hàng của người khác

### 1.2. Nhà hàng/Quán ăn (Restaurant Owner)
**Quyền truy cập:**
- Quản lý thông tin nhà hàng (tên, địa chỉ, giờ mở cửa, hình ảnh)
- Quản lý menu (thêm, sửa, xóa món ăn)
- Cập nhật giá cả và trạng thái món ăn (còn hàng/hết hàng)
- Xem và quản lý đơn hàng
- Cập nhật trạng thái đơn hàng (đã nhận, đang chuẩn bị, sẵn sàng giao)
- Xem thống kê doanh thu, số lượng đơn hàng
- Quản lý đánh giá và phản hồi khách hàng
- Quản lý voucher/khuyến mãi của nhà hàng
- Xem báo cáo chi tiết

**Hạn chế:**
- Không thể xem thông tin khách hàng khác (ngoài đơn hàng của mình)
- Không thể quản lý tài xế
- Không thể chỉnh sửa thông tin hệ thống

### 1.3. Tài xế giao hàng (Delivery Driver)
**Quyền truy cập:**
- Xem danh sách đơn hàng cần giao
- Nhận đơn hàng
- Xem chi tiết đơn hàng và địa chỉ giao hàng
- Cập nhật trạng thái giao hàng (đã lấy hàng, đang giao, đã giao)
- Xem lịch sử đơn hàng đã giao
- Xem thu nhập và thống kê
- Quản lý trạng thái hoạt động (online/offline)
- Xem bản đồ và chỉ đường

**Hạn chế:**
- Không thể chỉnh sửa thông tin đơn hàng
- Không thể xem thông tin tài chính của nhà hàng
- Không thể quản lý menu

### 1.4. Quản trị viên (Admin)
**Quyền truy cập:**
- Quản lý toàn bộ người dùng (khách hàng, nhà hàng, tài xế)
- Duyệt đăng ký nhà hàng mới
- Quản lý danh mục món ăn
- Xem tất cả đơn hàng và can thiệp khi cần
- Quản lý voucher/khuyến mãi hệ thống
- Xem báo cáo tổng quan và thống kê
- Quản lý cài đặt hệ thống
- Xử lý khiếu nại và hỗ trợ khách hàng

## 2. CHỨC NĂNG CHÍNH

### 2.1. Xác thực và Quản lý Tài khoản
- **Đăng ký:** Email, số điện thoại, OAuth (Google, Facebook, Apple)
- **Đăng nhập:** Email/Phone + Password, OTP, Social Login
- **Quên mật khẩu:** Reset qua email/SMS
- **Xác thực 2 bước:** OTP qua SMS/Email
- **Quản lý profile:** Avatar, tên, email, số điện thoại
- **Đăng xuất:** Single device hoặc all devices

### 2.2. Tìm kiếm và Duyệt
- **Tìm kiếm:** Nhà hàng, món ăn theo tên, từ khóa
- **Lọc:** Theo khoảng cách, đánh giá, giá cả, loại món ăn
- **Sắp xếp:** Phổ biến, đánh giá cao, gần nhất, giá thấp-cao
- **Danh mục:** Phân loại món ăn (Đồ ăn nhanh, Đồ chay, Đồ uống, v.v.)
- **Gợi ý:** Dựa trên lịch sử đặt hàng và sở thích

### 2.3. Chi tiết Nhà hàng và Menu
- **Thông tin nhà hàng:**
  - Tên, địa chỉ, số điện thoại
  - Giờ mở cửa/đóng cửa
  - Hình ảnh, đánh giá trung bình
  - Thời gian giao hàng ước tính
  - Phí giao hàng
  - Voucher/khuyến mãi hiện có
- **Menu:**
  - Danh sách món ăn với hình ảnh
  - Giá cả, mô tả
  - Tùy chọn (size, topping, ghi chú)
  - Trạng thái còn hàng/hết hàng
  - Món phổ biến, món mới

### 2.4. Giỏ hàng và Đặt hàng
- **Giỏ hàng:**
  - Thêm/xóa/sửa số lượng món
  - Áp dụng mã giảm giá
  - Tính tổng tiền (món ăn + phí giao hàng - giảm giá)
  - Lưu giỏ hàng tạm thời
- **Đặt hàng:**
  - Chọn địa chỉ giao hàng
  - Chọn phương thức thanh toán
  - Thêm ghi chú cho nhà hàng
  - Xác nhận đơn hàng
  - Tạo đơn hàng và nhận mã đơn

### 2.5. Thanh toán
- **Phương thức thanh toán:**
  - Tiền mặt (COD)
  - Thẻ tín dụng/ghi nợ
  - Ví điện tử (MoMo, ZaloPay, ShopeePay, v.v.)
  - Ví trong app
- **Bảo mật:** Tokenization, mã hóa thông tin thẻ
- **Lưu thông tin:** Lưu thẻ đã dùng (tùy chọn)

### 2.6. Theo dõi Đơn hàng (Real-time)
- **Trạng thái đơn hàng:**
  1. Đã đặt (Pending)
  2. Nhà hàng đã nhận (Confirmed)
  3. Đang chuẩn bị (Preparing)
  4. Sẵn sàng giao (Ready)
  5. Tài xế đã nhận (Picked up)
  6. Đang giao (On the way)
  7. Đã giao (Delivered)
  8. Đã hủy (Cancelled)
- **Thông tin real-time:**
  - Vị trí tài xế trên bản đồ
  - Thời gian ước tính đến
  - Thông tin tài xế (tên, số điện thoại, biển số xe)
- **Thông báo:** Push notification cho mỗi cập nhật trạng thái

### 2.7. Đánh giá và Nhận xét
- **Đánh giá nhà hàng:**
  - Số sao (1-5)
  - Nhận xét bằng văn bản
  - Upload hình ảnh món ăn
  - Đánh giá theo tiêu chí (vị, chất lượng, giao hàng)
- **Đánh giá tài xế:**
  - Số sao
  - Nhận xét về thái độ, tốc độ giao hàng
- **Phản hồi:** Nhà hàng có thể phản hồi đánh giá

### 2.8. Quản lý Địa chỉ
- **Thêm địa chỉ:**
  - Tự động lấy từ GPS
  - Nhập thủ công
  - Chọn từ bản đồ
- **Lưu địa chỉ:** Nhà, công ty, địa chỉ khác
- **Đặt mặc định:** Chọn địa chỉ giao hàng mặc định
- **Sửa/Xóa:** Quản lý danh sách địa chỉ

### 2.9. Khuyến mãi và Voucher
- **Voucher hệ thống:**
  - Giảm giá theo phần trăm
  - Giảm giá cố định
  - Miễn phí giao hàng
- **Voucher nhà hàng:**
  - Khuyến mãi riêng của từng nhà hàng
- **Điều kiện áp dụng:**
  - Giá trị đơn hàng tối thiểu
  - Thời gian hiệu lực
  - Số lượng có hạn
- **Mã giảm giá:** Nhập mã thủ công

### 2.10. Thông báo
- **Push Notification:**
  - Cập nhật trạng thái đơn hàng
  - Khuyến mãi mới
  - Nhắc nhở đánh giá sau khi nhận hàng
  - Thông báo hệ thống
- **In-app Notification:**
  - Tin nhắn trong app
  - Thông báo đơn hàng mới (cho nhà hàng/tài xế)

### 2.11. Quản lý Nhà hàng (Restaurant Owner)
- **Dashboard:**
  - Tổng quan doanh thu, đơn hàng hôm nay
  - Biểu đồ thống kê
- **Quản lý menu:**
  - CRUD món ăn
  - Upload hình ảnh
  - Quản lý danh mục
  - Cập nhật giá và trạng thái
- **Quản lý đơn hàng:**
  - Xem danh sách đơn hàng
  - Lọc theo trạng thái, ngày
  - Cập nhật trạng thái
  - In hóa đơn
- **Thống kê:**
  - Doanh thu theo ngày/tuần/tháng
  - Món bán chạy
  - Đánh giá trung bình

### 2.12. Quản lý Tài xế (Delivery Driver)
- **Dashboard:**
  - Đơn hàng đang giao
  - Thu nhập hôm nay/tuần/tháng
- **Nhận đơn:**
  - Xem danh sách đơn hàng sẵn sàng
  - Nhận đơn hàng
  - Từ chối đơn hàng
- **Giao hàng:**
  - Xem bản đồ và chỉ đường
  - Cập nhật trạng thái
  - Liên hệ khách hàng/nhà hàng
- **Thống kê:**
  - Số đơn đã giao
  - Thu nhập
  - Đánh giá trung bình

## 3. PHÂN QUYỀN HỆ THỐNG (SYSTEM PERMISSIONS)

### 3.1. Android Permissions
```xml
<!-- Vị trí -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet và Network -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera và Storage -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Thông báo -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Điện thoại (cho tài xế liên hệ khách hàng) -->
<uses-permission android:name="android.permission.CALL_PHONE" />

<!-- Background Location (cho tài xế) -->
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 3.2. iOS Permissions
- **Location Services:** Always/When In Use
- **Camera:** Chụp ảnh món ăn, đánh giá
- **Photo Library:** Chọn ảnh từ thư viện
- **Push Notifications:** Thông báo đơn hàng
- **Contacts:** (Tùy chọn) Đồng bộ địa chỉ

## 4. KIẾN TRÚC HỆ THỐNG

### 4.1. Flutter Architecture
- **State Management:** Provider / Riverpod / Bloc
- **Architecture Pattern:** Clean Architecture / MVVM
- **Dependency Injection:** GetIt / Provider

### 4.2. Backend
- **API:** RESTful API hoặc GraphQL
- **Real-time:** WebSocket / Firebase Realtime Database / Socket.io
- **Authentication:** JWT Token / OAuth 2.0
- **Database:** PostgreSQL / MySQL / MongoDB
- **File Storage:** AWS S3 / Firebase Storage / Cloudinary

### 4.3. Third-party Services
- **Maps:** Google Maps / Mapbox
- **Payment:** Stripe / PayPal / MoMo / ZaloPay SDK
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Analytics:** Firebase Analytics / Mixpanel
- **Crash Reporting:** Firebase Crashlytics / Sentry

## 5. CẤU TRÚC DATABASE

### 5.1. Các Bảng Chính
- **Users:** Thông tin người dùng (khách hàng, nhà hàng, tài xế, admin)
- **Restaurants:** Thông tin nhà hàng
- **Menu Items:** Món ăn
- **Categories:** Danh mục món ăn
- **Orders:** Đơn hàng
- **Order Items:** Chi tiết món trong đơn hàng
- **Addresses:** Địa chỉ giao hàng
- **Payments:** Giao dịch thanh toán
- **Reviews:** Đánh giá
- **Vouchers:** Mã giảm giá
- **Notifications:** Thông báo
- **Delivery Drivers:** Thông tin tài xế
- **Driver Locations:** Vị trí tài xế (real-time)

## 6. API ENDPOINTS CHÍNH

### 6.1. Authentication
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/logout` - Đăng xuất
- `POST /api/auth/refresh-token` - Làm mới token
- `POST /api/auth/forgot-password` - Quên mật khẩu
- `POST /api/auth/reset-password` - Đặt lại mật khẩu

### 6.2. Restaurants
- `GET /api/restaurants` - Danh sách nhà hàng
- `GET /api/restaurants/:id` - Chi tiết nhà hàng
- `GET /api/restaurants/:id/menu` - Menu nhà hàng
- `GET /api/restaurants/search` - Tìm kiếm nhà hàng

### 6.3. Orders
- `POST /api/orders` - Tạo đơn hàng
- `GET /api/orders` - Lịch sử đơn hàng
- `GET /api/orders/:id` - Chi tiết đơn hàng
- `PUT /api/orders/:id/status` - Cập nhật trạng thái
- `POST /api/orders/:id/cancel` - Hủy đơn hàng

### 6.4. Payments
- `POST /api/payments` - Tạo giao dịch thanh toán
- `GET /api/payments/:id` - Chi tiết thanh toán
- `POST /api/payments/verify` - Xác minh thanh toán

### 6.5. Reviews
- `POST /api/reviews` - Tạo đánh giá
- `GET /api/restaurants/:id/reviews` - Đánh giá nhà hàng

### 6.6. Real-time Tracking
- `WebSocket /ws/orders/:id` - Theo dõi đơn hàng real-time
- `GET /api/drivers/:id/location` - Vị trí tài xế

## 7. UI/UX REQUIREMENTS

### 7.1. Design Principles
- **Material Design 3** hoặc **Cupertino Design**
- **Responsive:** Hỗ trợ nhiều kích thước màn hình
- **Dark Mode:** Hỗ trợ chế độ tối
- **Accessibility:** Hỗ trợ người khuyết tật
- **Localization:** Đa ngôn ngữ (Tiếng Việt, English)

### 7.2. Màn hình Chính
- **Splash Screen:** Logo và loading
- **Onboarding:** Giới thiệu app (lần đầu mở)
- **Home:** Danh sách nhà hàng, banner, danh mục
- **Search:** Tìm kiếm và lọc
- **Cart:** Giỏ hàng
- **Orders:** Lịch sử và theo dõi đơn hàng
- **Profile:** Thông tin cá nhân, cài đặt

### 7.3. Performance
- **Loading Time:** < 2 giây cho màn hình chính
- **Image Optimization:** Lazy loading, caching
- **Offline Support:** Cache dữ liệu cơ bản
- **Smooth Animations:** 60 FPS

## 8. BẢO MẬT

### 8.1. Data Security
- **Encryption:** Mã hóa dữ liệu nhạy cảm
- **HTTPS:** Tất cả API calls qua HTTPS
- **Token Storage:** Secure storage cho JWT tokens
- **Input Validation:** Validate tất cả input từ user

### 8.2. Privacy
- **GDPR Compliance:** Tuân thủ quy định bảo vệ dữ liệu
- **Data Minimization:** Chỉ thu thập dữ liệu cần thiết
- **User Consent:** Xin phép trước khi thu thập dữ liệu

## 9. TESTING

### 9.1. Unit Tests
- Test business logic
- Test utility functions

### 9.2. Integration Tests
- Test API integration
- Test database operations

### 9.3. Widget Tests
- Test UI components
- Test user interactions

### 9.4. E2E Tests
- Test user flows hoàn chỉnh
- Test đặt hàng end-to-end

## 10. DEPLOYMENT

### 10.1. Build Configuration
- **Development:** Debug mode với logging
- **Staging:** Test với dữ liệu thật
- **Production:** Release build, tối ưu hóa

### 10.2. App Stores
- **Google Play Store:** Android
- **Apple App Store:** iOS

### 10.3. CI/CD
- **Automated Testing:** Chạy test tự động
- **Automated Build:** Build tự động khi push code
- **Automated Deployment:** Deploy lên stores

## 11. MONITORING & ANALYTICS

### 11.1. Analytics
- User behavior tracking
- Conversion rates
- Popular restaurants/dishes
- Revenue metrics

### 11.2. Error Tracking
- Crash reports
- Error logs
- Performance monitoring

## 12. ROADMAP PHÁT TRIỂN

### Phase 1: MVP (Minimum Viable Product)
- Đăng ký/Đăng nhập
- Xem danh sách nhà hàng
- Đặt hàng cơ bản
- Thanh toán COD
- Theo dõi đơn hàng đơn giản

### Phase 2: Core Features
- Thanh toán online
- Real-time tracking
- Đánh giá và nhận xét
- Quản lý địa chỉ
- Voucher/khuyến mãi

### Phase 3: Advanced Features
- Quản lý nhà hàng (Restaurant Owner)
- Quản lý tài xế (Delivery Driver)
- Thống kê và báo cáo
- Push notifications
- Chat support

### Phase 4: Optimization
- Performance optimization
- Advanced search và recommendation
- Loyalty program
- Social features (chia sẻ, mời bạn)

---

**Tài liệu này sẽ được cập nhật thường xuyên trong quá trình phát triển dự án.**

