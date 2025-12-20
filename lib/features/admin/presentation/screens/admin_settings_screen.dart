import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import 'admin_notification_settings_screen.dart';
import 'admin_security_settings_screen.dart';
import 'admin_payment_settings_screen.dart';
import 'admin_delivery_settings_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Cài đặt hệ thống',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Thông báo hệ thống',
            subtitle: 'Quản lý thông báo gửi đến users',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminNotificationSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.security,
            title: 'Bảo mật',
            subtitle: 'Cài đặt bảo mật hệ thống',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminSecuritySettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.payment,
            title: 'Thanh toán',
            subtitle: 'Cấu hình phương thức thanh toán',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminPaymentSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.local_shipping,
            title: 'Giao hàng',
            subtitle: 'Cấu hình phí giao hàng, khu vực',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDeliverySettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person,
            title: 'Thông tin cá nhân',
            subtitle: 'Chỉnh sửa thông tin admin',
            onTap: () {
              Navigator.pushNamed(context, '/profile/edit');
            },
          ),
          _SettingsTile(
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu đăng nhập',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Đăng xuất',
            subtitle: 'Đăng xuất khỏi tài khoản admin',
            onTap: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  await authService.logout();
                } catch (e) {
                  // Ignore logout API errors - logout locally anyway
                  print('Logout API error (ignored): $e');
                }

                if (context.mounted) {
                  // Close loading dialog
                  Navigator.pop(context);
                  
                  // Navigate directly to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

