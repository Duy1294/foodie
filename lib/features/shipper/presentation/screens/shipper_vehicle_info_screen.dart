import 'package:flutter/material.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/constants/colors.dart';

class ShipperVehicleInfoScreen extends StatefulWidget {
  const ShipperVehicleInfoScreen({super.key});

  @override
  State<ShipperVehicleInfoScreen> createState() => _ShipperVehicleInfoScreenState();
}

class _ShipperVehicleInfoScreenState extends State<ShipperVehicleInfoScreen> {
  final ShipperService _shipperService = ShipperService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vehicleBrandController = TextEditingController();
  final _vehicleModelController = TextEditingController();

  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _loadVehicleInfo();
  }

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _vehicleBrandController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _shipperService.getProfile();
      final vehicleInfo = profile['vehicleInfo'] as Map<String, dynamic>?;

      if (vehicleInfo != null) {
        setState(() {
          _selectedVehicleType = vehicleInfo['vehicleType'] as String?;
          _vehicleTypeController.text = _selectedVehicleType ?? '';
          _licensePlateController.text = vehicleInfo['licensePlate'] as String? ?? '';
          _vehicleBrandController.text = vehicleInfo['vehicleBrand'] as String? ?? '';
          _vehicleModelController.text = vehicleInfo['vehicleModel'] as String? ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveVehicleInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _shipperService.updateVehicleInfo(
        vehicleType: _selectedVehicleType,
        licensePlate: _licensePlateController.text.trim().isEmpty 
            ? null 
            : _licensePlateController.text.trim(),
        vehicleBrand: _vehicleBrandController.text.trim().isEmpty 
            ? null 
            : _vehicleBrandController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim().isEmpty 
            ? null 
            : _vehicleModelController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin phương tiện thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thông tin Phương tiện'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin Phương tiện'),
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
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Loại phương tiện *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'motorcycle', child: Text('Xe máy')),
                  DropdownMenuItem(value: 'bicycle', child: Text('Xe đạp')),
                  DropdownMenuItem(value: 'car', child: Text('Ô tô')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn loại phương tiện';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Biển số xe',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 30A-12345',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleBrandController,
                decoration: const InputDecoration(
                  labelText: 'Hãng xe',
                  border: OutlineInputBorder(),
                  hintText: 'VD: Honda, Yamaha',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                  hintText: 'VD: SH150i, Wave',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveVehicleInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : const Text('Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

