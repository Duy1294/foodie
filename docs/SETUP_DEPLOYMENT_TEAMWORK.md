# 🚀 SETUP CHO BUILD APK, DEPLOY VÀ TEAMWORK

**Ngày tạo:** 2025-01-XX

---

## 📋 TỔNG QUAN

Tài liệu này hướng dẫn setup **MongoDB** và **Firebase** cho:
1. ✅ Build APK
2. ✅ Deploy ra ngoài (production)
3. ✅ Teamwork (nhiều người làm việc cùng)

---

## 🔵 MONGODB SETUP

### 1. 📱 **Build APK**

#### ✅ **KHÔNG CẦN SETUP GÌ THÊM**

**Lý do:**
- MongoDB chạy ở **backend server** (không phải trong app)
- Flutter app chỉ cần **API endpoint** để kết nối
- APK build không cần MongoDB config

**Cần làm:**
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // Chỉ cần đổi baseUrl khi deploy
  static const String baseUrl = 'https://your-api.com/api/v1';
  // Hoặc localhost cho development
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api/v1'; // iOS simulator
}
```

**Kết luận:** ✅ **Rất dễ** - Chỉ cần đổi API URL

---

### 2. 🌐 **Deploy Ra Ngoài (Production)**

#### **Option A: MongoDB Atlas (Cloud - Khuyến nghị)**

**Bước 1: Tạo MongoDB Atlas Account**
1. Truy cập: https://www.mongodb.com/cloud/atlas/register
2. Đăng ký tài khoản (FREE tier có sẵn)
3. Tạo organization và project

**Bước 2: Tạo Cluster**
1. Click **"Build a Database"**
2. Chọn **FREE tier** (M0 - Shared)
3. Chọn **Cloud Provider & Region:**
   - AWS, Google Cloud, hoặc Azure
   - Region: `Asia Pacific (ap-southeast-1)` (Singapore - gần Việt Nam)
4. Click **"Create"** (mất 3-5 phút)

**Bước 3: Setup Database User**
1. Vào **"Database Access"**
2. Click **"Add New Database User"**
3. Chọn **"Password"** authentication
4. Username: `foodie_admin` (hoặc tên bạn muốn)
5. Password: Tạo password mạnh (lưu lại!)
6. Database User Privileges: **"Atlas admin"** (hoặc custom)
7. Click **"Add User"**

**Bước 4: Whitelist IP Address**
1. Vào **"Network Access"**
2. Click **"Add IP Address"**
3. Chọn **"Allow Access from Anywhere"** (0.0.0.0/0) - cho development
   - ⚠️ **Production:** Nên whitelist IP cụ thể của server
4. Click **"Confirm"**

**Bước 5: Lấy Connection String**
1. Vào **"Database"** → Click **"Connect"**
2. Chọn **"Connect your application"**
3. Driver: **Node.js**, Version: **5.5 or later**
4. Copy connection string:
   ```
   mongodb+srv://foodie_admin:<password>@cluster0.xxxxx.mongodb.net/foodie?retryWrites=true&w=majority
   ```
5. Thay `<password>` bằng password đã tạo

**Bước 6: Cấu hình Backend**
```bash
# backend/.env
MONGODB_URI=mongodb+srv://foodie_admin:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/foodie?retryWrites=true&w=majority
```

**Bước 7: Deploy Backend**
- Deploy backend lên server (Heroku, AWS, DigitalOcean, etc.)
- Set environment variable `MONGODB_URI` trên server
- Backend sẽ tự động kết nối MongoDB Atlas

**Kết luận:** ✅ **Dễ dàng** - 10-15 phút setup, không cần server riêng

---

#### **Option B: MongoDB Self-hosted (VPS/Server)**

**Bước 1: Setup MongoDB trên Server**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y mongodb

# Hoặc dùng Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

**Bước 2: Cấu hình MongoDB**
```bash
# Tạo database user
mongo
use foodie
db.createUser({
  user: "foodie_admin",
  pwd: "your_password",
  roles: ["readWrite"]
})
```

**Bước 3: Cấu hình Backend**
```bash
# backend/.env
MONGODB_URI=mongodb://foodie_admin:your_password@your-server-ip:27017/foodie
```

**Bước 4: Firewall**
```bash
# Mở port 27017 (chỉ cho backend server)
sudo ufw allow from YOUR_BACKEND_IP to any port 27017
```

**Kết luận:** ⚠️ **Phức tạp hơn** - Cần quản lý server, backup, security

---

### 3. 👥 **Teamwork (Nhiều người làm việc cùng)**

#### ✅ **Rất dễ với MongoDB Atlas**

**Cách 1: Dùng chung MongoDB Atlas (Khuyến nghị)**

**Setup:**
1. **1 người tạo MongoDB Atlas project** (như trên)
2. **Share connection string** với team:
   - Tạo file `backend/.env.example`:
     ```env
     MONGODB_URI=mongodb+srv://foodie_admin:<password>@cluster0.xxxxx.mongodb.net/foodie?retryWrites=true&w=majority
     ```
   - Mỗi người copy `.env.example` → `.env`
   - Điền password (share qua secure channel)

**Lợi ích:**
- ✅ Tất cả dùng chung database
- ✅ Dễ test với data thật
- ✅ Không cần setup riêng

**Lưu ý:**
- ⚠️ Cẩn thận khi xóa data (ảnh hưởng tất cả)
- ✅ Có thể tạo nhiều databases (dev, staging, prod)

---

**Cách 2: Mỗi người dùng MongoDB Atlas riêng**

**Setup:**
1. Mỗi người tạo MongoDB Atlas account riêng
2. Mỗi người tạo cluster riêng
3. Mỗi người có `.env` riêng với connection string riêng

**Lợi ích:**
- ✅ Không ảnh hưởng nhau
- ✅ Test độc lập

**Nhược điểm:**
- ⚠️ Cần nhiều tài khoản
- ⚠️ Không share data được

---

**Cách 3: MongoDB Local (Mỗi người)**

**Setup:**
```bash
# Mỗi người cài MongoDB local
# macOS
brew install mongodb-community

