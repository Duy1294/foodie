import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'restaurant_menu_management_screen.dart';
import 'restaurant_info_screen.dart';
import 'restaurant_delivery_settings_screen.dart';
import 'restaurant_opening_hours_screen.dart';

class RestaurantSettingsScreen extends StatelessWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Nhà hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Quản lý Nhà hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.store,
            title: 'Thông tin Nhà hàng',
            subtitle: 'Chỉnh sửa thông tin, địa chỉ, giờ mở cửa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantInfoScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.restaurant_menu,
            title: 'Quản lý Menu',
            subtitle: 'Thêm, sửa, xóa món ăn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantMenuManagementScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.local_shipping,
            title: 'Cài đặt Giao hàng',
            subtitle: 'Phí giao hàng, đơn tối thiểu, khu vực',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantDeliverySettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.schedule,
            title: 'Giờ mở cửa',
            subtitle: 'Thiết lập giờ mở/đóng cửa',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantOpeningHoursScreen(),
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
            subtitle: 'Chỉnh sửa thông tin chủ nhà hàng',
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
            subtitle: 'Đăng xuất khỏi tài khoản',
            onTap: () async {
              final bool confirm = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Xác nhận đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              ) ?? false;

              if (confirm) {
                // Show loading indicator
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                }

                try {
                  await authService.logout();
                } catch (e) {
                  // Ignore logout API errors - logout locally anyway
                  print('Logout API error (ignored): $e');
                }

                if (context.mounted) {
                  Navigator.of(context).pop(); // Dismiss loading dialog
                  Navigator.pushAndRemoveUntil(
                    context,
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

