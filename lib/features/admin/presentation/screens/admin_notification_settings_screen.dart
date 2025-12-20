import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AdminNotificationSettingsScreen extends StatefulWidget {
  const AdminNotificationSettingsScreen({super.key});

  @override
  State<AdminNotificationSettingsScreen> createState() => _AdminNotificationSettingsScreenState();
}

class _AdminNotificationSettingsScreenState extends State<AdminNotificationSettingsScreen> {
  bool _orderNotifications = true;
  bool _promotionNotifications = true;
  bool _systemNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Thông báo đơn hàng'),
              subtitle: const Text('Gửi thông báo khi có đơn hàng mới'),
              value: _orderNotifications,
              onChanged: (value) {
                setState(() {
                  _orderNotifications = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Thông báo khuyến mãi'),
              subtitle: const Text('Gửi thông báo khuyến mãi đến users'),
              value: _promotionNotifications,
              onChanged: (value) {
                setState(() {
                  _promotionNotifications = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Thông báo hệ thống'),
              subtitle: const Text('Thông báo bảo trì, cập nhật hệ thống'),
              value: _systemNotifications,
              onChanged: (value) {
                setState(() {
                  _systemNotifications = value;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu cài đặt thông báo'),
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

