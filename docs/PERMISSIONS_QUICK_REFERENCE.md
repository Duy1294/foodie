# BẢNG PHÂN QUYỀN NHANH - FOODIE APP

## 🔐 PHÂN QUYỀN THEO VAI TRÒ

### 👤 KHÁCH HÀNG (Customer)

| Tính năng | Xem | Tạo | Sửa | Xóa | Ghi chú |
|-----------|-----|-----|-----|-----|---------|
| Xem nhà hàng | ✅ | ❌ | ❌ | ❌ | Chỉ xem |
| Xem menu | ✅ | ❌ | ❌ | ❌ | Chỉ xem |
| Giỏ hàng | ✅ | ✅ | ✅ | ✅ | Của chính mình |
| Đặt hàng | ✅ | ✅ | ❌ | ⚠️ | Chỉ hủy khi pending |
| Xem đơn hàng | ✅ | ❌ | ❌ | ❌ | Chỉ đơn của mình |
| Đánh giá | ✅ | ✅ | ⚠️ | ⚠️ | Chỉ 1 lần/đơn, có thể sửa |
| Địa chỉ | ✅ | ✅ | ✅ | ✅ | Của chính mình |
| Profile | ✅ | ❌ | ✅ | ❌ | Chỉnh sửa của mình |
| Voucher | ✅ | ❌ | ❌ | ❌ | Chỉ xem và sử dụng |

---

### 🏪 NHÀ HÀNG (Restaurant Owner)

| Tính năng | Xem | Tạo | Sửa | Xóa | Ghi chú |
|-----------|-----|-----|-----|-----|---------|
| Thông tin nhà hàng | ✅ | ❌ | ✅ | ❌ | Chỉ nhà hàng của mình |
| Menu | ✅ | ✅ | ✅ | ✅ | Chỉ menu của mình |
| Đơn hàng | ✅ | ❌ | ⚠️ | ❌ | Chỉ đơn của nhà hàng mình, cập nhật trạng thái |
| Thống kê | ✅ | ❌ | ❌ | ❌ | Chỉ thống kê của mình |
| Đánh giá | ✅ | ❌ | ⚠️ | ❌ | Xem và phản hồi |
| Voucher | ✅ | ✅ | ✅ | ✅ | Voucher của nhà hàng mình |
| Profile | ✅ | ❌ | ✅ | ❌ | Chỉnh sửa của mình |

**Cập nhật trạng thái đơn hàng:**
- ✅ `pending` → `confirmed`
- ✅ `confirmed` → `preparing`
- ✅ `preparing` → `ready`
- ❌ Không thể hủy đơn (trừ khi có lý do chính đáng)

---

### 🚗 TÀI XẾ (Delivery Driver)

| Tính năng | Xem | Tạo | Sửa | Xóa | Ghi chú |
|-----------|-----|-----|-----|-----|---------|
| Đơn hàng sẵn sàng | ✅ | ❌ | ❌ | ❌ | Xem danh sách |
| Nhận đơn | ✅ | ✅ | ❌ | ❌ | Nhận đơn hàng |
| Đơn đang giao | ✅ | ❌ | ⚠️ | ❌ | Cập nhật trạng thái |
| Vị trí | ✅ | ✅ | ✅ | ❌ | Cập nhật vị trí real-time |
| Thu nhập | ✅ | ❌ | ❌ | ❌ | Xem thống kê |
| Profile | ✅ | ❌ | ✅ | ❌ | Chỉnh sửa của mình |

**Cập nhật trạng thái đơn hàng:**
- ✅ `ready` → `picked_up` (khi nhận đơn)
- ✅ `picked_up` → `on_the_way` (khi bắt đầu giao)
- ✅ `on_the_way` → `delivered` (khi giao xong)
- ❌ Không thể hủy đơn (chỉ admin)

---

### 👨‍💼 QUẢN TRỊ VIÊN (Admin)

| Tính năng | Xem | Tạo | Sửa | Xóa | Ghi chú |
|-----------|-----|-----|-----|-----|---------|
| Tất cả người dùng | ✅ | ✅ | ✅ | ⚠️ | Toàn quyền |
| Tất cả nhà hàng | ✅ | ✅ | ✅ | ⚠️ | Toàn quyền |
| Tất cả đơn hàng | ✅ | ❌ | ✅ | ⚠️ | Có thể hủy |
| Tất cả đánh giá | ✅ | ❌ | ✅ | ✅ | Quản lý nội dung |
| Voucher hệ thống | ✅ | ✅ | ✅ | ✅ | Toàn quyền |
| Thống kê | ✅ | ❌ | ❌ | ❌ | Xem tất cả |
| Cài đặt hệ thống | ✅ | ✅ | ✅ | ✅ | Toàn quyền |
| Khiếu nại | ✅ | ❌ | ✅ | ❌ | Xử lý khiếu nại |

**Quyền đặc biệt:**
- ✅ Duyệt đăng ký nhà hàng mới
- ✅ Khóa/Mở khóa tài khoản
- ✅ Xem thông tin tài chính
- ✅ Can thiệp đơn hàng
- ✅ Xóa nội dung không phù hợp

---

## 📱 PHÂN QUYỀN HỆ THỐNG (SYSTEM PERMISSIONS)

