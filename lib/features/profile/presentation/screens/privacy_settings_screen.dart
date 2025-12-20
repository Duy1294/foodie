import 'package:flutter/material.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/constants/colors.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _shareLocation = true;
  bool _shareProfile = true;
  bool _analytics = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final settings = await _settingsService.getPrivacySettings();
    setState(() {
      _shareLocation = settings['shareLocation'] ?? true;
      _shareProfile = settings['shareProfile'] ?? true;
      _analytics = settings['analytics'] ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    await _settingsService.setPrivacySetting(key, value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật cài đặt'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quyền riêng tư'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Share Location
                SwitchListTile(
                  title: const Text('Chia sẻ vị trí'),
                  subtitle: const Text('Cho phép ứng dụng sử dụng vị trí của bạn để tìm nhà hàng gần nhất'),
                  value: _shareLocation,
                  onChanged: (value) {
                    setState(() {
                      _shareLocation = value;
                    });
                    _updateSetting('share_location', value);
                  },
                  secondary: const Icon(Icons.location_on),
                ),
                const Divider(),
                // Share Profile
                SwitchListTile(
                  title: const Text('Chia sẻ thông tin cá nhân'),
                  subtitle: const Text('Cho phép nhà hàng xem thông tin cơ bản của bạn'),
                  value: _shareProfile,
                  onChanged: (value) {
                    setState(() {
                      _shareProfile = value;
                    });
                    _updateSetting('share_profile', value);
                  },
                  secondary: const Icon(Icons.person),
                ),
                const Divider(),
                // Analytics
                SwitchListTile(
                  title: const Text('Phân tích dữ liệu'),
                  subtitle: const Text('Cho phép thu thập dữ liệu để cải thiện trải nghiệm'),
                  value: _analytics,
                  onChanged: (value) {
                    setState(() {
                      _analytics = value;
                    });
                    _updateSetting('analytics', value);
                  },
                  secondary: const Icon(Icons.analytics),
                ),
                const Divider(),
                // Info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Về quyền riêng tư',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chúng tôi cam kết bảo vệ quyền riêng tư của bạn. Dữ liệu được mã hóa và chỉ sử dụng để cải thiện dịch vụ.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

