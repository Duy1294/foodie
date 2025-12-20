import 'package:flutter/material.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';

class RestaurantDeliverySettingsScreen extends StatefulWidget {
  const RestaurantDeliverySettingsScreen({super.key});

  @override
  State<RestaurantDeliverySettingsScreen> createState() => _RestaurantDeliverySettingsScreenState();
}

class _RestaurantDeliverySettingsScreenState extends State<RestaurantDeliverySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final RestaurantService _restaurantService = RestaurantService();

  Restaurant? _restaurant;
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';

  late TextEditingController _deliveryFeeController;
  late TextEditingController _minimumOrderController;

  @override
  void initState() {
    super.initState();
    _deliveryFeeController = TextEditingController();
    _minimumOrderController = TextEditingController();
    _loadRestaurant();
  }

  @override
  void dispose() {
    _deliveryFeeController.dispose();
    _minimumOrderController.dispose();
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
        _deliveryFeeController.text = restaurant.deliveryFee.toStringAsFixed(0);
        _minimumOrderController.text = restaurant.minimumOrder.toStringAsFixed(0);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || _restaurant == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final deliveryFee = double.tryParse(_deliveryFeeController.text.replaceAll(',', '').replaceAll('.', ''));
      final minimumOrder = double.tryParse(_minimumOrderController.text.replaceAll(',', '').replaceAll('.', ''));

      if (deliveryFee == null || deliveryFee < 0) {
        throw Exception('Phí giao hàng không hợp lệ');
      }
      if (minimumOrder == null || minimumOrder < 0) {
        throw Exception('Đơn tối thiểu không hợp lệ');
      }

      await _restaurantService.updateDeliverySettings(
        _restaurant!.id,
        deliveryFee: deliveryFee,
        minimumOrder: minimumOrder,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật cài đặt giao hàng'),
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
        title: const Text('Cài đặt Giao hàng'),
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
                          controller: _deliveryFeeController,
                          decoration: const InputDecoration(
                            labelText: 'Phí giao hàng (₫) *',
                            hintText: 'Ví dụ: 15000',
                            border: OutlineInputBorder(),
                            helperText: 'Phí giao hàng tối thiểu cho mỗi đơn hàng',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập phí giao hàng';
                            }
                            final fee = double.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
                            if (fee == null || fee < 0) {
                              return 'Phí giao hàng phải là số dương';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _minimumOrderController,
                          decoration: const InputDecoration(
                            labelText: 'Đơn tối thiểu (₫) *',
                            hintText: 'Ví dụ: 50000',
                            border: OutlineInputBorder(),
                            helperText: 'Giá trị đơn hàng tối thiểu để được giao hàng',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập đơn tối thiểu';
                            }
                            final min = double.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
                            if (min == null || min < 0) {
                              return 'Đơn tối thiểu phải là số dương';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveSettings,
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
                                    'Lưu cài đặt',
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

