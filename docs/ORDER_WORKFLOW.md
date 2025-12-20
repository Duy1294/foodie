# 📋 QUY TRÌNH ĐẶT HÀNG VÀ GIAO HÀNG

## 🔄 Quy trình tổng quan

```
1. Customer đặt đơn → pending
2. Restaurant xác nhận → confirmed
3. Shipper nhận đơn → driverId được gán, status: confirmed
4. Restaurant bắt đầu chuẩn bị → preparing
5. Restaurant sẵn sàng → ready
6. Shipper lấy hàng → picked_up
7. Shipper đang giao → on_the_way
8. Shipper giao xong → delivered
```

---

## 👤 CUSTOMER (Khách hàng)

### Màn hình: `OrderListScreen` → `OrderDetailScreen`

#### Bước 1: Đặt đơn hàng
- **Màn hình**: `CheckoutScreen`
- **Hành động**: 
  - Chọn địa chỉ giao hàng
  - Chọn phương thức thanh toán
  - Nhập ghi chú (nếu có)
  - **Bấm nút "Đặt hàng"**
- **Kết quả**: Đơn hàng được tạo với status `pending`

#### Bước 2: Xem trạng thái đơn hàng
- **Màn hình**: `OrderListScreen` → `OrderDetailScreen`
- **Hành động**: 
  - Xem danh sách đơn hàng
  - Bấm vào đơn hàng để xem chi tiết
- **Thông tin hiển thị**:
  - Số đơn hàng
  - Trạng thái hiện tại
  - Danh sách món ăn
  - Tổng tiền
  - Địa chỉ giao hàng
  - Thông tin shipper (khi đã có)

#### Bước 3: Hủy đơn (nếu cần)
- **Điều kiện**: Chỉ có thể hủy khi status = `pending`
- **Hành động**: Bấm nút "Hủy đơn" (nếu có trong UI)
- **Lưu ý**: Hiện tại chưa có nút hủy đơn trong UI, cần thêm

---

## 🏪 RESTAURANT OWNER (Chủ nhà hàng)

### Màn hình: `RestaurantOrdersScreen` → `OrderDetailScreen`

#### Bước 1: Xác nhận đơn hàng
- **Màn hình**: `RestaurantOrdersScreen`
- **Điều kiện**: Đơn hàng ở status `pending`
- **Hành động**: 
  - Xem danh sách đơn hàng
  - Tìm đơn hàng ở trạng thái "Chờ xác nhận"
  - **Bấm nút "Xác nhận đơn hàng"** (màu xanh)
- **Kết quả**: Status chuyển thành `confirmed`

#### Bước 2: Chờ shipper nhận đơn
- **Màn hình**: `RestaurantOrdersScreen`
- **Điều kiện**: Đơn hàng ở status `confirmed` và chưa có driver
- **Hiển thị**: 
  - Thông báo màu cam: **"Đang chờ shipper nhận đơn"**
  - Không có nút "Bắt đầu chuẩn bị" (chưa được phép)

#### Bước 3: Bắt đầu chuẩn bị
- **Màn hình**: `RestaurantOrdersScreen`
- **Điều kiện**: 
  - Đơn hàng ở status `confirmed`
  - **Đã có shipper nhận đơn** (driverId != null)
- **Hành động**: 
  - **Bấm nút "Bắt đầu chuẩn bị"** (màu tím)
- **Kết quả**: Status chuyển thành `preparing`

#### Bước 4: Sẵn sàng giao hàng
- **Màn hình**: `RestaurantOrdersScreen`
- **Điều kiện**: 
  - Đơn hàng ở status `preparing`
  - Đã có shipper
- **Hành động**: 
  - **Bấm nút "Sẵn sàng giao hàng"** (màu teal)
- **Kết quả**: Status chuyển thành `ready`

#### Bước 5: Theo dõi đơn hàng
- **Màn hình**: `RestaurantOrdersScreen` → `OrderDetailScreen`
- **Hành động**: 
  - Xem danh sách đơn hàng theo trạng thái (dropdown filter)
  - Bấm vào đơn hàng để xem chi tiết
- **Thông tin hiển thị**:
  - Trạng thái hiện tại
  - Thông tin khách hàng
  - Danh sách món ăn
  - Thông tin shipper (khi đã có)

---

## 🚚 SHIPPER (Người giao hàng)

### Màn hình: `ShipperOrdersScreen` → `OrderDetailScreen`

#### Bước 1: Xem đơn hàng mới
- **Màn hình**: `ShipperOrdersScreen` (tab "Đơn hàng mới")
- **Điều kiện**: 
  - Đơn hàng ở status `confirmed`
  - Chưa có driver (driverId = null)
- **Hành động**: 
  - Xem danh sách đơn hàng available
  - Bấm vào đơn hàng để xem chi tiết

