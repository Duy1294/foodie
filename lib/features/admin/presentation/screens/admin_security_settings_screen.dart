import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class AdminSecuritySettingsScreen extends StatefulWidget {
  const AdminSecuritySettingsScreen({super.key});

  @override
  State<AdminSecuritySettingsScreen> createState() => _AdminSecuritySettingsScreenState();
}

class _AdminSecuritySettingsScreenState extends State<AdminSecuritySettingsScreen> {
  bool _requireStrongPassword = true;
  bool _enable2FA = false;
  int _sessionTimeout = 30; // minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảo mật hệ thống'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Yêu cầu mật khẩu mạnh'),
              subtitle: const Text('Mật khẩu phải có ít nhất 8 ký tự, chữ hoa, số'),
              value: _requireStrongPassword,
              onChanged: (value) {
                setState(() {
                  _requireStrongPassword = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Xác thực 2 yếu tố (2FA)'),
              subtitle: const Text('Yêu cầu xác thực 2 yếu tố cho admin'),
              value: _enable2FA,
              onChanged: (value) {
                setState(() {
                  _enable2FA = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Thời gian hết hạn phiên đăng nhập'),
              subtitle: Text('$_sessionTimeout phút'),
              trailing: DropdownButton<int>(
                value: _sessionTimeout,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 phút')),
                  DropdownMenuItem(value: 30, child: Text('30 phút')),
                  DropdownMenuItem(value: 60, child: Text('1 giờ')),
                  DropdownMenuItem(value: 120, child: Text('2 giờ')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sessionTimeout = value;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu cài đặt bảo mật'),
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

