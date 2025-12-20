import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  final OrderService _orderService = OrderService();
  final RestaurantService _restaurantService = RestaurantService();
  
  List<Order> _orders = [];
  bool _isLoading = true;
  String _error = '';
  
  String? _selectedStatus;
  String? _myRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool resetPage = false}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Get restaurant owner's restaurant ID
      if (_myRestaurantId == null) {
        final myRestaurant = await _restaurantService.getMyRestaurant();
        if (myRestaurant != null) {
          _myRestaurantId = myRestaurant.id;
        } else {
          setState(() {
            _error = 'Không tìm thấy nhà hàng của bạn';
            _isLoading = false;
          });
          return;
        }
      }

      final orders = await _orderService.getOrders();
      
      // Filter orders to only show orders belonging to this restaurant
      List<Order> restaurantOrders = orders.where((order) {
        return order.restaurantId == _myRestaurantId;
      }).toList();
      
      // Filter by status if selected
      List<Order> filteredOrders = restaurantOrders;
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty && _selectedStatus != 'all') {
        filteredOrders = restaurantOrders.where((order) => order.status.toString().contains(_selectedStatus!)).toList();
      }

      setState(() {
        _orders = filteredOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.pickedUp:
        return Colors.indigo;
      case OrderStatus.onTheWay:
        return Colors.cyan;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.preparing:
        return 'Đang chuẩn bị';
      case OrderStatus.ready:
        return 'Sẵn sàng';
      case OrderStatus.pickedUp:
        return 'Đã lấy hàng';
      case OrderStatus.onTheWay:
        return 'Đang giao';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
      default:
        return status.toString();
    }
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    String statusText = '';
    if (newStatus == 'confirmed') statusText = 'Đã xác nhận';
    else if (newStatus == 'preparing') statusText = 'Đang chuẩn bị';
    else if (newStatus == 'ready') statusText = 'Sẵn sàng';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật trạng thái'),
        content: Text('Cập nhật trạng thái đơn hàng #${order.orderNumber} thành "$statusText"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.updateOrderStatus(order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật trạng thái thành "$statusText"'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Reload orders
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus ?? 'all',
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(value: 'pending', child: Text('Chờ xác nhận')),
                DropdownMenuItem(value: 'confirmed', child: Text('Đã xác nhận')),
                DropdownMenuItem(value: 'preparing', child: Text('Đang chuẩn bị')),
                DropdownMenuItem(value: 'ready', child: Text('Sẵn sàng')),
                DropdownMenuItem(value: 'picked_up', child: Text('Đã lấy hàng')),
                DropdownMenuItem(value: 'on_the_way', child: Text('Đang giao')),
                DropdownMenuItem(value: 'delivered', child: Text('Đã giao')),
                DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value == 'all' ? null : value;
                });
                _loadOrders();
              },
            ),
          ),
          Expanded(
            child: _isLoading
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
                              onPressed: _loadOrders,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chưa có đơn hàng nào',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                final status = order.status;
                                final hasDriver = order.driverId != null && order.driverId!.isNotEmpty;
                                // Can update if: pending (can confirm), or confirmed/preparing with driver assigned
                                final canUpdate = status == OrderStatus.pending || 
                                                 (status == OrderStatus.confirmed && hasDriver) || 
                                                 (status == OrderStatus.preparing && hasDriver);
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
                                          child: Icon(
                                            Icons.receipt,
                                            color: _getStatusColor(order.status),
                                          ),
                                        ),
                                        title: Text(
                                          'Đơn #${order.orderNumber}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text('${order.items.length} món'),
                                            Text(
                                              '${order.totalAmount.toStringAsFixed(0)}₫',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(order.status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _getStatusLabel(order.status),
                                                style: TextStyle(
                                                  color: _getStatusColor(order.status),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => OrderDetailScreen(orderId: order.id),
                                            ),
                                          );
                                        },
                                      ),
                                      // Action buttons for restaurant
                                      if (canUpdate)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              if (status == OrderStatus.pending)
                                                ElevatedButton.icon(
                                                  onPressed: () => _updateOrderStatus(order, 'confirmed'),
                                                  icon: const Icon(Icons.check_circle),
                                                  label: const Text('Xác nhận đơn hàng'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                              if (status == OrderStatus.confirmed) ...[
                                                if (!hasDriver)
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade50,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.orange.shade200),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            'Đang chờ shipper nhận đơn',
                                                            style: TextStyle(
                                                              color: Colors.orange.shade700,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                else
                                                  ElevatedButton.icon(
                                                    onPressed: () => _updateOrderStatus(order, 'preparing'),
                                                    icon: const Icon(Icons.restaurant),
                                                    label: const Text('Bắt đầu chuẩn bị'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.purple,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                  ),
                                              ],
                                              if (status == OrderStatus.preparing && hasDriver)
                                                ElevatedButton.icon(
                                                  onPressed: () => _updateOrderStatus(order, 'ready'),
                                                  icon: const Icon(Icons.check),
                                                  label: const Text('Sẵn sàng giao hàng'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.teal,
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

