import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/order_item_data.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'qr_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedPaymentMethod = AppConstants.paymentCash;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      final orderService = OrderService();
      final authService = AuthService();

      if (authService.currentUser == null) {
        throw Exception('Vui lòng đăng nhập để đặt hàng');
      }

      if (cartService.restaurant == null) {
        throw Exception('Không tìm thấy thông tin nhà hàng');
      }

      final order = await orderService.createOrder(
        restaurantId: cartService.restaurant!.id,
        items: cartService.items.map((item) => OrderItemData(
          menuItemId: item.menuItem.id,
          quantity: item.quantity,
          unitPrice: item.menuItem.price,
          specialInstructions: item.specialInstructions,
        )).toList(),
        deliveryAddress: _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        deliveryFee: cartService.deliveryFee,
        customerNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      // Clear cart
      await cartService.clearCart();

      if (!mounted) return;

      // Handle QR payment for MoMo
      if (_selectedPaymentMethod == AppConstants.paymentMoMo) {
        // Navigate to QR payment screen
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QRPaymentScreen(
              orderNumber: order.orderNumber,
              amount: order.totalAmount,
              orderId: order.id,
            ),
          ),
        );

        // If payment was confirmed, result will be true
        if (result == true && mounted) {
          // Already navigated in payment screen
          return;
        }
      }

      // Show success dialog for cash/card payments or if QR screen was closed
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đặt hàng thành công!'),
          content: Text('Mã đơn hàng: ${order.orderNumber}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: const Text('Xem đơn hàng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Delivery address
            const Text(
              'Địa chỉ giao hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                hintText: 'Nhập địa chỉ giao hàng',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ giao hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Payment method
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._paymentMethods.map((method) => RadioListTile<String>(
              title: Text(_getPaymentMethodName(method)),
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value!);
              },
            )),
            const SizedBox(height: 24),
            // Note
            const Text(
              'Ghi chú (tùy chọn)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Ghi chú cho nhà hàng',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            // Order summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Tóm tắt đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tạm tính:'),
                        Text(_formatCurrency(cartService.subtotal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phí giao hàng:'),
                        Text(_formatCurrency(cartService.deliveryFee)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatCurrency(cartService.total),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Đặt hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _paymentMethods = [
    AppConstants.paymentCash,
    AppConstants.paymentMoMo,
  ];

  String _getPaymentMethodName(String method) {
    switch (method) {
      case AppConstants.paymentCash:
        return 'Tiền mặt';
      case AppConstants.paymentMoMo:
        return 'MoMo (QR Code)';
      default:
        return method;
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }
}


