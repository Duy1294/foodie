import 'package:flutter/material.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/constants/colors.dart';

class ShipperNotificationSettingsScreen extends StatefulWidget {
  const ShipperNotificationSettingsScreen({super.key});

  @override
  State<ShipperNotificationSettingsScreen> createState() => _ShipperNotificationSettingsScreenState();
}

class _ShipperNotificationSettingsScreenState extends State<ShipperNotificationSettingsScreen> {
  final ShipperService _shipperService = ShipperService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  bool _notificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _shipperService.getProfile();
      final settings = profile['shipperSettings'] as Map<String, dynamic>?;

      if (settings != null) {
        setState(() {
          _notificationEnabled = settings['notificationEnabled'] as bool? ?? true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _shipperService.updateNotificationSettings(_notificationEnabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật cài đặt thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo đơn hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông báo đơn hàng mới',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Nhận thông báo khi có đơn hàng mới',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notificationEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationEnabled = value;
                              });
                              _saveSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Khi bật thông báo, bạn sẽ nhận được thông báo khi có đơn hàng mới phù hợp với khu vực và giờ làm việc của bạn.',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

