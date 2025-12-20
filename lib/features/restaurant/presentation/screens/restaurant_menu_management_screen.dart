import 'package:flutter/material.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';
import 'add_edit_menu_item_screen.dart';

class RestaurantMenuManagementScreen extends StatefulWidget {
  const RestaurantMenuManagementScreen({super.key});

  @override
  State<RestaurantMenuManagementScreen> createState() => _RestaurantMenuManagementScreenState();
}

class _RestaurantMenuManagementScreenState extends State<RestaurantMenuManagementScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final AuthService _authService = AuthService();
  
  Restaurant? _restaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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

      final menuItems = await _restaurantService.getRestaurantMenuForOwner(restaurant.id);

      setState(() {
        _restaurant = restaurant;
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Better error message handling
        if (e.toString().contains('404') || e.toString().contains('not found')) {
          _error = 'Không tìm thấy nhà hàng của bạn. Vui lòng liên hệ admin để được tạo nhà hàng.';
        } else {
          _error = 'Lỗi: ${e.toString()}';
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMenuItem(MenuItem menuItem) async {
    if (_restaurant == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa món "${menuItem.name}"?'),
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
        await _restaurantService.deleteMenuItem(_restaurant!.id, menuItem.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa món ăn'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
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
        title: const Text('Quản lý Menu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _restaurant != null
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditMenuItemScreen(
                          restaurantId: _restaurant!.id,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadData();
                    }
                  }
                : null,
          ),
        ],
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
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _menuItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có món ăn nào',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditMenuItemScreen(
                                    restaurantId: _restaurant!.id,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadData();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm món ăn đầu tiên'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final menuItem = _menuItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: menuItem.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        menuItem.imageUrl!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.restaurant),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.restaurant),
                                    ),
                              title: Text(
                                menuItem.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (menuItem.description != null)
                                    Text(
                                      menuItem.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${menuItem.price.toStringAsFixed(0)}₫',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (menuItem.isPopular)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Phổ biến',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: menuItem.isAvailable ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          menuItem.isAvailable ? 'Có sẵn' : 'Hết hàng',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
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
                                        Text('Chỉnh sửa'),
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
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditMenuItemScreen(
                                          restaurantId: _restaurant!.id,
                                          menuItem: menuItem,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadData();
                                    }
                                  } else if (value == 'delete') {
                                    _deleteMenuItem(menuItem);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

