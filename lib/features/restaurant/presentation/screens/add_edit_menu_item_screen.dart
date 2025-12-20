import 'package:flutter/material.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/validators.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final String restaurantId;
  final MenuItem? menuItem;

  const AddEditMenuItemScreen({
    super.key,
    required this.restaurantId,
    this.menuItem,
  });

  @override
  State<AddEditMenuItemScreen> createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final RestaurantService _restaurantService = RestaurantService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  bool _isAvailable = true;
  bool _isPopular = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _descriptionController = TextEditingController(text: widget.menuItem?.description ?? '');
    _priceController = TextEditingController(
      text: widget.menuItem?.price.toStringAsFixed(0) ?? '',
    );
    _imageUrlController = TextEditingController(text: widget.menuItem?.imageUrl ?? '');
    _isAvailable = widget.menuItem?.isAvailable ?? true;
    _isPopular = widget.menuItem?.isPopular ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final price = double.tryParse(_priceController.text.replaceAll(',', '').replaceAll('.', ''));
      if (price == null || price <= 0) {
        throw Exception('Giá không hợp lệ');
      }

      final menuItem = MenuItem(
        id: widget.menuItem?.id ?? '',
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        isAvailable: _isAvailable,
        isPopular: _isPopular,
        createdAt: widget.menuItem?.createdAt ?? DateTime.now(),
      );

      if (widget.menuItem == null) {
        await _restaurantService.addMenuItem(widget.restaurantId, menuItem);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm món ăn'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _restaurantService.updateMenuItem(
          widget.restaurantId,
          widget.menuItem!.id,
          menuItem,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật món ăn'),
            backgroundColor: Colors.green,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem == null ? 'Thêm món ăn' : 'Chỉnh sửa món ăn'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên món ăn *',
                        hintText: 'Ví dụ: Phở Bò',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Mô tả về món ăn',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Giá (₫) *',
                        hintText: 'Ví dụ: 50000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập giá';
                        }
                        final price = double.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
                        if (price == null || price <= 0) {
                          return 'Giá phải là số dương';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Link ảnh',
                        hintText: 'https://example.com/image.jpg',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Có sẵn'),
                      subtitle: const Text('Món ăn có sẵn để đặt hàng'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    SwitchListTile(
                      title: const Text('Món phổ biến'),
                      subtitle: const Text('Hiển thị món này là phổ biến'),
                      value: _isPopular,
                      onChanged: (value) {
                        setState(() {
                          _isPopular = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMenuItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.menuItem == null ? 'Thêm món ăn' : 'Cập nhật món ăn',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

