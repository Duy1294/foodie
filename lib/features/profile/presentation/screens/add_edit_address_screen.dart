import 'package:flutter/material.dart';
import '../../../../core/models/address.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({
    super.key,
    this.address,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _streetController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _recipientNameController = TextEditingController();
  
  bool _isDefault = false;
  bool _isLoading = false;
  final AddressService _addressService = AddressService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!.label;
      _fullAddressController.text = widget.address!.fullAddress;
      _streetController.text = widget.address!.street ?? '';
      _wardController.text = widget.address!.ward ?? '';
      _districtController.text = widget.address!.district ?? '';
      _cityController.text = widget.address!.city ?? '';
      _phoneController.text = widget.address!.phone ?? '';
      _recipientNameController.text = widget.address!.recipientName ?? '';
      _isDefault = widget.address!.isDefault;
    } else {
      // Set default values from user
      final user = _authService.currentUser;
      if (user != null) {
        _phoneController.text = user.phone ?? '';
        _recipientNameController.text = user.fullName;
      }
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullAddressController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _recipientNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.address != null) {
        // Update existing address
        await _addressService.updateAddress(
          addressId: widget.address!.id,
          label: _labelController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          street: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
          ward: _wardController.text.trim().isEmpty ? null : _wardController.text.trim(),
          district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          recipientName: _recipientNameController.text.trim().isEmpty ? null : _recipientNameController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        // Create new address
        await _addressService.createAddress(
          label: _labelController.text.trim(),
          fullAddress: _fullAddressController.text.trim(),
          street: _streetController.text.trim().isEmpty ? null : _streetController.text.trim(),
          ward: _wardController.text.trim().isEmpty ? null : _wardController.text.trim(),
          district: _districtController.text.trim().isEmpty ? null : _districtController.text.trim(),
          city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          recipientName: _recipientNameController.text.trim().isEmpty ? null : _recipientNameController.text.trim(),
          isDefault: _isDefault,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.address != null ? 'Cập nhật địa chỉ thành công' : 'Thêm địa chỉ thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address != null ? 'Sửa địa chỉ' : 'Thêm địa chỉ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Label
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Nhãn địa chỉ *',
                  hintText: 'VD: Nhà, Công ty, ...',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nhãn địa chỉ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Full Address
              TextFormField(
                controller: _fullAddressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ đầy đủ *',
                  hintText: 'VD: 123 Đường ABC, Phường XYZ, Quận 1, TP.HCM',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ đầy đủ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Street
              TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Số nhà, tên đường',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Ward
              TextFormField(
                controller: _wardController,
                decoration: InputDecoration(
                  labelText: 'Phường/Xã',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // District
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Quận/Huyện',
                  prefixIcon: const Icon(Icons.map_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Thành phố/Tỉnh',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Recipient Name
              TextFormField(
                controller: _recipientNameController,
                decoration: InputDecoration(
                  labelText: 'Tên người nhận',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              // Default Address Toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Đặt làm địa chỉ mặc định'),
                  subtitle: const Text('Sử dụng địa chỉ này cho các đơn hàng sau'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.address != null ? 'Cập nhật' : 'Thêm địa chỉ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

