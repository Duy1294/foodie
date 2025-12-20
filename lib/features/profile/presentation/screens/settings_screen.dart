import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/constants/app_constants.dart';
import 'language_selection_screen.dart';
import 'theme_selection_screen.dart';
import 'privacy_settings_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  String _currentLanguage = 'vi';
  bool _notificationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await _settingsService.getLanguage();
    final notifications = await _settingsService.getNotificationEnabled();
    setState(() {
      _currentLanguage = language;
      _notificationEnabled = notifications;
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationEnabled = value;
    });
    await _settingsService.setNotificationEnabled(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Đã bật thông báo' : 'Đã tắt thông báo'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'Tiếng Việt';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Language
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Ngôn ngữ'),
                  subtitle: Text(_getLanguageName(_currentLanguage)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectionScreen(),
                      ),
                    ).then((_) => _loadSettings());
                  },
                ),
                const Divider(),
                // Theme
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Giao diện'),
                  subtitle: Text(themeProvider.themeModeText),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ThemeSelectionScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                // Notifications
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Thông báo'),
                  subtitle: const Text('Bật/tắt thông báo đơn hàng và khuyến mãi'),
                  trailing: Switch(
                    value: _notificationEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
                const Divider(),
                // Privacy
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Quyền riêng tư'),
                  subtitle: const Text('Quản lý quyền riêng tư và dữ liệu'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                // About
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Về ứng dụng'),
                  subtitle: Text('Phiên bản ${AppConstants.appVersion}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: AppConstants.appVersion,
                      applicationIcon: const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: AppColors.primary,
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Ứng dụng đặt đồ ăn trực tuyến\n'
                            'Giúp bạn tìm và đặt món ăn yêu thích một cách dễ dàng.',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(),
                // Terms
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Điều khoản sử dụng'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.shield),
                  title: const Text('Chính sách bảo mật'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

