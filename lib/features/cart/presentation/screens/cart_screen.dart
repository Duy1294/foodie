import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    return _CartItemCard(item: item);
                  },
                ),
              ),
              _CartSummary(cartService: cartService),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm món ăn vào giỏ hàng để đặt hàng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.menuItem.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.menuItem.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                      ),
                    )
                  : const Icon(Icons.fastfood),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.menuItem.price.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}đ',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (item.quantity > 1) {
                      cartService.updateItemQuantity(
                        item.menuItem.id,
                        item.quantity - 1,
                      );
                    } else {
                      cartService.removeItem(item.menuItem.id);
                    }
                  },
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    cartService.updateItemQuantity(
                      item.menuItem.id,
                      item.quantity + 1,
                    );
                  },
                ),
              ],
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                cartService.removeItem(item.menuItem.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartService cartService;

  const _CartSummary({required this.cartService});

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = cartService.restaurant;
    final minimumOrder = restaurant?.minimumOrder ?? 0;
    final canCheckout = cartService.subtotal >= minimumOrder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (restaurant != null && minimumOrder > 0) ...[
            if (!canCheckout)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Cần đặt tối thiểu ${_formatCurrency(minimumOrder)}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạm tính:',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                _formatCurrency(cartService.subtotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phí giao hàng:',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                _formatCurrency(cartService.deliveryFee),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(cartService.total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canCheckout
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Đặt hàng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