#### Bước 2: Nhận đơn hàng
- **Màn hình**: `ShipperOrdersScreen` (tab "Đơn hàng mới")
- **Điều kiện**: 
  - Đơn hàng ở status `confirmed`
  - Chưa có driver
- **Hành động**: 
  - **Bấm nút "Nhận đơn"** (màu xanh primary)
  - Xác nhận trong dialog
- **Kết quả**: 
  - driverId được gán cho shipper
  - Status giữ nguyên `confirmed`
  - Đơn hàng xuất hiện trong tab "Đơn đang giao"

#### Bước 3: Chờ nhà hàng chuẩn bị
- **Màn hình**: `ShipperOrdersScreen` (tab "Đơn đang giao")
- **Điều kiện**: 
  - Đơn hàng đã được shipper nhận
  - Status: `confirmed` hoặc `preparing` hoặc `ready`
- **Hành động**: 
  - Theo dõi trạng thái đơn hàng
  - Chờ nhà hàng chuyển sang `ready`

#### Bước 4: Lấy hàng và bắt đầu giao (khi đơn ready)
- **Màn hình**: `ShipperOrdersScreen` (tab "Đơn đang giao")
- **Điều kiện**: 
  - Đơn hàng ở status `ready`
  - Đã có driver (là shipper này)
- **Hành động**: 
  - Đến nhà hàng lấy hàng
  - **Bấm nút "Đã lấy hàng"** (màu teal)
- **Kết quả**: Status chuyển trực tiếp thành `on_the_way` (bắt đầu giao ngay)

#### Bước 5: Đang giao hàng
- **Màn hình**: `ShipperOrdersScreen` (tab "Đơn đang giao")
- **Điều kiện**: 
  - Đơn hàng ở status `on_the_way`
  - Đã có driver (là shipper này)
- **Hành động**: 
  - Giao hàng đến khách
  - **Bấm nút "Hoàn thành"** (màu xanh lá) khi đã giao xong
- **Kết quả**: 
  - Status chuyển thành `delivered`
  - deliveredAt được set
  - Đơn hàng chuyển sang tab "Lịch sử giao hàng"

#### Bước 6: Xem lịch sử
- **Màn hình**: `ShipperOrdersScreen` (tab "Lịch sử giao hàng")
- **Hành động**: 
  - Xem danh sách đơn hàng đã giao (status = `delivered`)
  - Bấm vào đơn hàng để xem chi tiết

---

## 📊 Bảng tóm tắt nút bấm theo role

| Role | Trạng thái đơn | Nút bấm | Kết quả |
|------|----------------|---------|---------|
| **Customer** | `pending` | Đặt hàng | Tạo đơn mới |
| **Customer** | `pending` | Hủy đơn | Status → `cancelled` (cần thêm UI) |
| **Restaurant** | `pending` | Xác nhận đơn hàng | Status → `confirmed` |
| **Restaurant** | `confirmed` (chưa có driver) | - | Hiển thị "Đang chờ shipper nhận đơn" |
| **Restaurant** | `confirmed` (đã có driver) | Bắt đầu chuẩn bị | Status → `preparing` |
| **Restaurant** | `preparing` (đã có driver) | Sẵn sàng giao hàng | Status → `ready` |
| **Shipper** | `confirmed` (chưa có driver) | Nhận đơn | driverId được gán, status giữ `confirmed` |
| **Shipper** | `ready` (đã nhận đơn) | Đã lấy hàng | Status → `on_the_way` (bắt đầu giao ngay) |
| **Shipper** | `on_the_way` (đã nhận đơn) | Hoàn thành | Status → `delivered` |

---

## ⚠️ Lưu ý quan trọng

1. **Restaurant KHÔNG thể bắt đầu chuẩn bị nếu chưa có shipper nhận đơn**
   - Nút "Bắt đầu chuẩn bị" chỉ hiển thị khi `driverId != null`
   - Hiển thị thông báo "Đang chờ shipper nhận đơn" khi chưa có driver

2. **Shipper chỉ có thể nhận đơn ở status `confirmed`**
   - Không thể nhận đơn ở status `preparing` hoặc `ready`
   - Sau khi nhận, status giữ nguyên `confirmed`

3. **Quy trình bắt buộc**:
   - Customer đặt → Restaurant xác nhận → Shipper nhận → Restaurant chuẩn bị → Restaurant sẵn sàng → Shipper lấy → Shipper giao → Shipper hoàn thành

4. **Validation**:
   - Backend kiểm tra `driverId` trước khi cho phép chuyển sang `preparing` hoặc `ready`
   - Backend kiểm tra status transitions hợp lệ

---

## 🔧 Cần bổ sung

1. **Customer**: Thêm nút "Hủy đơn" trong `OrderDetailScreen` khi status = `pending`
2. **Customer**: Thêm real-time tracking đơn hàng (nếu cần)
3. **Restaurant**: Thêm thông báo khi shipper nhận đơn
4. **Shipper**: Thêm thông báo khi restaurant chuyển sang `ready`

