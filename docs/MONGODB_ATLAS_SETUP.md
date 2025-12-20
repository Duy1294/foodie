# 🍃 HƯỚNG DẪN SETUP MONGODB ATLAS

## 📋 Tổng quan

MongoDB Atlas là dịch vụ MongoDB được quản lý trên cloud, miễn phí với 512MB storage.

**Thời gian:** ~10-15 phút  
**Chi phí:** Miễn phí (FREE tier)

---

## 🚀 CÁC BƯỚC SETUP

### BƯỚC 1: Đăng ký tài khoản
1. Truy cập: https://www.mongodb.com/cloud/atlas/register
2. Điền thông tin và xác nhận email

### BƯỚC 2: Tạo Cluster
1. Click "Build a Database"
2. Chọn **FREE (M0)** tier
3. Chọn Provider: **AWS**
4. Chọn Region: **Singapore (ap-southeast-1)** hoặc gần bạn
5. Đặt tên cluster (ví dụ: `foodie-cluster`)
6. Click "Create" (đợi 3-5 phút)

### BƯỚC 3: Tạo Database User
1. Vào "Database Access" → "Add New Database User"
2. Username: `foodieuser` (hoặc tên bạn muốn)
3. Password: Click "Autogenerate Secure Password" hoặc tự tạo
4. **⚠️ LƯU LẠI PASSWORD NGAY!**
5. Database User Privileges: "Atlas admin"
6. Click "Add User"

### BƯỚC 4: Whitelist IP Address
1. Vào "Network Access" → "Add IP Address"
2. Click **"Allow Access from Anywhere"** (cho development)
3. Click "Confirm"

### BƯỚC 5: Lấy Connection String
1. Vào "Database" → Click "Connect" trên cluster
2. Chọn **"Connect your application"**
3. Driver: **Node.js**, Version: **5.5 or later**
4. Copy connection string

### BƯỚC 6: Chỉnh sửa Connection String

Connection string mẫu:
```
mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
```

**Cần chỉnh sửa:**
1. Thay `<username>` bằng username bạn đã tạo
2. Thay `<password>` bằng password bạn đã tạo
3. **Thêm `/foodie` trước `?`** để chỉ định database name

**Ví dụ sau khi chỉnh:**
```
mongodb+srv://foodieuser:MyPassword123@cluster0.abc123.mongodb.net/foodie?retryWrites=true&w=majority
```

### BƯỚC 7: Cập nhật file .env

Mở `backend/.env` và cập nhật:
```env
MONGODB_URI=mongodb+srv://foodieuser:MyPassword123@cluster0.abc123.mongodb.net/foodie?retryWrites=true&w=majority
```

---

## ✅ Test kết nối

```bash
cd backend
npm run dev
```

Bạn sẽ thấy:
```
✅ MongoDB Connected: cluster0-shard-00-00.xxxxx.mongodb.net:27017
🚀 Server running on port 3000
```

---

## 🔧 Troubleshooting

### Lỗi: "Authentication failed"
- Kiểm tra username và password trong connection string
- Đảm bảo đã thay `<username>` và `<password>`

### Lỗi: "IP not whitelisted"
- Vào Network Access → Thêm IP hoặc "Allow Access from Anywhere"

### Lỗi: "Connection timeout"
- Kiểm tra cluster đã "Running" chưa
- Kiểm tra internet connection

---

**Xem chi tiết hơn trong README.md**

