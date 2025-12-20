import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/screens/order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminService _adminService = AdminService();
  
  List<Order> _orders = [];
  bool _isLoading = true;
  String _error = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _adminService.getOrders(
        page: _currentPage,
        status: _selectedStatus,
      );

      setState(() {
        _orders = result['orders'] as List<Order>;
        _total = result['total'] as int;
        _currentPage = result['page'] as int;
        _totalPages = result['pages'] as int;
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
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Trạng thái',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Tất cả')),
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
                  _selectedStatus = value;
                });
                _loadOrders(resetPage: true);
              },
            ),
          ),
          // Orders List
          Expanded(
            child: _isLoading
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
                              onPressed: () => _loadOrders(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? const Center(child: Text('Không có đơn hàng nào'))
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Tổng: $_total đơn hàng',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => _loadOrders(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _orders.length,
                                    itemBuilder: (context, index) {
                                      final order = _orders[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => OrderDetailScreen(orderId: order.id),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      order.orderNumber,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    _buildChip(
                                                      _getStatusLabel(order.status),
                                                      _getStatusColor(order.status),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text('💰 ${_formatCurrency(order.totalAmount)}'),
                                                const SizedBox(height: 4),
                                                Text('📦 ${order.items.length} món'),
                                                const SizedBox(height: 4),
                                                Text('📅 ${_formatDate(order.createdAt)}'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (_totalPages > 1)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 1
                                            ? () {
                                                setState(() {
                                                  _currentPage--;
                                                });
                                                _loadOrders();
                                              }
                                            : null,
                                      ),
                                      Text('Trang $_currentPage / $_totalPages'),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _currentPage < _totalPages
                                            ? () {
                                                setState(() {
                                                  _currentPage++;
                                                });
                                                _loadOrders();
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

