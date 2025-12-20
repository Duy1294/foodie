import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/models/user.dart';
import '../../../../core/constants/colors.dart';
import 'admin_users_screen.dart';
import 'admin_restaurants_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_shippers_screen.dart';
import 'admin_analytics_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
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
              Navigator.pushNamed(context, '/admin/settings');
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
                      'Xin chào, ${_currentUser?.fullName ?? "Admin"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quản trị hệ thống Foodie',
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
              icon: Icons.people_outline,
              title: 'Quản lý Users',
              subtitle: 'Xem, chỉnh sửa, khóa/mở khóa tài khoản',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.restaurant_menu,
              title: 'Quản lý Nhà hàng',
              subtitle: 'Duyệt, chỉnh sửa, xóa nhà hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRestaurantsScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.shopping_bag,
              title: 'Quản lý Đơn hàng',
              subtitle: 'Xem tất cả đơn hàng, can thiệp khi cần',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminOrdersScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.delivery_dining,
              title: 'Quản lý Shippers',
              subtitle: 'Xem, chỉnh sửa thông tin shipper',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminShippersScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.analytics,
              title: 'Thống kê & Báo cáo',
              subtitle: 'Xem báo cáo doanh thu, đơn hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminAnalyticsScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.settings,
              title: 'Cài đặt hệ thống',
              subtitle: 'Cấu hình hệ thống, thông báo',
              onTap: () {
                Navigator.pushNamed(context, '/admin/settings');
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