# Windows
# Download từ: https://www.mongodb.com/try/download/community

# Linux
sudo apt install mongodb
```

**Cấu hình:**
```bash
# backend/.env
MONGODB_URI=mongodb://localhost:27017/foodie
```

**Lợi ích:**
- ✅ Hoàn toàn độc lập
- ✅ Không tốn phí

**Nhược điểm:**
- ⚠️ Mỗi người phải setup
- ⚠️ Không share data được

---

### 📊 **Tổng kết MongoDB**

| Tình huống | Độ khó | Thời gian | Ghi chú |
|------------|--------|-----------|---------|
| **Build APK** | ✅ Rất dễ | 0 phút | Chỉ cần đổi API URL |
| **Deploy (Atlas)** | ✅ Dễ | 10-15 phút | Free tier có sẵn |
| **Deploy (Self-hosted)** | ⚠️ Phức tạp | 1-2 giờ | Cần quản lý server |
| **Teamwork (Chung Atlas)** | ✅ Rất dễ | 5 phút | Share connection string |
| **Teamwork (Riêng)** | ✅ Dễ | 10 phút | Mỗi người setup riêng |

---

## 🔥 FIREBASE SETUP

### 1. 📱 **Build APK**

#### ⚠️ **CẦN SETUP TRƯỚC**

**Bước 1: Tạo Firebase Project**
1. Truy cập: https://console.firebase.google.com/
2. Click **"Add project"** hoặc **"Create a project"**
3. Nhập tên project: `Foodie` (hoặc tên bạn muốn)
4. Chọn Google Analytics (tùy chọn)
5. Click **"Create project"**

**Bước 2: Thêm Android App**
1. Trong Firebase Console, click **"Add app"** → Chọn **Android**
2. Nhập thông tin:
   - **Android package name:** `com.example.foodie` (phải khớp với `applicationId` trong `build.gradle.kts`)
   - **App nickname:** `Foodie Android` (tùy chọn)
3. Click **"Register app"**

**Bước 3: Download `google-services.json`**
1. Download file `google-services.json`
2. **Copy file vào:** `android/app/google-services.json`
   ```
   android/
     app/
       google-services.json  ← File này
       build.gradle.kts
   ```

**Bước 4: Kiểm tra Gradle Config**
```kotlin
// android/app/build.gradle.kts
plugins {
    id("com.google.gms.google-services") // Đã có
}

