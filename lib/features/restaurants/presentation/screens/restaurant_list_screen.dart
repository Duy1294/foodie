import 'package:flutter/material.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/restaurant_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String _error = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants({String? search}) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final restaurants = await _restaurantService.getRestaurants(
        search: search,
      );
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
        _searchQuery = search ?? '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) {
      _loadRestaurants();
    } else {
      _loadRestaurants(search: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _RestaurantSearchDelegate(
                  onSearch: _handleSearch,
                  restaurants: _restaurants,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhà hàng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadRestaurants();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: _handleSearch,
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadRestaurants();
                }
              },
            ),
          ),
          // Restaurant List
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
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRestaurants,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Không tìm thấy nhà hàng nào'
                                : 'Không có nhà hàng nào',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _loadRestaurants();
                              },
                              child: const Text('Xóa bộ lọc'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadRestaurants(search: _searchQuery.isEmpty ? null : _searchQuery),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _restaurants.length,
                        itemBuilder: (context, index) {
                          final restaurant = _restaurants[index];
                          return _RestaurantCard(
                            restaurant: restaurant,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RestaurantDetailScreen(
                                    restaurantId: restaurant.id,
                                  ),
                                ),
                              );
                            },
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

class _RestaurantSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;
  final List<Restaurant> restaurants;

  _RestaurantSearchDelegate({
    required this.onSearch,
    required this.restaurants,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Nhập tên nhà hàng để tìm kiếm'),
      );
    }

    final filtered = restaurants.where((r) {
      return r.name.toLowerCase().contains(query.toLowerCase()) ||
          (r.description != null && r.description!.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhà hàng nào',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final restaurant = filtered[index];
        return ListTile(
          leading: const Icon(Icons.restaurant),
          title: Text(restaurant.name),
          subtitle: restaurant.description != null
              ? Text(restaurant.description!)
              : null,
          onTap: () {
            close(context, restaurant.name);
            onSearch(restaurant.name);
          },
        );
      },
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: restaurant.coverImageUrl != null
                  ? Image.network(
                      restaurant.coverImageUrl!,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (restaurant.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      restaurant.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.rating,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.ratingAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${restaurant.ratingCount})',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Phí giao: ${_formatCurrency(restaurant.deliveryFee)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Tối thiểu: ${_formatCurrency(restaurant.minimumOrder)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

