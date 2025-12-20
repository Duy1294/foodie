import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'shipper_vehicle_info_screen.dart';
import 'shipper_location_screen.dart';
import 'shipper_notification_settings_screen.dart';
import 'shipper_working_hours_screen.dart';
import 'shipper_delivery_areas_screen.dart';
import 'shipper_analytics_screen.dart';

class ShipperSettingsScreen extends StatelessWidget {
  const ShipperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt Shipper'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Thông tin Shipper',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.person,
            title: 'Thông tin cá nhân',
            subtitle: 'Chỉnh sửa thông tin shipper',
            onTap: () {
              Navigator.pushNamed(context, '/profile/edit');
            },
          ),
          _SettingsTile(
            icon: Icons.motorcycle,
            title: 'Phương tiện',
            subtitle: 'Thông tin xe, biển số',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperVehicleInfoScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.location_on,
            title: 'Vị trí hiện tại',
            subtitle: 'Cập nhật vị trí GPS',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperLocationScreen(),
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Cài đặt giao hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications,
            title: 'Thông báo đơn hàng',
            subtitle: 'Bật/tắt thông báo đơn hàng mới',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperNotificationSettingsScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.schedule,
            title: 'Giờ làm việc',
            subtitle: 'Thiết lập giờ nhận đơn hàng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperWorkingHoursScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.map,
            title: 'Khu vực giao hàng',
            subtitle: 'Chọn khu vực muốn nhận đơn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperDeliveryAreasScreen(),
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
          _SettingsTile(
            icon: Icons.analytics,
            title: 'Thống kê',
            subtitle: 'Xem thống kê thu nhập, đơn hàng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShipperAnalyticsScreen(),
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

