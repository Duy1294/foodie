import 'package:flutter/material.dart';
import '../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../features/admin/presentation/screens/admin_settings_screen.dart';
import '../../../features/restaurant/presentation/screens/restaurant_dashboard_screen.dart';
import '../../../features/restaurant/presentation/screens/restaurant_settings_screen.dart';
import '../../../features/shipper/presentation/screens/shipper_dashboard_screen.dart';
import '../../../features/shipper/presentation/screens/shipper_settings_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Admin routes
      '/admin/dashboard': (context) => const AdminDashboardScreen(),
      '/admin/settings': (context) => const AdminSettingsScreen(),
      
      // Restaurant routes
      '/restaurant/dashboard': (context) => const RestaurantDashboardScreen(),
      '/restaurant/settings': (context) => const RestaurantSettingsScreen(),
      
      // Shipper routes
      '/shipper/dashboard': (context) => const ShipperDashboardScreen(),
      '/shipper/settings': (context) => const ShipperSettingsScreen(),
    };
  }
}

