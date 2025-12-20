import 'package:flutter/material.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/constants/colors.dart';

class AdminRestaurantsScreen extends StatefulWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  State<AdminRestaurantsScreen> createState() => _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends State<AdminRestaurantsScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String _error = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  
  bool? _selectedIsActive;
  bool? _selectedIsVerified;
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

  Future<void> _loadRestaurants({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _adminService.getRestaurants(
        page: _currentPage,
        isActive: _selectedIsActive,
        isVerified: _selectedIsVerified,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _restaurants = result['restaurants'] as List<Restaurant>;
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

  Future<void> _handleUpdateRestaurant(Restaurant restaurant) async {
    final result = await showDialog<Map<String, bool>>(
      context: context,
      builder: (context) => _RestaurantEditDialog(restaurant: restaurant),
    );

    if (result != null) {
      try {
        await _adminService.updateRestaurant(
          restaurantId: restaurant.id,
          isActive: result['isActive'],
          isVerified: result['isVerified'],
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật nhà hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRestaurants();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteRestaurant(Restaurant restaurant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Nhà hàng'),
        content: Text('Bạn có chắc chắn muốn xóa nhà hàng "${restaurant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _adminService.deleteRestaurant(restaurant.id);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa nhà hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRestaurants();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Nhà hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, địa chỉ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _loadRestaurants(resetPage: true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    _searchQuery = value;
                    _loadRestaurants(resetPage: true);
                  },
                ),
                const SizedBox(height: 12),
                // Status filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        value: _selectedIsActive,
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
                          DropdownMenuItem(value: true, child: Text('Active')),
                          DropdownMenuItem(value: false, child: Text('Inactive')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedIsActive = value;
                          });
                          _loadRestaurants(resetPage: true);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        value: _selectedIsVerified,
                        decoration: InputDecoration(
                          labelText: 'Verified',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(value: true, child: Text('Verified')),
                          DropdownMenuItem(value: false, child: Text('Not Verified')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedIsVerified = value;
                          });
                          _loadRestaurants(resetPage: true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Restaurants List
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
                              onPressed: () => _loadRestaurants(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _restaurants.isEmpty
                        ? const Center(child: Text('Không có nhà hàng nào'))
                        : Column(
                            children: [
                              // Total count
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Tổng: $_total nhà hàng',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // List
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => _loadRestaurants(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _restaurants.length,
                                    itemBuilder: (context, index) {
                                      final restaurant = _restaurants[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: ListTile(
                                          leading: restaurant.logoUrl != null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(restaurant.logoUrl!),
                                                )
                                              : const CircleAvatar(
                                                  child: Icon(Icons.restaurant),
                                                ),
                                          title: Text(
                                            restaurant.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (restaurant.description != null)
                                                Text(restaurant.description!),
                                              Text('📍 ${restaurant.address}'),
                                              if (restaurant.phone != null)
                                                Text('📞 ${restaurant.phone}'),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  _buildChip(
                                                    restaurant.isActive ? 'Active' : 'Inactive',
                                                    restaurant.isActive ? Colors.green : Colors.red,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildChip(
                                                    restaurant.isVerified ? 'Verified' : 'Not Verified',
                                                    restaurant.isVerified ? Colors.blue : Colors.grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildChip(
                                                    '⭐ ${restaurant.ratingAverage.toStringAsFixed(1)}',
                                                    Colors.amber,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Sửa'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Xóa', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _handleUpdateRestaurant(restaurant);
                                              } else if (value == 'delete') {
                                                _handleDeleteRestaurant(restaurant);
                                              }
                                            },
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Pagination
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
                                                _loadRestaurants();
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
                                                _loadRestaurants();
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
}

class _RestaurantEditDialog extends StatefulWidget {
  final Restaurant restaurant;

  const _RestaurantEditDialog({required this.restaurant});

  @override
  State<_RestaurantEditDialog> createState() => _RestaurantEditDialogState();
}

class _RestaurantEditDialogState extends State<_RestaurantEditDialog> {
  late bool _isActive;
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _isActive = widget.restaurant.isActive;
    _isVerified = widget.restaurant.isVerified;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa Nhà hàng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.restaurant.name}'),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Active'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Verified'),
            value: _isVerified,
            onChanged: (value) {
              setState(() {
                _isVerified = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'isActive': _isActive,
              'isVerified': _isVerified,
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