// android/settings.gradle.kts
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false // Đã có
}
```

**Bước 5: Generate Firebase Options (Flutter)**
```bash
# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart
flutterfire configure
```

**Bước 6: Update Code**
```dart
// lib/main.dart
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

**Kết luận:** ⚠️ **Cần setup** - 15-20 phút, nhưng chỉ làm 1 lần

---

### 2. 🌐 **Deploy Ra Ngoài (Production)**

#### **Cần làm thêm:**

**Bước 1: Tạo Production App (Nếu chưa có)**
1. Trong Firebase Console, có thể tạo thêm Android app với package name khác
2. Hoặc dùng chung app, nhưng cấu hình khác nhau

**Bước 2: Setup Firebase Services**
1. **Firestore:**
   - Vào **Firestore Database**
   - Click **"Create database"**
   - Chọn **"Start in production mode"** (không phải test mode)
   - Setup Security Rules:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /orders/{orderId} {
           allow read: if request.auth != null 
             && (resource.data.customerId == request.auth.uid 
                 || resource.data.restaurantId == request.auth.uid);
           allow write: if false; // Chỉ backend được write
         }
       }
     }
     ```

2. **FCM (Cloud Messaging):**
   - Đã tự động enable khi thêm Android app
   - Không cần setup thêm

3. **Authentication:**
   - Vào **Authentication** → **Sign-in method**
   - Enable **Email/Password**
   - Enable **Google** (nếu cần)

**Bước 3: Update Security Rules**
- ⚠️ **Quan trọng:** Update Firestore Security Rules cho production
- ⚠️ **Quan trọng:** Không dùng test mode rules

**Kết luận:** ⚠️ **Cần setup** - 20-30 phút, cần cẩn thận với security rules

---

### 3. 👥 **Teamwork (Nhiều người làm việc cùng)**

#### ⚠️ **PHỨC TẠP HƠN MONGODB**

**Vấn đề:**
- `google-services.json` chứa **project-specific config**
- File này **không nên commit** vào Git (có thể chứa sensitive info)
- Mỗi người cần file riêng hoặc share chung

---

**Cách 1: Dùng chung Firebase Project (Khuyến nghị cho team nhỏ)**

**Setup:**
1. **1 người tạo Firebase project**
2. **Share `google-services.json`** với team:
   - Tạo file `android/app/google-services.json.example`
   - Mỗi người copy `google-services.json.example` → `google-services.json`
   - Hoặc share qua secure channel (Slack, email)

**Lợi ích:**
- ✅ Tất cả dùng chung Firebase project
- ✅ Dễ test với data thật
- ✅ Không cần setup riêng

**Nhược điểm:**
- ⚠️ Cẩn thận khi xóa data (ảnh hưởng tất cả)
- ⚠️ Có thể conflict khi test cùng lúc

**Git setup:**
```gitignore
# .gitignore
android/app/google-services.json  # Không commit file thật
android/app/google-services.json.example  # Commit file example
```

---

**Cách 2: Mỗi người dùng Firebase Project riêng**

**Setup:**
1. Mỗi người tạo Firebase project riêng
2. Mỗi người download `google-services.json` riêng
3. Mỗi người có file riêng (không commit)

**Lợi ích:**
- ✅ Hoàn toàn độc lập
- ✅ Không ảnh hưởng nhau

**Nhược điểm:**
- ⚠️ Cần nhiều Firebase projects
- ⚠️ Không share data được
- ⚠️ Mỗi người phải setup riêng

---

**Cách 3: Dùng Firebase Emulator (Development)**

**Setup:**
```bash
# Cài đặt Firebase Emulator
npm install -g firebase-tools
firebase init emulators

