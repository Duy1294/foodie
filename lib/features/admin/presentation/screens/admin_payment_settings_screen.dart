import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AdminPaymentSettingsScreen extends StatefulWidget {
  const AdminPaymentSettingsScreen({super.key});

  @override
  State<AdminPaymentSettingsScreen> createState() => _AdminPaymentSettingsScreenState();
}

class _AdminPaymentSettingsScreenState extends State<AdminPaymentSettingsScreen> {
  bool _cashEnabled = true;
  bool _momoEnabled = false;
  bool _zalopayEnabled = false;
  bool _vnpayEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Thanh toán'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Tiền mặt'),
              subtitle: const Text('Thanh toán khi nhận hàng'),
              value: _cashEnabled,
              onChanged: (value) {
                setState(() {
                  _cashEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('MoMo'),
              subtitle: const Text('Thanh toán qua ví MoMo'),
              value: _momoEnabled,
              onChanged: (value) {
                setState(() {
                  _momoEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('ZaloPay'),
              subtitle: const Text('Thanh toán qua ví ZaloPay'),
              value: _zalopayEnabled,
              onChanged: (value) {
                setState(() {
                  _zalopayEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('VNPay'),
              subtitle: const Text('Thanh toán qua VNPay'),
              value: _vnpayEnabled,
              onChanged: (value) {
                setState(() {
                  _vnpayEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu cài đặt thanh toán'),
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

