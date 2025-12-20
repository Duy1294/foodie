import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/models/user.dart';
import '../../../../core/constants/colors.dart';
import 'shipper_orders_screen.dart';
import 'shipper_analytics_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class ShipperDashboardScreen extends StatefulWidget {
  const ShipperDashboardScreen({super.key});

  @override
  State<ShipperDashboardScreen> createState() => _ShipperDashboardScreenState();
}

class _ShipperDashboardScreenState extends State<ShipperDashboardScreen> {
  final AuthService _authService = AuthService();
  final ShipperService _shipperService = ShipperService();
  User? _currentUser;
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _currentUser = _authService.currentUser;
    });

    try {
      final profile = await _shipperService.getProfile();
      setState(() {
        _isOnline = profile['isOnline'] as bool? ?? false;
      });
    } catch (e) {
      print('Error loading shipper profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOnlineStatus(bool value) async {
    setState(() {
      _isOnline = value;
    });

    try {
      await _shipperService.updateOnlineStatus(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value ? 'Đã bật trạng thái online' : 'Đã tắt trạng thái online'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isOnline = !value; // Revert on error
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: const Text('Shipper Dashboard'),
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
              Navigator.pushNamed(context, '/shipper/settings');
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
                      'Xin chào, ${_currentUser?.fullName ?? "Shipper"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quản lý giao hàng',
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

            // Status Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trạng thái',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bật để nhận đơn hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: _updateOnlineStatus,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
              icon: Icons.shopping_bag,
              title: 'Đơn hàng mới',
              subtitle: 'Xem đơn hàng đang chờ giao',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShipperOrdersScreen(statusFilter: 'new'),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.local_shipping,
              title: 'Đơn đang giao',
              subtitle: 'Xem đơn hàng đang giao',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShipperOrdersScreen(statusFilter: 'active'),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.history,
              title: 'Lịch sử giao hàng',
              subtitle: 'Xem lịch sử đơn hàng đã giao',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShipperOrdersScreen(statusFilter: 'completed'),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.analytics,
              title: 'Thống kê',
              subtitle: 'Xem thống kê thu nhập, đơn hàng',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShipperAnalyticsScreen(),
                  ),
                );
              },
            ),
            _ActionTile(
              icon: Icons.settings,
              title: 'Cài đặt',
              subtitle: 'Cấu hình tài khoản shipper',
              onTap: () {
                Navigator.pushNamed(context, '/shipper/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
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

