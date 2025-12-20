import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/user.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'address_management_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Role-specific dashboard
                  if (user.role == UserRole.admin ||
                      user.role == UserRole.restaurantOwner ||
                      user.role == UserRole.driver)
                    ListTile(
                      leading: Icon(
                        user.role == UserRole.admin
                            ? Icons.admin_panel_settings
                            : user.role == UserRole.restaurantOwner
                                ? Icons.store
                                : Icons.delivery_dining,
                      ),
                      title: Text(
                        user.role == UserRole.admin
                            ? 'Admin Dashboard'
                            : user.role == UserRole.restaurantOwner
                                ? 'Quản lý Nhà hàng'
                                : 'Shipper Dashboard',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (user.role == UserRole.admin) {
                          Navigator.pushNamed(context, '/admin/dashboard');
                        } else if (user.role == UserRole.restaurantOwner) {
                          Navigator.pushNamed(context, '/restaurant/dashboard');
                        } else if (user.role == UserRole.driver) {
                          Navigator.pushNamed(context, '/shipper/dashboard');
                        }
                      },
                    ),
                  if (user.role == UserRole.admin ||
                      user.role == UserRole.restaurantOwner ||
                      user.role == UserRole.driver)
                    const Divider(),
                  // Menu items
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Thông tin cá nhân'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Địa chỉ giao hàng'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddressManagementScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Thông báo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Cài đặt'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Route to role-specific settings
                      if (user.role == UserRole.admin) {
                        Navigator.pushNamed(context, '/admin/settings');
                      } else if (user.role == UserRole.restaurantOwner) {
                        Navigator.pushNamed(context, '/restaurant/settings');
                      } else if (user.role == UserRole.driver) {
                        Navigator.pushNamed(context, '/shipper/settings');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Trợ giúp'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text('Bạn có chắc muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await authService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.role.toString().split('.').last,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

