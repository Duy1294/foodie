import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../home/presentation/screens/home_screen.dart' as home;

// Temporary home screen that redirects to actual home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    if (!authService.isAuthenticated) {
      // If not authenticated, this shouldn't happen but handle it
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập')),
      );
    }
    
    return const home.HomeScreen();
  }
}

