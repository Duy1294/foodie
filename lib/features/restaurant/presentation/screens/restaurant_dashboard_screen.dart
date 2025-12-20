import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user.dart';
import '../../../../core/constants/colors.dart';
import 'restaurant_menu_management_screen.dart';
import 'restaurant_info_screen.dart';
import 'restaurant_settings_screen.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_analytics_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _currentUser = _authService.currentUser;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhà hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Hide back button
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào, ${_currentUser?.fullName ?? "Chủ nhà hàng"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quản lý nhà hàng của bạn',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Thao tác nhanh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.restaurant_menu,
              title: 'Quản lý Menu',
              subtitle: 'Thêm, sửa, xóa món ăn',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantMenuManagementScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.shopping_bag,
              title: 'Đơn hàng',
              subtitle: 'Xem và xử lý đơn hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantOrdersScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.store,
              title: 'Thông tin Nhà hàng',
              subtitle: 'Chỉnh sửa thông tin nhà hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantInfoScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.analytics,
              title: 'Thống kê',
              subtitle: 'Xem báo cáo doanh thu, đơn hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantAnalyticsScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.settings,
              title: 'Cài đặt',
              subtitle: 'Cấu hình nhà hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RestaurantSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

