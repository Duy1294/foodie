import 'package:flutter/material.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/order.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AdminService _adminService = AdminService();
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load all data to calculate stats
      final usersResult = await _adminService.getUsers(limit: 1000);
      final restaurantsResult = await _adminService.getRestaurants(limit: 1000);
      final ordersResult = await _adminService.getOrders(limit: 1000);
      final shippersResult = await _adminService.getShippers(limit: 1000);

      final users = usersResult['users'] as List;
      final restaurants = restaurantsResult['restaurants'] as List;
      final ordersList = ordersResult['orders'] as List;
      final shippers = shippersResult['shippers'] as List;

      // Calculate stats
      double totalRevenue = 0.0;
      int pendingOrders = 0;
      int deliveredOrders = 0;
      
      for (var orderData in ordersList) {
        if (orderData is Order) {
          totalRevenue += orderData.totalAmount;
          final status = orderData.status.toString();
          if (status.contains('pending')) pendingOrders++;
          if (status.contains('delivered')) deliveredOrders++;
        } else if (orderData is Map) {
          // Handle Map case (if orders are not parsed yet)
          try {
            final order = Order.fromJson(orderData as Map<String, dynamic>);
            totalRevenue += order.totalAmount;
            final status = order.status.toString();
            if (status.contains('pending')) pendingOrders++;
            if (status.contains('delivered')) deliveredOrders++;
          } catch (e) {
            print('❌ Error parsing order in analytics: $e');
            print('📋 Order data: $orderData');
          }
        }
      }

      setState(() {
        _stats = {
          'totalUsers': users.length,
          'totalRestaurants': restaurants.length,
          'totalOrders': ordersList.length,
          'totalShippers': shippers.length,
          'totalRevenue': totalRevenue,
          'pendingOrders': pendingOrders,
          'deliveredOrders': deliveredOrders,
          'activeRestaurants': restaurants.where((r) => r.isActive == true).length,
          'verifiedRestaurants': restaurants.where((r) => r.isVerified == true).length,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê & Báo cáo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng quan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Main Stats Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: [
                            _StatCard(
                              title: 'Tổng Users',
                              value: '${_stats['totalUsers'] ?? 0}',
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                            _StatCard(
                              title: 'Nhà hàng',
                              value: '${_stats['totalRestaurants'] ?? 0}',
                              icon: Icons.restaurant,
                              color: Colors.orange,
                            ),
                            _StatCard(
                              title: 'Đơn hàng',
                              value: '${_stats['totalOrders'] ?? 0}',
                              icon: Icons.shopping_cart,
                              color: Colors.green,
                            ),
                            _StatCard(
                              title: 'Shippers',
                              value: '${_stats['totalShippers'] ?? 0}',
                              icon: Icons.delivery_dining,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Doanh thu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          color: AppColors.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.white, size: 40),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tổng doanh thu',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(_stats['totalRevenue'] ?? 0.0),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Đơn hàng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Chờ xử lý',
                                value: '${_stats['pendingOrders'] ?? 0}',
                                icon: Icons.pending,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Đã giao',
                                value: '${_stats['deliveredOrders'] ?? 0}',
                                icon: Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Nhà hàng',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Đang hoạt động',
                                value: '${_stats['activeRestaurants'] ?? 0}',
                                icon: Icons.store,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Đã xác thực',
                                value: '${_stats['verifiedRestaurants'] ?? 0}',
                                icon: Icons.verified,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
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
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

