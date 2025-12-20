import 'package:flutter/material.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/order.dart';
import '../../../../core/constants/colors.dart';

class ShipperAnalyticsScreen extends StatefulWidget {
  const ShipperAnalyticsScreen({super.key});

  @override
  State<ShipperAnalyticsScreen> createState() => _ShipperAnalyticsScreenState();
}

class _ShipperAnalyticsScreenState extends State<ShipperAnalyticsScreen> {
  final OrderService _orderService = OrderService();
  
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
      final orders = await _orderService.getOrders();

      // Calculate stats
      double totalEarnings = 0.0;
      int todayOrders = 0;
      int activeOrders = 0;
      int completedOrders = 0;
      int totalOrders = orders.length;
      
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      for (var order in orders) {
        if (order.status.toString().contains('delivered')) {
          completedOrders++;
          // Assume earnings = deliveryFee or a percentage of totalAmount
          totalEarnings += order.deliveryFee ?? 0;
        }
        if (order.status.toString().contains('picked_up') || 
            order.status.toString().contains('on_the_way')) {
          activeOrders++;
        }
        if (order.createdAt.isAfter(todayStart)) {
          todayOrders++;
        }
      }

      setState(() {
        _stats = {
          'totalOrders': totalOrders,
          'todayOrders': todayOrders,
          'activeOrders': activeOrders,
          'completedOrders': completedOrders,
          'totalEarnings': totalEarnings,
          'averageRating': 4.5, // TODO: Calculate from reviews
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
        title: const Text('Thống kê'),
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
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Lỗi: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Tổng đơn',
                              value: '${_stats['totalOrders'] ?? 0}',
                              icon: Icons.shopping_bag,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Hôm nay',
                              value: '${_stats['todayOrders'] ?? 0}',
                              icon: Icons.today,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Đang giao',
                              value: '${_stats['activeOrders'] ?? 0}',
                              icon: Icons.local_shipping,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Đã hoàn thành',
                              value: '${_stats['completedOrders'] ?? 0}',
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Thu nhập',
                              value: '${_formatCurrency(_stats['totalEarnings'] ?? 0.0)}',
                              icon: Icons.attach_money,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Đánh giá',
                              value: '${_stats['averageRating'] ?? 0.0}',
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M₫';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K₫';
    }
    return '${amount.toStringAsFixed(0)}₫';
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

