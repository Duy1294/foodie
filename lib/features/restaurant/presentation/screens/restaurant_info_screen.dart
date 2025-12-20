import 'package:flutter/material.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/validators.dart';

class RestaurantInfoScreen extends StatefulWidget {
  const RestaurantInfoScreen({super.key});

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final RestaurantService _restaurantService = RestaurantService();

  Restaurant? _restaurant;
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _logoUrlController;
  late TextEditingController _coverImageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _logoUrlController = TextEditingController();
    _coverImageUrlController = TextEditingController();
    _loadRestaurant();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _logoUrlController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurant() async {
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

      setState(() {
        _restaurant = restaurant;
        _nameController.text = restaurant.name;
        _descriptionController.text = restaurant.description ?? '';
        _addressController.text = restaurant.address;
        _phoneController.text = restaurant.phone ?? '';
        _emailController.text = restaurant.email ?? '';
        _logoUrlController.text = restaurant.logoUrl ?? '';
        _coverImageUrlController.text = restaurant.coverImageUrl ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate() || _restaurant == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedRestaurant = _restaurant!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty
            ? null
            : _logoUrlController.text.trim(),
        coverImageUrl: _coverImageUrlController.text.trim().isEmpty
            ? null
            : _coverImageUrlController.text.trim(),
      );

      await _restaurantService.updateRestaurant(_restaurant!.id, updatedRestaurant);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin nhà hàng'),
          backgroundColor: Colors.green,
        ),
      );
      _loadRestaurant();
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin Nhà hàng'),
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
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRestaurant,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
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
                            labelText: 'Tên nhà hàng *',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            hintText: 'Mô tả về nhà hàng',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Địa chỉ *',
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.required,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return Validators.email(value);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _logoUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Link logo',
                            hintText: 'https://example.com/logo.jpg',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _coverImageUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Link ảnh bìa',
                            hintText: 'https://example.com/cover.jpg',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveRestaurant,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Lưu thông tin',
                                    style: TextStyle(fontSize: 18),
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

