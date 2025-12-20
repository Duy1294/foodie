import 'package:flutter/material.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/order.dart';
import '../../../../core/constants/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  Order? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await _orderService.getOrderById(widget.orderId);
      setState(() {
        _order = order;
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
        title: const Text('Chi tiết đơn hàng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(child: Text('Không tìm thấy đơn hàng'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Đơn #${_order!.orderNumber}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(_order!.status)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _order!.statusText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(_order!.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Đặt lúc: ${_formatDate(_order!.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Items
                          const Text(
                            'Món đã đặt',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._order!.items.map((item) => Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    item.menuItem?.name ?? 'Món đã xóa',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Số lượng: ${item.quantity}'),
                                      Text(
                                        '${_formatCurrency(item.unitPrice)} x ${item.quantity} = ${_formatCurrency(item.subtotal)}',
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    _formatCurrency(item.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                          // Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _SummaryRow(
                                    label: 'Tạm tính',
                                    value: _formatCurrency(_order!.subtotal),
                                  ),
                                  _SummaryRow(
                                    label: 'Phí giao hàng',
                                    value: _formatCurrency(_order!.deliveryFee),
                                  ),
                                  if (_order!.discountAmount > 0)
                                    _SummaryRow(
                                      label: 'Giảm giá',
                                      value: '-${_formatCurrency(_order!.discountAmount)}',
                                      valueColor: Colors.green,
                                    ),
                                  const Divider(),
                                  _SummaryRow(
                                    label: 'Tổng cộng',
                                    value: _formatCurrency(_order!.totalAmount),
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Delivery info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông tin giao hàng',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_order!.deliveryAddress),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thanh toán: ${_getPaymentMethodName(_order!.paymentMethod)}',
                                  ),
                                  if (_order!.customerNote != null) ...[
                                    const SizedBox(height: 8),
                                    Text('Ghi chú: ${_order!.customerNote}'),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          // Action buttons for customer
                          if (_order!.status == OrderStatus.pending) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _cancelOrder,
                                icon: const Icon(Icons.cancel),
                                label: const Text('Hủy đơn hàng'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _orderService.cancelOrder(_order!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrder(); // Reload order to update status
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.ready:
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.card:
        return 'Thẻ tín dụng/Ghi nợ';
      case PaymentMethod.momo:
        return 'MoMo';
      case PaymentMethod.zalopay:
        return 'ZaloPay';
      case PaymentMethod.wallet:
        return 'Ví điện tử';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isTotal ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }
}

