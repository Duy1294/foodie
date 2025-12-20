# CẤU TRÚC DATABASE - FOODIE APP

## 📊 SƠ ĐỒ QUAN HỆ (ERD)

```
Users (1) ────< (N) Orders
Users (1) ────< (N) Addresses
Users (1) ────< (N) Reviews
Users (1) ────< (N) Payments

Restaurants (1) ────< (N) MenuItems
Restaurants (1) ────< (N) Orders
Restaurants (1) ────< (N) Reviews
Restaurants (1) ────< (N) Vouchers

Orders (1) ────< (N) OrderItems
Orders (1) ────< (1) Payments
Orders (1) ────< (1) DeliveryDrivers

MenuItems (N) ────< (N) OrderItems (Many-to-Many)
Categories (1) ────< (N) MenuItems
```

## 📋 CÁC BẢNG CHI TIẾT

### 1. Users (Người dùng)
```sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    role ENUM('customer', 'restaurant_owner', 'driver', 'admin') NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role)
);
```

**Các trường:**
- `id`: UUID
- `email`: Email đăng nhập
- `phone`: Số điện thoại
- `password_hash`: Mật khẩu đã hash
- `full_name`: Tên đầy đủ
- `avatar_url`: URL ảnh đại diện
- `role`: Vai trò (customer, restaurant_owner, driver, admin)
- `is_verified`: Đã xác thực email/phone chưa
- `is_active`: Tài khoản có đang hoạt động không

### 2. Restaurants (Nhà hàng)
```sql
CREATE TABLE restaurants (
    id VARCHAR(36) PRIMARY KEY,
    owner_id VARCHAR(36) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone VARCHAR(20),
    email VARCHAR(255),
    logo_url VARCHAR(500),
    cover_image_url VARCHAR(500),
    opening_hours JSON, -- {"monday": {"open": "09:00", "close": "22:00"}, ...}
    delivery_fee DECIMAL(10, 2) DEFAULT 0,
    minimum_order DECIMAL(10, 2) DEFAULT 0,
    rating_average DECIMAL(3, 2) DEFAULT 0,
    rating_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id),
    INDEX idx_owner (owner_id),
    INDEX idx_location (latitude, longitude),
    INDEX idx_active (is_active)
);
```

**Các trường:**
- `id`: UUID
- `owner_id`: ID chủ nhà hàng
- `name`: Tên nhà hàng
- `address`: Địa chỉ
- `latitude`, `longitude`: Tọa độ GPS
- `opening_hours`: Giờ mở cửa (JSON)
- `delivery_fee`: Phí giao hàng
- `minimum_order`: Đơn hàng tối thiểu
- `rating_average`: Đánh giá trung bình
- `rating_count`: Số lượng đánh giá

