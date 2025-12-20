import 'package:flutter/material.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/order.dart';

class RestaurantAnalyticsScreen extends StatefulWidget {
  const RestaurantAnalyticsScreen({super.key});

  @override
  State<RestaurantAnalyticsScreen> createState() => _RestaurantAnalyticsScreenState();
}

class _RestaurantAnalyticsScreenState extends State<RestaurantAnalyticsScreen> {
  final OrderService _orderService = OrderService();
  final RestaurantService _restaurantService = RestaurantService();
  
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
      final restaurant = await _restaurantService.getMyRestaurant();
      if (restaurant == null) {
        setState(() {
          _error = 'Không tìm thấy nhà hàng của bạn';
          _isLoading = false;
        });
        return;
      }

      final orders = await _orderService.getOrders();

      // Calculate stats
      double totalRevenue = 0.0;
      int todayOrders = 0;
      int pendingOrders = 0;
      int deliveredOrders = 0;
      final now = DateTime.now();
      
      for (var order in orders) {
        if (order is Order) {
          totalRevenue += order.totalAmount;
          final status = order.status.toString();
          if (status.contains('pending')) pendingOrders++;
          if (status.contains('delivered')) deliveredOrders++;
          
          // Check if order is from today
          if (order.createdAt.year == now.year &&
              order.createdAt.month == now.month &&
              order.createdAt.day == now.day) {
            todayOrders++;
          }
        }
      }

      setState(() {
        _stats = {
          'totalOrders': orders.length,
          'todayOrders': todayOrders,
          'totalRevenue': totalRevenue,
          'pendingOrders': pendingOrders,
          'deliveredOrders': deliveredOrders,
          'rating': restaurant.ratingAverage,
          'ratingCount': restaurant.ratingCount,
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
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: Colors.grey[600]),
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
                              title: 'Tổng đơn hàng',
                              value: '${_stats['totalOrders'] ?? 0}',
                              icon: Icons.shopping_bag,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Đơn hôm nay',
                              value: '${_stats['todayOrders'] ?? 0}',
                              icon: Icons.today,
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
                              title: 'Doanh thu',
                              value: '${(_stats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}₫',
                              icon: Icons.attach_money,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Đánh giá',
                              value: '${(_stats['rating'] ?? 0.0).toStringAsFixed(1)}',
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Order Status
                      const Text(
                        'Trạng thái đơn hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _StatusRow(
                                label: 'Chờ xác nhận',
                                count: _stats['pendingOrders'] ?? 0,
                                color: Colors.orange,
                              ),
                              const Divider(),
                              _StatusRow(
                                label: 'Đã giao',
                                count: _stats['deliveredOrders'] ?? 0,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Rating Info
                      if (_stats['ratingCount'] != null && (_stats['ratingCount'] as int) > 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Số lượt đánh giá:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${_stats['ratingCount']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