### Android Permissions

| Permission | Mục đích | Bắt buộc | Runtime Request |
|------------|----------|----------|-----------------|
| `INTERNET` | Kết nối API | ✅ | ❌ |
| `ACCESS_NETWORK_STATE` | Kiểm tra mạng | ✅ | ❌ |
| `ACCESS_FINE_LOCATION` | Vị trí chính xác | ✅ | ✅ |
| `ACCESS_COARSE_LOCATION` | Vị trí gần đúng | ✅ | ✅ |
| `ACCESS_BACKGROUND_LOCATION` | Vị trí nền (tài xế) | ⚠️ | ✅ |
| `CAMERA` | Chụp ảnh | ⚠️ | ✅ |
| `READ_EXTERNAL_STORAGE` | Đọc file | ⚠️ | ✅ (Android < 13) |
| `READ_MEDIA_IMAGES` | Đọc ảnh | ⚠️ | ✅ (Android 13+) |
| `POST_NOTIFICATIONS` | Thông báo | ✅ | ✅ (Android 13+) |
| `CALL_PHONE` | Gọi điện (tài xế) | ⚠️ | ✅ |

**Ghi chú:**
- ✅ = Bắt buộc
- ⚠️ = Tùy chọn (theo tính năng)
- Runtime Request = Cần xin phép khi chạy app

### iOS Permissions

| Permission | Mục đích | Bắt buộc | Info.plist Key |
|------------|----------|----------|----------------|
| Location (When In Use) | Vị trí khi dùng app | ✅ | `NSLocationWhenInUseUsageDescription` |
| Location (Always) | Vị trí nền (tài xế) | ⚠️ | `NSLocationAlwaysUsageDescription` |
| Camera | Chụp ảnh | ⚠️ | `NSCameraUsageDescription` |
| Photo Library | Chọn ảnh | ⚠️ | `NSPhotoLibraryUsageDescription` |
| Notifications | Thông báo | ✅ | Tự động khi đăng ký |

---

## 🔒 BẢO MẬT DỮ LIỆU

### Dữ liệu nhạy cảm cần mã hóa:
- ✅ Mật khẩu (hash với bcrypt/argon2)
- ✅ Token JWT (lưu trong secure storage)
- ✅ Thông tin thẻ tín dụng (tokenization)
- ✅ Số điện thoại (có thể mã hóa)
- ✅ Địa chỉ (tùy chọn)

### Dữ liệu không cần mã hóa:
- ❌ Tên nhà hàng
- ❌ Menu công khai
- ❌ Đánh giá công khai
- ❌ Vị trí nhà hàng

---

## 🚫 HẠN CHẾ THEO VAI TRÒ

### Khách hàng KHÔNG thể:
- ❌ Xem thông tin khách hàng khác
- ❌ Xem thông tin tài chính nhà hàng
- ❌ Chỉnh sửa menu
- ❌ Quản lý đơn hàng của người khác
- ❌ Xem thông tin tài xế (ngoài đơn hàng của mình)

### Nhà hàng KHÔNG thể:
- ❌ Xem thông tin khách hàng (ngoài đơn hàng)
- ❌ Xem thông tin tài xế (ngoài đơn hàng)
- ❌ Quản lý nhà hàng khác
- ❌ Hủy đơn hàng (trừ khi có lý do chính đáng)

### Tài xế KHÔNG thể:
- ❌ Xem thông tin khách hàng (ngoài đơn hàng)
- ❌ Xem thông tin nhà hàng (ngoài đơn hàng)
- ❌ Chỉnh sửa đơn hàng
- ❌ Hủy đơn hàng
- ❌ Xem thu nhập của tài xế khác

### Admin CÓ THỂ:
- ✅ Xem tất cả dữ liệu
- ✅ Chỉnh sửa tất cả dữ liệu
- ✅ Xóa dữ liệu (cẩn thận)
- ✅ Khóa/Mở khóa tài khoản
- ✅ Can thiệp đơn hàng

---

## 🔄 QUY TRÌNH XÁC THỰC

### 1. Đăng nhập
```
User → Nhập email/phone + password
     → Server verify
     → Trả về JWT token
     → Lưu token trong secure storage
```

### 2. API Request
```
App → Gửi request với JWT token trong header
    → Server verify token
    → Kiểm tra quyền (role-based)
    → Trả về dữ liệu
```

### 3. Token Refresh
```
App → Token sắp hết hạn
    → Gửi refresh token
    → Server verify refresh token
    → Trả về token mới
```

---

## 📋 CHECKLIST PHÂN QUYỀN

### Khi phát triển tính năng mới:
- [ ] Xác định vai trò nào cần truy cập
- [ ] Xác định quyền (CRUD) cho từng vai trò
- [ ] Implement authorization check ở backend
- [ ] Implement UI permissions ở frontend
- [ ] Test với từng vai trò
- [ ] Document trong code

### Khi review code:
- [ ] Kiểm tra authorization check
- [ ] Kiểm tra không có hardcode role
- [ ] Kiểm tra không expose dữ liệu nhạy cảm
- [ ] Kiểm tra input validation
- [ ] Kiểm tra error handling

---

**Tài liệu này giúp nhanh chóng tra cứu phân quyền khi phát triển.**

