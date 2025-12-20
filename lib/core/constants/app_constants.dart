class AppConstants {
  // App Info
  static const String appName = 'Foodie';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user_data';
  static const String keyCart = 'cart_data';
  static const String keyOnboarding = 'onboarding_completed';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme_mode';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusPickedUp = 'picked_up';
  static const String orderStatusOnTheWay = 'on_the_way';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';
  
  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleRestaurantOwner = 'restaurant_owner';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentWallet = 'wallet';
  static const String paymentMoMo = 'momo';
  static const String paymentZaloPay = 'zalopay';
  
  // Image
  static const String defaultImageUrl = 'https://via.placeholder.com/300';
  static const double defaultImageHeight = 200.0;
  
  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
}

