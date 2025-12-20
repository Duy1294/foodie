class ApiConstants {
  // Base URL - Backend API
  // Development: http://localhost:3000/api/v1
  // Android Emulator: 
  //   - http://localhost:3000/api/v1 (when using adb reverse tcp:3000 tcp:3000)
  //   - http://10.0.2.2:3000/api/v1 (default - maps to host's localhost)
  //   - http://192.168.100.18:3000/api/v1 (use your computer's IP if others don't work)
  // iOS Simulator: http://localhost:3000/api/v1
  // Physical device: http://YOUR_COMPUTER_IP:3000/api/v1
  // Note: Using localhost with adb port forwarding is the most reliable method
  // For Android Emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Android Emulator - maps to host's localhost
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User endpoints
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';
  
      // Restaurant endpoints
      static const String restaurants = '/restaurants';
      static const String myRestaurant = '/restaurants/my-restaurant';
      static String restaurantDetail(String id) => '/restaurants/$id';
      static String restaurantMenu(String id) => '/restaurants/$id/menu';
      static String restaurantMenuManage(String id) => '/restaurants/$id/menu/manage';
      static String restaurantMenuItem(String restaurantId, String menuItemId) => '/restaurants/$restaurantId/menu/$menuItemId';
      static String restaurantReviews(String id) => '/restaurants/$id/reviews';
      static const String searchRestaurants = '/restaurants/search';
      static String restaurantDelivery(String id) => '/restaurants/$id/delivery';
      static String restaurantHours(String id) => '/restaurants/$id/hours';
  
  // Order endpoints
  static const String orders = '/orders';
  static const String availableOrders = '/orders/available';
  static String orderDetail(String id) => '/orders/$id';
  static String acceptOrder(String id) => '/orders/$id/accept';
  static String updateOrderStatus(String id) => '/orders/$id/status';
  static String cancelOrder(String id) => '/orders/$id/cancel';
  
  // Cart endpoints
  static const String cart = '/cart';
  
  // Address endpoints
  static const String addresses = '/addresses';
  static String addressDetail(String id) => '/addresses/$id';
  
  // Review endpoints
  static const String reviews = '/reviews';
  static String reviewDetail(String id) => '/reviews/$id';
  
  // Voucher endpoints
  static const String vouchers = '/vouchers';
  static String applyVoucher(String code) => '/vouchers/$code/apply';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String unreadNotificationCount = '/notifications/unread-count';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  
  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static String adminUserDetail(String id) => '/admin/users/$id';
  static const String adminRestaurants = '/admin/restaurants';
  static String adminRestaurantDetail(String id) => '/admin/restaurants/$id';
  static const String adminOrders = '/admin/orders';
      static const String adminShippers = '/admin/shippers';
      static String adminShipperDetail(String id) => '/admin/shippers/$id';
      
      // Shipper endpoints
      static const String shipperProfile = '/shippers/profile';
      static const String shipperVehicle = '/shippers/vehicle';
      static const String shipperLocation = '/shippers/location';
      static const String shipperOnlineStatus = '/shippers/online-status';
      static const String shipperNotificationSettings = '/shippers/settings/notifications';
      static const String shipperWorkingHours = '/shippers/settings/working-hours';
      static const String shipperDeliveryAreas = '/shippers/settings/delivery-areas';
      
      // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

