# 🍔 FOODIE - Ứng dụng Đặt Đồ Ăn

Ứng dụng đặt đồ ăn được xây dựng bằng Flutter với backend Node.js/Express, tương tự Shopee Food và TikTok Food.

## 📋 Mục lục

- [Yêu cầu](#yêu-cầu)
- [Cài đặt](#cài-đặt)
- [Chạy ứng dụng](#chạy-ứng-dụng)
- [Cấu trúc dự án](#cấu-trúc-dự-án)
- [Tài liệu](#tài-liệu)
- [Tính năng](#tính-năng)

## 🚀 Yêu cầu

### Flutter App
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Android SDK (cho Android development)
- Xcode (cho iOS development, chỉ trên macOS)

### Backend
- Node.js >= 16.0.0
- MongoDB (Local hoặc Atlas)

## 📦 Cài đặt

### 1. Flutter App

```bash
# Cài đặt dependencies
flutter pub get

# Generate code cho models
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Backend

```bash
cd backend

# Cài đặt dependencies
npm install

# Tạo file .env từ template
copy ENV_TEMPLATE.txt .env

# Chỉnh sửa .env với MongoDB URI của bạn
```

### 3. MongoDB Setup

**Option A: MongoDB Atlas (Cloud - Khuyến nghị)**
1. Đăng ký: https://www.mongodb.com/cloud/atlas/register
2. Tạo cluster FREE
3. Tạo database user
4. Whitelist IP: "Allow Access from Anywhere"
5. Lấy connection string và cập nhật trong `backend/.env`

**Option B: MongoDB Local**
1. Tải: https://www.mongodb.com/try/download/community
2. Cài đặt và khởi động
3. Giữ nguyên `MONGODB_URI=mongodb://localhost:27017/foodie` trong `.env`

## 🏃 Chạy ứng dụng

### Backend

```bash
cd backend
npm run dev
```

Server chạy tại: `http://localhost:3000`

### Flutter App

```bash
# Chạy trên web
flutter run -d edge

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios
```

**Lưu ý:** Nếu chạy trên Android/iOS, cập nhật API URL trong `lib/core/constants/api_constants.dart`:
- Android Emulator: `http://10.0.2.2:3000/api/v1`
- iOS Simulator: `http://localhost:3000/api/v1`
- Physical device: `http://YOUR_COMPUTER_IP:3000/api/v1`

## 📁 Cấu trúc dự án

```
Foodie/
├── lib/                    # Flutter app source code
│   ├── core/              # Core functionality
│   │   ├── constants/     # Constants
│   │   ├── models/        # Data models
│   │   ├── services/      # Services (API, Auth, Storage)
│   │   └── utils/         # Utilities
│   ├── features/          # Feature modules
│   │   ├── auth/          # Authentication
│   │   ├── home/          # Home screen
│   │   ├── restaurants/   # Restaurant features
│   │   ├── cart/          # Shopping cart
│   │   ├── orders/        # Order management
│   │   └── profile/       # User profile
│   └── shared/            # Shared widgets and themes
├── backend/               # Backend API
│   ├── src/
│   │   ├── config/        # Configuration
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── middleware/    # Middleware
│   │   └── utils/         # Utilities
│   └── package.json
├── assets/                # Assets (images, icons)
└── docs/                  # Documentation
    ├── REQUIREMENTS.md
    ├── TECHNICAL_IMPLEMENTATION.md
    ├── DATABASE_SCHEMA.md
    └── PERMISSIONS_QUICK_REFERENCE.md
```

## 📚 Tài liệu

- **[docs/REQUIREMENTS.md](./docs/REQUIREMENTS.md)** - Yêu cầu chi tiết và phân quyền
- **[docs/TECHNICAL_IMPLEMENTATION.md](./docs/TECHNICAL_IMPLEMENTATION.md)** - Hướng dẫn kỹ thuật
- **[docs/DATABASE_SCHEMA.md](./docs/DATABASE_SCHEMA.md)** - Cấu trúc database
- **[docs/PERMISSIONS_QUICK_REFERENCE.md](./docs/PERMISSIONS_QUICK_REFERENCE.md)** - Bảng phân quyền
- **[docs/PROJECT_STRUCTURE.md](./docs/PROJECT_STRUCTURE.md)** - Cấu trúc dự án
- **[docs/MONGODB_ATLAS_SETUP.md](./docs/MONGODB_ATLAS_SETUP.md)** - Hướng dẫn setup MongoDB Atlas
- **[backend/README.md](./backend/README.md)** - Tài liệu backend API

## ✨ Tính năng

### Khách hàng
- ✅ Đăng ký/Đăng nhập
- ✅ Tìm kiếm nhà hàng
- ✅ Xem menu và đặt hàng
- ✅ Theo dõi đơn hàng
- ✅ Quản lý profile

### Nhà hàng (Sắp tới)
- ⏳ Dashboard quản lý
- ⏳ Quản lý menu
- ⏳ Quản lý đơn hàng

### Tài xế (Sắp tới)
- ⏳ Nhận đơn hàng
- ⏳ Theo dõi vị trí
- ⏳ Cập nhật trạng thái giao hàng

## 🏗️ Kiến trúc

- **Frontend:** Flutter với Clean Architecture
- **Backend:** Node.js + Express + MongoDB
- **State Management:** Provider
- **API:** RESTful API

## 🔐 API Endpoints

Base URL: `http://localhost:3000/api/v1`

- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập
- `GET /restaurants` - Danh sách nhà hàng
- `GET /restaurants/:id` - Chi tiết nhà hàng
- `GET /restaurants/:id/menu` - Menu nhà hàng
- `POST /orders` - Tạo đơn hàng
- `GET /orders` - Lịch sử đơn hàng

Xem đầy đủ trong [backend/README.md](./backend/README.md)

## 🧪 Testing

```bash
# Flutter tests
flutter test

# Backend tests (khi có)
cd backend
npm test
```

## 📝 License

MIT License

---

**Dự án đang trong quá trình phát triển. Đóng góp và feedback được chào đón! 🎉**