# Chạy emulator
firebase emulators:start
```

**Cấu hình:**
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dùng emulator cho development
  if (kDebugMode) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  
  runApp(const MyApp());
}
```

**Lợi ích:**
- ✅ Hoàn toàn local
- ✅ Không tốn phí
- ✅ Không ảnh hưởng production

**Nhược điểm:**
- ⚠️ Mỗi người phải chạy emulator
- ⚠️ Không share data được

---

### 📊 **Tổng kết Firebase**

| Tình huống | Độ khó | Thời gian | Ghi chú |
|------------|--------|-----------|---------|
| **Build APK** | ⚠️ Cần setup | 15-20 phút | Cần `google-services.json` |
| **Deploy** | ⚠️ Cần setup | 20-30 phút | Cần security rules |
| **Teamwork (Chung)** | ⚠️ Phức tạp | 10 phút | Share `google-services.json` |
| **Teamwork (Riêng)** | ⚠️ Phức tạp | 20 phút | Mỗi người setup riêng |

---

## 📊 SO SÁNH TỔNG QUAN

### 🟢 **MongoDB - Dễ hơn**

| Tiêu chí | MongoDB | Firebase |
|----------|---------|----------|
| **Build APK** | ✅ Không cần setup | ⚠️ Cần `google-services.json` |
| **Deploy** | ✅ Dễ (Atlas) | ⚠️ Cần security rules |
| **Teamwork** | ✅ Rất dễ (share connection string) | ⚠️ Phức tạp (share file) |
| **Setup lần đầu** | ✅ 10-15 phút | ⚠️ 15-20 phút |
| **Maintenance** | ✅ Ít | ⚠️ Nhiều hơn (security rules) |

---

## 🎯 KHUYẾN NGHỊ

### ✅ **Cho Build APK:**
- **MongoDB:** ✅ Không cần setup gì
- **Firebase:** ⚠️ Cần `google-services.json` (làm 1 lần)

### ✅ **Cho Deploy:**
- **MongoDB:** ✅ Dùng MongoDB Atlas (dễ nhất)
- **Firebase:** ⚠️ Cần setup security rules cẩn thận

### ✅ **Cho Teamwork:**
- **MongoDB:** ✅ Dùng chung MongoDB Atlas (rất dễ)
- **Firebase:** ⚠️ Dùng chung Firebase project hoặc emulator

---

## 📝 CHECKLIST

### MongoDB:
- [ ] Tạo MongoDB Atlas account
- [ ] Tạo cluster
- [ ] Setup database user
- [ ] Whitelist IP
- [ ] Lấy connection string
- [ ] Cấu hình `.env`
- [ ] Deploy backend

### Firebase:
- [ ] Tạo Firebase project
- [ ] Thêm Android app
- [ ] Download `google-services.json`
- [ ] Copy vào `android/app/`
- [ ] Run `flutterfire configure`
- [ ] Setup Firestore
- [ ] Setup Security Rules
- [ ] Enable Authentication
- [ ] Enable FCM

---

## 🚨 LƯU Ý QUAN TRỌNG

### MongoDB:
1. ✅ **Connection string có password** - Không commit vào Git
2. ✅ **Whitelist IP** - Production nên whitelist IP cụ thể
3. ✅ **Backup** - MongoDB Atlas tự động backup

### Firebase:
1. ⚠️ **`google-services.json`** - Không commit vào Git
2. ⚠️ **Security Rules** - Phải setup cẩn thận cho production
3. ⚠️ **Cost** - Firestore có thể tốn phí khi scale
4. ⚠️ **Package name** - Phải khớp với `applicationId` trong `build.gradle.kts`

---

## 📚 TÀI LIỆU THAM KHẢO

- [MongoDB Atlas Setup](https://www.mongodb.com/docs/atlas/getting-started/)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

---

**Kết luận:** MongoDB **dễ setup hơn** cho teamwork và deploy, nhưng Firebase cũng không quá phức tạp nếu làm đúng các bước trên.

