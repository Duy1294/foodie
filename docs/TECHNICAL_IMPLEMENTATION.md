# HƯỚNG DẪN TRIỂN KHAI KỸ THUẬT - FLUTTER FOODIE APP

## 1. CẤU TRÚC DỰ ÁN FLUTTER

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Root widget
│   └── routes.dart                 # Route configuration
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # API endpoints
│   │   ├── app_constants.dart      # App constants
│   │   └── colors.dart            # Color scheme
│   ├── utils/
│   │   ├── validators.dart         # Form validators
│   │   ├── helpers.dart            # Helper functions
│   │   └── date_formatter.dart     # Date formatting
│   ├── services/
│   │   ├── api_service.dart        # API client
│   │   ├── auth_service.dart       # Authentication
│   │   ├── location_service.dart   # Location services
│   │   ├── notification_service.dart # Push notifications
│   │   └── storage_service.dart   # Local storage
│   └── models/
│       ├── user.dart
│       ├── restaurant.dart
│       ├── menu_item.dart
│       ├── order.dart
│       └── review.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── forgot_password_screen.dart
│   │       └── widgets/
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── widgets/
│   ├── restaurants/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── restaurant_list_screen.dart
│   │       │   ├── restaurant_detail_screen.dart
│   │       │   └── menu_screen.dart
│   │       └── widgets/
│   ├── cart/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── cart_screen.dart
│   │       └── widgets/
│   ├── orders/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── order_list_screen.dart
│   │       │   ├── order_detail_screen.dart
│   │       │   └── order_tracking_screen.dart
│   │       └── widgets/
│   ├── profile/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   ├── address_management_screen.dart
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   ├── restaurant_owner/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── restaurant_dashboard_screen.dart
│   │       │   ├── menu_management_screen.dart
│   │       │   └── order_management_screen.dart
│   │       └── widgets/
│   └── driver/
│       └── presentation/
│           ├── screens/
│           │   ├── driver_dashboard_screen.dart
│           │   ├── available_orders_screen.dart
│           │   └── active_delivery_screen.dart
│           └── widgets/
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    └── themes/
        ├── app_theme.dart
        └── text_styles.dart
```

## 2. FLUTTER PACKAGES CẦN THIẾT

### 2.1. State Management
```yaml
# Option 1: Provider (Recommended cho beginners)
provider: ^6.1.1

# Option 2: Riverpod (Modern, type-safe)
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3

# Option 3: Bloc (Enterprise-grade)
flutter_bloc: ^8.1.3
bloc: ^8.1.2
```

### 2.2. Networking
```yaml
# HTTP client
dio: ^5.4.0
retrofit: ^4.0.3
json_annotation: ^4.8.1

# WebSocket cho real-time
web_socket_channel: ^2.4.0
```

### 2.3. Local Storage
```yaml
# Key-value storage
shared_preferences: ^2.2.2

# SQLite database
sqflite: ^2.3.0
path: ^1.8.3

# Secure storage cho tokens
flutter_secure_storage: ^9.0.0
```

### 2.4. Authentication
```yaml
# Firebase Auth
firebase_auth: ^4.15.3
firebase_core: ^2.24.2

# OAuth
google_sign_in: ^6.1.6
sign_in_with_apple: ^5.0.0
```

### 2.5. Maps & Location
```yaml
# Google Maps
google_maps_flutter: ^2.5.0
geolocator: ^10.1.0
geocoding: ^2.1.1

# Location permissions
permission_handler: ^11.1.0
```

### 2.6. UI Components
```yaml
# Image handling
cached_network_image: ^3.3.1
image_picker: ^1.0.5

# Icons
flutter_svg: ^2.0.9
font_awesome_flutter: ^10.6.0

# Animations
lottie: ^2.7.0
animations: ^2.0.8

# Carousel
carousel_slider: ^5.0.0

# Bottom sheet
modal_bottom_sheet: ^3.0.0
```

### 2.7. Forms & Validation
```yaml
# Form handling
flutter_form_builder: ^9.1.1
form_builder_validators: ^9.1.0
```

### 2.8. Payments
```yaml
# Payment gateways (tùy theo region)
# Ví dụ cho Việt Nam:
# momo_payment: ^1.0.0 (nếu có package)
# zalopay_sdk: ^1.0.0 (nếu có package)

# Hoặc sử dụng WebView cho payment
webview_flutter: ^4.4.2
```

### 2.9. Notifications
```yaml
# Firebase Cloud Messaging
firebase_messaging: ^14.7.10
flutter_local_notifications: ^16.3.0
```

### 2.10. Utilities
```yaml
# Date & Time
intl: ^0.19.0

# URL Launcher
url_launcher: ^6.2.2

