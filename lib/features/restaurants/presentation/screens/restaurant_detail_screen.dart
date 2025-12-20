import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/cart_service.dart';
import '../../../../core/services/restaurant_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  Restaurant? _restaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load restaurant and menu in parallel
      final results = await Future.wait([
        _restaurantService.getRestaurantById(widget.restaurantId),
        _restaurantService.getRestaurantMenu(widget.restaurantId),
      ]);

      setState(() {
        _restaurant = results[0] as Restaurant;
        _menuItems = results[1] as List<MenuItem>;
        _isLoading = false;
      });

      // Set restaurant in cart service
      if (_restaurant != null) {
        final cartService = Provider.of<CartService>(context, listen: false);
        await cartService.setRestaurant(_restaurant!);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết nhà hàng')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết nhà hàng')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_restaurant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết nhà hàng')),
        body: const Center(child: Text('Không tìm thấy nhà hàng')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_restaurant!.name),
              background: Container(
                color: Colors.grey[300],
                child: _restaurant!.coverImageUrl != null
                    ? Image.network(
                        _restaurant!.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating and info
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _restaurant!.ratingAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_restaurant!.ratingCount} đánh giá)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _restaurant!.address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (_restaurant!.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _restaurant!.phone!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Delivery info
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.delivery_dining,
                        label: 'Phí giao: ${_formatCurrency(_restaurant!.deliveryFee)}',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.shopping_bag,
                        label: 'Tối thiểu: ${_formatCurrency(_restaurant!.minimumOrder)}',
                      ),
                    ],
                  ),
                  if (_restaurant!.description != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _restaurant!.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Menu section
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Menu items
                  ..._menuItems.map((item) => _MenuItemCard(
                    item: item,
                    restaurant: _restaurant!,
                    restaurantId: widget.restaurantId,
                  )),
                ],
              ),
            ),
          ),
        ],
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final Restaurant restaurant;
  final String restaurantId;

  const _MenuItemCard({
    required this.item,
    required this.restaurant,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                  ),
                )
              : const Icon(Icons.fastfood),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null) ...[
              const SizedBox(height: 4),
              Text(
                item.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${item.price.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}đ',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        trailing: item.isPopular
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Phổ biến',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              )
            : null,
        onTap: () async {
          // Add to cart
          final cartService = Provider.of<CartService>(context, listen: false);
          
          // Set restaurant if not set or different restaurant
          if (cartService.restaurant?.id != restaurantId) {
            await cartService.setRestaurant(restaurant);
          }
          
          await cartService.addItem(item);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm ${item.name} vào giỏ hàng'),
              ),
            );
          }
        },
      ),
    );
  }
}

