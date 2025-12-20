import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/constants/colors.dart';

class ShipperLocationScreen extends StatefulWidget {
  const ShipperLocationScreen({super.key});

  @override
  State<ShipperLocationScreen> createState() => _ShipperLocationScreenState();
}

class _ShipperLocationScreenState extends State<ShipperLocationScreen> {
  final ShipperService _shipperService = ShipperService();
  
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _error;
  double? _currentLatitude;
  double? _currentLongitude;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _shipperService.getProfile();
      final location = profile['currentLocation'] as Map<String, dynamic>?;

      if (location != null) {
        setState(() {
          _currentLatitude = (location['latitude'] as num?)?.toDouble();
          _currentLongitude = (location['longitude'] as num?)?.toDouble();
          if (location['lastUpdated'] != null) {
            _lastUpdated = DateTime.parse(location['lastUpdated']);
          }
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isUpdating = true;
      _error = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Dịch vụ định vị chưa được bật. Vui lòng bật GPS.';
          _isUpdating = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Quyền truy cập vị trí bị từ chối.';
            _isUpdating = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.';
          _isUpdating = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update location on server
      await _shipperService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _lastUpdated = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật vị trí thành công'),
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
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vị trí hiện tại'),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vị trí hiện tại',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_currentLatitude != null && _currentLongitude != null) ...[
                            _InfoRow(
                              label: 'Vĩ độ',
                              value: _currentLatitude!.toStringAsFixed(6),
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Kinh độ',
                              value: _currentLongitude!.toStringAsFixed(6),
                            ),
                            if (_lastUpdated != null) ...[
                              const SizedBox(height: 8),
                              _InfoRow(
                                label: 'Cập nhật lúc',
                                value: '${_lastUpdated!.day}/${_lastUpdated!.month}/${_lastUpdated!.year} ${_lastUpdated!.hour}:${_lastUpdated!.minute.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ] else
                            const Text(
                              'Chưa có vị trí',
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _getCurrentLocation,
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(_isUpdating ? 'Đang cập nhật...' : 'Cập nhật vị trí'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                            'Lưu ý',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Vị trí của bạn sẽ được cập nhật khi bạn nhấn nút "Cập nhật vị trí"\n'
                            '• Đảm bảo GPS đã được bật\n'
                            '• Ứng dụng cần quyền truy cập vị trí để hoạt động',
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

