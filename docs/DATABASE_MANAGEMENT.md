# 📊 QUẢN LÝ DATABASE - FOODIE APP

## 🗄️ Database hiện tại

**Database Engine:** MongoDB (NoSQL)  
**ORM/ODM:** Mongoose  
**Hosting:** MongoDB Atlas (Cloud) hoặc MongoDB Local

## 📍 Cấu hình hiện tại

### Connection String
- **Development:** `mongodb://localhost:27017/foodie` (Local)
- **Production:** `mongodb+srv://username:password@cluster.mongodb.net/foodie` (Atlas)

### File cấu hình
- **Backend:** `backend/src/config/database.js`
- **Environment:** `backend/.env` (MONGODB_URI)

## 📋 Các Collections (Tables)

### 1. **users** - Người dùng
- **Fields:** email, password, fullName, phone, role, isVerified, isActive
- **Model:** `backend/src/models/User.js`
- **Relationships:**
  - 1 user → N orders (customer)
  - 1 user → N restaurants (owner)

### 2. **restaurants** - Nhà hàng
- **Fields:** name, address, deliveryFee, minimumOrder, ratingAverage, etc.
- **Model:** `backend/src/models/Restaurant.js`
- **Relationships:**
  - 1 restaurant → N menuItems
  - 1 restaurant → N orders

### 3. **menuitems** - Món ăn
- **Fields:** name, price, description, isAvailable, isPopular
- **Model:** `backend/src/models/MenuItem.js`
- **Relationships:**
  - N menuItems → 1 restaurant

### 4. **orders** - Đơn hàng
- **Fields:** orderNumber, status, totalAmount, paymentMethod, items[]
- **Model:** `backend/src/models/Order.js`
- **Relationships:**
  - 1 order → 1 customer (user)
  - 1 order → 1 restaurant
  - 1 order → N orderItems

## 🛠️ Cách quản lý Database

### 1. **Xem dữ liệu hiện tại**

#### Qua MongoDB Atlas (Web UI):
1. Đăng nhập: https://cloud.mongodb.com
2. Chọn cluster → "Browse Collections"
3. Xem dữ liệu trong các collections

#### Qua MongoDB Compass (Desktop App):
1. Download: https://www.mongodb.com/try/download/compass
2. Kết nối với connection string
3. Browse collections và documents

#### Qua Terminal (MongoDB Shell):
```bash
# Kết nối local
mongosh mongodb://localhost:27017/foodie

# Hoặc kết nối Atlas
mongosh "mongodb+srv://username:password@cluster.mongodb.net/foodie"

# Xem collections
show collections

# Xem documents
db.users.find()
db.restaurants.find()
db.orders.find()
```

### 2. **Tạo dữ liệu mẫu (Seed Data)**

```bash
cd backend
npm run seed
```

Script sẽ tạo:
- 1 user owner (email: `owner@foodie.com`, password: `password123`)
- 2 restaurants với ObjectId thật
- Menu items cho mỗi restaurant

**Lưu ý:** Script sẽ in ra các ObjectId để bạn có thể sử dụng.

### 3. **Xóa dữ liệu**

#### Xóa tất cả:
```javascript
// Trong MongoDB shell hoặc script
db.users.deleteMany({})
db.restaurants.deleteMany({})
db.menuitems.deleteMany({})
db.orders.deleteMany({})
```

#### Xóa theo điều kiện:
```javascript
// Xóa user theo email
db.users.deleteOne({ email: "user@example.com" })

// Xóa restaurant theo tên
db.restaurants.deleteOne({ name: "Nhà hàng ABC" })
```

### 4. **Cập nhật dữ liệu**

#### Qua API:
- PUT `/api/v1/users/profile` - Cập nhật profile
- PUT `/api/v1/orders/:id/status` - Cập nhật trạng thái đơn hàng

#### Qua MongoDB Shell:
```javascript
// Cập nhật user
db.users.updateOne(
  { email: "user@example.com" },
  { $set: { fullName: "Tên mới" } }
)

// Cập nhật restaurant
db.restaurants.updateOne(
  { name: "Nhà hàng ABC" },
  { $set: { deliveryFee: 20000 } }
)
```

### 5. **Backup Database**

#### MongoDB Atlas:
- Tự động backup hàng ngày (FREE tier: 2 backups)
- Vào "Backups" → "Restore" để khôi phục

#### MongoDB Local:
```bash
# Backup
mongodump --uri="mongodb://localhost:27017/foodie" --out=./backup

# Restore
mongorestore --uri="mongodb://localhost:27017/foodie" ./backup/foodie
```

### 6. **Xem thống kê**

```javascript
// Số lượng documents
db.users.countDocuments()
db.restaurants.countDocuments()
db.orders.countDocuments()

// Tổng doanh thu
db.orders.aggregate([
  { $group: { _id: null, total: { $sum: "$totalAmount" } } }
])

// Top restaurants
db.restaurants.find().sort({ ratingAverage: -1 }).limit(5)
```

## 🔍 Các lệnh hữu ích

### Tìm kiếm
```javascript
// Tìm user theo email
db.users.findOne({ email: "user@example.com" })

// Tìm restaurants có rating > 4
db.restaurants.find({ ratingAverage: { $gte: 4 } })

// Tìm orders của user
db.orders.find({ customerId: ObjectId("...") })
```

### Indexes (đã tự động tạo)
- `users.email` - Unique index
- `restaurants.location` - Geospatial index
- `orders.createdAt` - Index cho sorting

## ⚠️ Lưu ý quan trọng

1. **ObjectId vs String:**
   - MongoDB dùng ObjectId (24 ký tự hex)
   - Backend tự động transform `_id` → `id` trong JSON response
   - Flutter app nhận `id` là String

2. **Validation:**
   - Mongoose schemas tự động validate
   - Required fields sẽ báo lỗi nếu thiếu
   - Enum values phải đúng format

3. **Relationships:**
   - Dùng `ref` trong Mongoose để populate
   - ObjectId references giữa collections

4. **Timestamps:**
   - Tự động thêm `createdAt` và `updatedAt`
   - Không cần set thủ công

## 🚀 Quick Start

1. **Kiểm tra kết nối:**
   ```bash
   cd backend
   npm run dev
   # Xem log: ✅ MongoDB Connected: ...
   ```

2. **Tạo data mẫu:**
   ```bash
   npm run seed
   ```

3. **Xem data:**
   - Qua MongoDB Atlas Web UI
   - Hoặc MongoDB Compass
   - Hoặc terminal với mongosh

## 📚 Tài liệu tham khảo

- **Mongoose Docs:** https://mongoosejs.com/docs/
- **MongoDB Atlas:** https://www.mongodb.com/cloud/atlas
- **MongoDB Shell:** https://www.mongodb.com/docs/mongodb-shell/