### 3. Categories (Danh mục)
```sql
CREATE TABLE categories (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    icon_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4. MenuItems (Món ăn)
```sql
CREATE TABLE menu_items (
    id VARCHAR(36) PRIMARY KEY,
    restaurant_id VARCHAR(36) NOT NULL,
    category_id VARCHAR(36),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    image_url VARCHAR(500),
    is_available BOOLEAN DEFAULT TRUE,
    is_popular BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_category (category_id),
    INDEX idx_available (is_available)
);
```

### 5. Orders (Đơn hàng)
```sql
CREATE TABLE orders (
    id VARCHAR(36) PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    driver_id VARCHAR(36),
    address_id VARCHAR(36) NOT NULL,
    status ENUM('pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    delivery_fee DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'card', 'wallet', 'momo', 'zalopay') NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    customer_note TEXT,
    estimated_delivery_time TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (driver_id) REFERENCES users(id),
    FOREIGN KEY (address_id) REFERENCES addresses(id),
    INDEX idx_customer (customer_id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_driver (driver_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
);
```

**Trạng thái đơn hàng:**
- `pending`: Đã đặt, chờ xác nhận
- `confirmed`: Nhà hàng đã xác nhận
- `preparing`: Đang chuẩn bị
- `ready`: Sẵn sàng giao
- `picked_up`: Tài xế đã lấy hàng
- `on_the_way`: Đang giao
- `delivered`: Đã giao
- `cancelled`: Đã hủy

### 6. OrderItems (Chi tiết đơn hàng)
```sql
CREATE TABLE order_items (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    menu_item_id VARCHAR(36) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (menu_item_id) REFERENCES menu_items(id),
    INDEX idx_order (order_id)
);
```

### 7. Addresses (Địa chỉ)
```sql
CREATE TABLE addresses (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    label VARCHAR(50) NOT NULL, -- "Nhà", "Công ty", etc.
    full_address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    contact_name VARCHAR(255),
    contact_phone VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
);
```

### 8. Payments (Thanh toán)
```sql
CREATE TABLE payments (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'card', 'wallet', 'momo', 'zalopay') NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(255),
    payment_gateway_response JSON,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_order (order_id),
    INDEX idx_user (user_id),
    INDEX idx_status (payment_status)
);
```

### 9. Reviews (Đánh giá)
```sql
CREATE TABLE reviews (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    restaurant_id VARCHAR(36) NOT NULL,
    driver_id VARCHAR(36),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    restaurant_rating INT CHECK (restaurant_rating >= 1 AND restaurant_rating <= 5),
    driver_rating INT CHECK (driver_rating >= 1 AND driver_rating <= 5),
    food_rating INT CHECK (food_rating >= 1 AND food_rating <= 5),
    images JSON, -- Array of image URLs
    restaurant_reply TEXT,
    restaurant_replied_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    FOREIGN KEY (driver_id) REFERENCES users(id),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_user (user_id),
    INDEX idx_order (order_id),
    UNIQUE KEY unique_order_review (order_id)
);
```

### 10. Vouchers (Mã giảm giá)
```sql
CREATE TABLE vouchers (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    restaurant_id VARCHAR(36), -- NULL = voucher hệ thống
    title VARCHAR(255) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed', 'free_delivery') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    minimum_order_amount DECIMAL(10, 2) DEFAULT 0,
    maximum_discount_amount DECIMAL(10, 2),
    usage_limit INT, -- NULL = không giới hạn
    used_count INT DEFAULT 0,
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    INDEX idx_code (code),
    INDEX idx_restaurant (restaurant_id),
    INDEX idx_valid (valid_from, valid_until)
);
```

### 11. UserVouchers (Voucher của người dùng)
```sql
CREATE TABLE user_vouchers (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    voucher_id VARCHAR(36) NOT NULL,
    order_id VARCHAR(36),
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_user (user_id),
    INDEX idx_voucher (voucher_id)
);
```

### 12. Notifications (Thông báo)
```sql
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type VARCHAR(50) NOT NULL, -- 'order_update', 'promotion', 'system'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSON, -- Additional data
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_created (created_at)
);
```

### 13. DriverLocations (Vị trí tài xế - Real-time)
```sql
CREATE TABLE driver_locations (
    id VARCHAR(36) PRIMARY KEY,
    driver_id VARCHAR(36) NOT NULL,
    order_id VARCHAR(36),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    heading DECIMAL(5, 2), -- Hướng di chuyển (0-360)
    speed DECIMAL(5, 2), -- Tốc độ (km/h)
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (driver_id) REFERENCES users(id),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_driver (driver_id),
    INDEX idx_order (order_id),
    INDEX idx_timestamp (timestamp)
);
```

**Lưu ý:** Bảng này có thể sử dụng Redis hoặc in-memory database cho real-time tracking.

### 14. OrderStatusHistory (Lịch sử trạng thái đơn hàng)
```sql
CREATE TABLE order_status_history (
    id VARCHAR(36) PRIMARY KEY,
    order_id VARCHAR(36) NOT NULL,
    status VARCHAR(50) NOT NULL,
    changed_by VARCHAR(36), -- User ID
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_created (created_at)
);
```

## 🔍 INDEXES QUAN TRỌNG

### Performance Indexes
```sql
-- Tìm nhà hàng gần nhất
CREATE INDEX idx_restaurant_location ON restaurants(latitude, longitude);

-- Lọc đơn hàng theo trạng thái
CREATE INDEX idx_order_status_date ON orders(status, created_at);

-- Tìm kiếm món ăn
CREATE FULLTEXT INDEX idx_menu_search ON menu_items(name, description);

-- Lọc đánh giá
CREATE INDEX idx_review_restaurant_rating ON reviews(restaurant_id, rating);
```

## 📊 VIEWS HỮU ÍCH

### 1. Restaurant Statistics View
```sql
CREATE VIEW restaurant_stats AS
SELECT 
    r.id,
    r.name,
    COUNT(DISTINCT o.id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    AVG(rev.rating) as avg_rating,
    COUNT(DISTINCT rev.id) as review_count
FROM restaurants r
LEFT JOIN orders o ON r.id = o.restaurant_id
LEFT JOIN reviews rev ON r.id = rev.restaurant_id
GROUP BY r.id;
```

### 2. User Order Summary View
```sql
CREATE VIEW user_order_summary AS
SELECT 
    u.id as user_id,
    COUNT(o.id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(rev.rating) as avg_rating_given
FROM users u
LEFT JOIN orders o ON u.id = o.customer_id
LEFT JOIN reviews rev ON u.id = rev.user_id
WHERE u.role = 'customer'
GROUP BY u.id;
```

## 🔄 MIGRATIONS

Sử dụng migration tool như:
- **Node.js:** Knex.js, TypeORM
- **Python:** Alembic, Django Migrations
- **PHP:** Laravel Migrations
- **Java:** Flyway, Liquibase

## 💾 BACKUP & RECOVERY

- **Daily backups:** Full database backup
- **Transaction logs:** Real-time replication
- **Point-in-time recovery:** Restore to specific timestamp

---

**Lưu ý:** Đây là schema cơ bản. Có thể cần điều chỉnh tùy theo yêu cầu cụ thể và database engine (PostgreSQL, MySQL, MongoDB, etc.)

