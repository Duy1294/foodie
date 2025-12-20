# 🍔 FOODIE BACKEND API

Backend API cho ứng dụng đặt đồ ăn Foodie, được xây dựng với Node.js, Express và MongoDB.

## 📋 Yêu cầu

- Node.js >= 16.0.0
- MongoDB (Local hoặc Atlas)
- npm hoặc yarn

## 🚀 Cài đặt

### 1. Cài đặt dependencies

```bash
npm install
```

### 2. Cấu hình MongoDB

**Option A: MongoDB Atlas (Cloud - Khuyến nghị)**

1. Đăng ký: https://www.mongodb.com/cloud/atlas/register
2. Tạo cluster FREE
3. Tạo database user
4. Whitelist IP: "Allow Access from Anywhere"
5. Lấy connection string

**Option B: MongoDB Local**

1. Tải: https://www.mongodb.com/try/download/community
2. Cài đặt và khởi động
3. MongoDB sẽ chạy tại `mongodb://localhost:27017`

### 3. Cấu hình Environment Variables

Tạo file `.env` từ template:

```bash
copy ENV_TEMPLATE.txt .env
```

Chỉnh sửa `.env`:

```env
PORT=3000
NODE_ENV=development

# MongoDB Atlas
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/foodie?retryWrites=true&w=majority

# Hoặc MongoDB Local
# MONGODB_URI=mongodb://localhost:27017/foodie

# JWT Secret (thay đổi thành key bí mật)
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRE=7d

# CORS
CORS_ORIGIN=http://localhost:8080
```

## 🏃 Chạy

### Development mode (với auto-reload):

```bash
npm run dev
```

### Production mode:

```bash
npm start
```

Server chạy tại: `http://localhost:3000`

## 📡 API Endpoints

Base URL: `http://localhost:3000/api/v1`

### Authentication
- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập
- `GET /auth/me` - Lấy thông tin user hiện tại
- `POST /auth/forgot-password` - Quên mật khẩu

### Restaurants
- `GET /restaurants` - Danh sách nhà hàng
- `GET /restaurants/:id` - Chi tiết nhà hàng
- `GET /restaurants/:id/menu` - Menu nhà hàng
- `POST /restaurants` - Tạo nhà hàng (Owner only)

### Orders
- `GET /orders` - Lịch sử đơn hàng
- `GET /orders/:id` - Chi tiết đơn hàng
- `POST /orders` - Tạo đơn hàng (Customer only)
- `PUT /orders/:id/status` - Cập nhật trạng thái đơn hàng

### Users
- `GET /users/profile` - Lấy profile
- `PUT /users/profile` - Cập nhật profile

## 🔐 Authentication

Hầu hết các endpoints (trừ register/login) yêu cầu authentication.

Gửi token trong header:
```
Authorization: Bearer <your-token>
```

## 📝 Ví dụ sử dụng

### Đăng ký
```bash
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123","fullName":"John Doe"}'
```

### Đăng nhập
```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

### Lấy danh sách nhà hàng
```bash
curl http://localhost:3000/api/v1/restaurants
```

## 🧪 Testing

### Health Check
```bash
curl http://localhost:3000/health
```

Response:
```json
{
  "status": "OK",
  "message": "Foodie API is running",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## 📦 Cấu trúc

```
backend/
├── src/
│   ├── config/
│   │   └── database.js       # Database connection
│   ├── middleware/
│   │   └── auth.js           # Authentication middleware
│   ├── models/
│   │   ├── User.js
│   │   ├── Restaurant.js
│   │   ├── MenuItem.js
│   │   └── Order.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── restaurants.js
│   │   ├── orders.js
│   │   └── users.js
│   ├── utils/
│   │   └── generateToken.js
│   └── server.js             # Main server file
├── .env                      # Environment variables
├── package.json
└── README.md
```

## 🔧 Troubleshooting

### Lỗi kết nối MongoDB
- Kiểm tra MongoDB đã chạy chưa
- Kiểm tra connection string trong `.env`
- Kiểm tra firewall/network

### Lỗi port đã được sử dụng
- Thay đổi PORT trong `.env`
- Hoặc kill process đang dùng port 3000

### Lỗi JWT
- Đảm bảo JWT_SECRET đã được set trong `.env`
- Token hết hạn: đăng nhập lại

## 📚 Tài liệu thêm

- [Express.js Documentation](https://expressjs.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Mongoose Documentation](https://mongoosejs.com/)

---

**Chúc bạn phát triển thành công! 🎉**