# Connectivity
connectivity_plus: ^5.0.2

# Device Info
device_info_plus: ^9.1.1

# Package Info
package_info_plus: ^5.0.1

# Path Provider
path_provider: ^2.1.1

# Logger
logger: ^2.0.2+1
```

### 2.11. Testing
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

## 3. CẤU HÌNH ANDROID

### 3.1. android/app/build.gradle
```gradle
android {
    compileSdkVersion 34
    minSdkVersion 21
    targetSdkVersion 34
    
    defaultConfig {
        applicationId "com.example.foodie"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 3.2. android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.CALL_PHONE"/>
    
    <application
        android:label="Foodie"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
            
        <!-- Firebase -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel"/>
    </application>
</manifest>
```

## 4. CẤU HÌNH iOS

### 4.1. ios/Runner/Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Chúng tôi cần vị trí của bạn để tìm nhà hàng gần nhất và giao hàng</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Chúng tôi cần vị trí của bạn để theo dõi đơn hàng real-time</string>

<key>NSCameraUsageDescription</key>
<string>Chúng tôi cần camera để chụp ảnh món ăn và đánh giá</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Chúng tôi cần truy cập thư viện ảnh để chọn hình ảnh</string>
```

## 5. KIẾN TRÚC CLEAN ARCHITECTURE

### 5.1. Data Layer
- **Models:** Data models từ API
- **Repositories:** Implement repository interfaces
- **Data Sources:** API, Local Database

### 5.2. Domain Layer
- **Entities:** Business objects
- **Repositories:** Repository interfaces
- **Use Cases:** Business logic

### 5.3. Presentation Layer
- **Screens:** UI screens
- **Widgets:** Reusable widgets
- **State Management:** Provider/Riverpod/Bloc

## 6. API SERVICE SETUP

### 6.1. API Client với Dio
```dart
class ApiService {
  late Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ));
    
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
}
```

### 6.2. Authentication Interceptor
```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - redirect to login
    }
    handler.next(err);
  }
}
```

## 7. STATE MANAGEMENT VỚI PROVIDER

### 7.1. Example: Restaurant Provider
```dart
class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  
  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  
  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.get('/restaurants');
      _restaurants = (response.data as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 8. REAL-TIME TRACKING

### 8.1. WebSocket Service
```dart
class WebSocketService {
  WebSocketChannel? _channel;
  
  void connect(String orderId) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://your-api.com/ws/orders/$orderId'),
    );
  }
  
  Stream<OrderStatus> get orderStatusStream {
    return _channel!.stream.map(
      (data) => OrderStatus.fromJson(jsonDecode(data)),
    );
  }
  
  void disconnect() {
    _channel?.sink.close();
  }
}
```

## 9. LOCATION SERVICES

### 9.1. Location Service
```dart
class LocationService {
  final Geolocator _geolocator = Geolocator();
  
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }
    
    LocationPermission permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    return await _geolocator.getCurrentPosition();
  }
  
  Stream<Position> getLocationStream() {
    return _geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
```

## 10. PUSH NOTIFICATIONS

### 10.1. Firebase Messaging Setup
```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      // Send token to backend
    }
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show local notification
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
```

## 11. TESTING STRATEGY

### 11.1. Unit Tests
```dart
// test/features/restaurants/domain/use_cases/get_restaurants_test.dart
void main() {
  test('should get restaurants from repository', () async {
    // Arrange
    final mockRepository = MockRestaurantRepository();
    final useCase = GetRestaurants(mockRepository);
    
    // Act
    final result = await useCase();
    
    // Assert
    expect(result, isA<List<Restaurant>>());
  });
}
```

### 11.2. Widget Tests
```dart
// test/features/restaurants/presentation/widgets/restaurant_card_test.dart
void main() {
  testWidgets('should display restaurant name', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RestaurantCard(restaurant: mockRestaurant),
      ),
    );
    
    expect(find.text('Restaurant Name'), findsOneWidget);
  });
}
```

## 12. DEPLOYMENT CHECKLIST

### 12.1. Pre-deployment
- [ ] Tất cả tests đã pass
- [ ] Code review hoàn tất
- [ ] Performance testing
- [ ] Security audit
- [ ] UI/UX review

### 12.2. Build Configuration
- [ ] Update version code và version name
- [ ] Configure signing keys
- [ ] Set up ProGuard rules (Android)
- [ ] Configure App Store Connect (iOS)

### 12.3. App Store Submission
- [ ] Screenshots và app preview
- [ ] App description và keywords
- [ ] Privacy policy URL
- [ ] Support URL
- [ ] App icon và splash screen

---

**Tài liệu này sẽ được cập nhật khi có thay đổi trong quá trình phát triển.**

