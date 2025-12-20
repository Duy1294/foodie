import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/user.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../restaurant/presentation/screens/restaurant_dashboard_screen.dart';
import '../../../shipper/presentation/screens/shipper_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(AppConstants.splashDuration);
    
    if (!mounted) return;
    
    final authService = AuthService();
    
    if (authService.isAuthenticated) {
      final user = authService.currentUser;
      Widget nextScreen;
      
      // Route based on user role
      switch (user?.role) {
        case UserRole.admin:
          nextScreen = const AdminDashboardScreen();
          break;
        case UserRole.restaurantOwner:
          nextScreen = const RestaurantDashboardScreen();
          break;
        case UserRole.driver:
          nextScreen = const ShipperDashboardScreen();
          break;
        case UserRole.customer:
        default:
          nextScreen = const HomeScreen();
          break;
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đặt đồ ăn nhanh chóng',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

