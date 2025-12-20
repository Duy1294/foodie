import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AdminDeliverySettingsScreen extends StatefulWidget {
  const AdminDeliverySettingsScreen({super.key});

  @override
  State<AdminDeliverySettingsScreen> createState() => _AdminDeliverySettingsScreenState();
}

class _AdminDeliverySettingsScreenState extends State<AdminDeliverySettingsScreen> {
  final TextEditingController _baseFeeController = TextEditingController(text: '15000');
  final TextEditingController _perKmController = TextEditingController(text: '5000');
  final TextEditingController _maxDistanceController = TextEditingController(text: '10');

  @override
  void dispose() {
    _baseFeeController.dispose();
    _perKmController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Giao hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Phí giao hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _baseFeeController,
            decoration: const InputDecoration(
              labelText: 'Phí cơ bản (đ)',
              hintText: '15000',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _perKmController,
            decoration: const InputDecoration(
              labelText: 'Phí mỗi km (đ)',
              hintText: '5000',
              prefixIcon: Icon(Icons.straighten),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxDistanceController,
            decoration: const InputDecoration(
              labelText: 'Khoảng cách tối đa (km)',
              hintText: '10',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu cài đặt giao hàng'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Lưu cài đặt'),
          ),
        ],
      ),
    );
  }
}

