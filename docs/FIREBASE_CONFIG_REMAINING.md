# ⚙️ CẤU HÌNH FIREBASE CÒN LẠI

**Ngày tạo:** 2025-01-XX

---

## ✅ ĐÃ HOÀN THÀNH

- [x] Packages đã được thêm vào `pubspec.yaml`
- [x] Code đã được implement
- [x] Android configuration đã được setup
- [x] `flutter pub get` đã chạy thành công

---

## ⚠️ CẦN LÀM TIẾP

### 1. Setup Firebase Project (QUAN TRỌNG)

#### Bước 1: Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** hoặc **"Create a project"**
3. Nhập tên project: `Foodie` (hoặc tên bạn muốn)
4. Chọn Google Analytics (tùy chọn)
5. Click **"Create project"**

#### Bước 2: Thêm Android App

1. Trong Firebase Console, click **"Add app"** → Chọn **Android**
2. Nhập thông tin:
   - **Android package name:** `com.example.foodie`
   - **App nickname:** `Foodie Android` (tùy chọn)
3. Click **"Register app"**
4. Download file `google-services.json`
5. **Copy file vào:** `android/app/google-services.json` (thay thế file cũ nếu có)

#### Bước 3: Enable Firebase Services

1. **Firebase Cloud Messaging (FCM):**
   - Vào **Cloud Messaging** trong Firebase Console
   - Click **"Get started"** (nếu chưa enable)
   - Đã tự động enable khi thêm Android app

2. **Cloud Firestore:**
   - Vào **Firestore Database**
   - Click **"Create database"**
   - Chọn **"Start in test mode"** (cho development)
   - Chọn location: `asia-southeast1` (gần Việt Nam)
   - Click **"Enable"**

3. **Firebase Authentication:**
   - Vào **Authentication**
   - Click **"Get started"**
   - Vào tab **"Sign-in method"**
   - Enable **Email/Password**
   - Enable **Google** (cần cấu hình OAuth client ID)

#### Bước 4: Cấu hình Google Sign-In (Tùy chọn)

1. Trong **Google Sign-In** settings:
   - **Project support email:** Chọn email của bạn
   - Click **"Save"**

2. Lấy SHA-1 fingerprint (cho Android):
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Tìm dòng có `SHA1:` và copy giá trị

3. Thêm SHA-1 vào Firebase Console:
   - Vào Firebase Console → Project Settings
   - Scroll xuống phần "Your apps"
   - Click vào Android app
   - Thêm SHA-1 fingerprint vào phần "SHA certificate fingerprints"

---

### 2. Test Firebase

#### Test 1: Chạy App

```bash
flutter run
```

Kiểm tra logs:
- ✅ `Firebase initialized successfully`
- ✅ `FCM Token: ...`

#### Test 2: Test FCM

1. Trong Firebase Console → **Cloud Messaging**
2. Click **"Send test message"**
3. Nhập FCM token (lấy từ app logs)
4. Nhập title và message
5. Click **"Test"**
6. Kiểm tra notification trên device

#### Test 3: Test Firestore

1. Trong Firebase Console → **Firestore Database**
2. Click **"Start collection"**
3. Tạo collection `test` với document ID `test1`
4. Thêm field `message` = `"Hello Firestore"`
5. Trong app, kiểm tra xem có thể đọc được không

#### Test 4: Test Google Sign-In

1. Chạy app
2. Vào màn hình Login
3. Click nút **"Đăng nhập với Google"**
4. Chọn Google account
5. Kiểm tra đăng nhập thành công

---

### 3. Firestore Security Rules (QUAN TRỌNG)

**Hiện tại (Test mode):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

⚠️ **Lưu ý:** Rules trên chỉ dùng cho development. Production cần rules chặt chẽ hơn.

**Production Rules (Cần update sau):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders - chỉ user liên quan mới đọc được
    match /orders/{orderId} {
      allow read: if request.auth != null 
        && (resource.data.customerId == request.auth.uid 
            || resource.data.restaurantId == request.auth.uid
            || resource.data.driverId == request.auth.uid);
      allow write: if false; // Chỉ backend được write
    }
    
    // Driver location - chỉ user liên quan mới đọc được
    match /orders/{orderId}/driver_location/{locationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
        && request.auth.uid == resource.data.driverId;
    }
  }
}
```

---

## 📝 CHECKLIST

### Setup Firebase Project:
- [ ] Tạo Firebase project
- [ ] Thêm Android app
- [ ] Download `google-services.json`
- [ ] Copy `google-services.json` vào `android/app/`
- [ ] Enable FCM
- [ ] Enable Firestore (test mode)
- [ ] Enable Firebase Auth (Email/Password, Google)
- [ ] Cấu hình Google Sign-In (nếu cần)

### Test:
- [ ] Chạy `flutter run` và kiểm tra Firebase initialization
- [ ] Test FCM notifications
- [ ] Test Firestore read/write
- [ ] Test Google Sign-In

### Production (Sau này):
- [ ] Update Firestore Security Rules
- [ ] Setup Firebase Analytics (nếu cần)
- [ ] Setup Firebase Crashlytics (nếu cần)

---

## 🚨 LƯU Ý QUAN TRỌNG

1. **Firebase Storage đã bỏ** - Vì cần trả phí, không cần enable
2. **Firestore có free tier** - 50K reads/day, 20K writes/day (đủ cho development)
3. **FCM miễn phí** - Không giới hạn số lượng notifications
4. **Firebase Auth miễn phí** - Không giới hạn users

---

## 📚 TÀI LIỆU THAM KHẢO

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Sau khi hoàn thành các bước trên, Firebase sẽ hoạt động đầy đủ! 🎉**

