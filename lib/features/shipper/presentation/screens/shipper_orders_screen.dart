import 'package:flutter/material.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/order.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';

class ShipperOrdersScreen extends StatefulWidget {
  final String? statusFilter;

  const ShipperOrdersScreen({
    super.key,
    this.statusFilter,
  });

  @override
  State<ShipperOrdersScreen> createState() => _ShipperOrdersScreenState();
}

class _ShipperOrdersScreenState extends State<ShipperOrdersScreen> {
  final OrderService _orderService = OrderService();
  
  List<Order> _orders = [];
  bool _isLoading = true;
  String _error = '';
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.statusFilter;
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      List<Order> orders;
      
      // If statusFilter is 'new', get available orders (orders without driver)
      if (_selectedStatus == 'new') {
        orders = await _orderService.getAvailableOrders();
      } else {
        // Otherwise, get assigned orders
        orders = await _orderService.getOrders();
        
        // Filter by status if provided
        if (_selectedStatus != null) {
          orders = orders.where((order) {
            final status = order.status.toString().toLowerCase();
            if (_selectedStatus == 'active') {
              // Hiển thị tất cả đơn đã nhận (có driverId) và chưa delivered
              // Bao gồm: confirmed, preparing, ready, picked_up, on_the_way
              return order.driverId != null && 
                     order.driverId!.isNotEmpty &&
                     !status.contains('delivered') && 
                     !status.contains('cancelled');
            } else if (_selectedStatus == 'completed') {
              return status.contains('delivered');
            }
            return true;
          }).toList();
        }
      }

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhận đơn hàng'),
        content: Text('Bạn có chắc chắn muốn nhận đơn hàng #${order.orderNumber}?'),
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
            child: const Text('Nhận đơn'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.acceptOrder(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã nhận đơn hàng thành công'),
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

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    String statusText = '';
    if (newStatus == 'picked_up') statusText = 'Đã lấy hàng';
    else if (newStatus == 'on_the_way') statusText = 'Đang giao';
    else if (newStatus == 'delivered') statusText = 'Đã giao';

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

  String _getStatusText(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('pending')) return 'Chờ xử lý';
    if (statusLower.contains('confirmed')) return 'Đã xác nhận';
    if (statusLower.contains('preparing')) return 'Đang chuẩn bị';
    if (statusLower.contains('ready')) return 'Sẵn sàng';
    if (statusLower.contains('picked_up')) return 'Đã lấy hàng';
    if (statusLower.contains('on_the_way')) return 'Đang giao';
    if (statusLower.contains('delivered')) return 'Đã giao';
    if (statusLower.contains('cancelled')) return 'Đã hủy';
    return status;
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('pending') || statusLower.contains('confirmed')) {
      return Colors.orange;
    }
    if (statusLower.contains('preparing') || statusLower.contains('ready')) {
      return Colors.blue;
    }
    if (statusLower.contains('picked_up') || statusLower.contains('on_the_way')) {
      return Colors.purple;
    }
    if (statusLower.contains('delivered')) {
      return Colors.green;
    }
    if (statusLower.contains('cancelled')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final title = _selectedStatus == 'new'
        ? 'Đơn hàng mới'
        : _selectedStatus == 'active'
            ? 'Đơn đang giao'
            : _selectedStatus == 'completed'
                ? 'Lịch sử giao hàng'
                : 'Đơn hàng';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có đơn hàng nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        itemCount: _orders.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final status = order.status.toString().toLowerCase();
                          final statusEnum = order.status; // Use enum for comparison
                          final isAvailable = _selectedStatus == 'new' && order.driverId == null;
                          final isMyOrder = order.driverId != null;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    'Đơn #${order.orderNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text('${order.items.length} món'),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getStatusText(order.status.toString()),
                                        style: TextStyle(
                                          color: _getStatusColor(order.status.toString()),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tổng: ${_formatCurrency(order.totalAmount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(orderId: order.id),
                                      ),
                                    );
                                  },
                                ),
                                // Action buttons
                                if (isAvailable)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _acceptOrder(order),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Nhận đơn'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                  )
                                else if (isMyOrder)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      children: [
                                        // Nút "Đã lấy hàng" khi order ở status ready - chuyển trực tiếp sang on_the_way
                                        if (statusEnum == OrderStatus.ready)
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _updateOrderStatus(order, 'on_the_way'),
                                              icon: const Icon(Icons.shopping_bag),
                                              label: const Text('Đã lấy hàng'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        // Nút "Hoàn thành" khi order ở status on_the_way
                                        if (statusEnum == OrderStatus.onTheWay)
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _updateOrderStatus(order, 'delivered'),
                                              icon: const Icon(Icons.check_circle),
                                              label: const Text('Hoàn thành'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
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

