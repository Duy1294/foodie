import 'package:flutter/material.dart';
import '../../../../core/models/restaurant.dart';
import '../../../../core/services/restaurant_service.dart';
import '../../../../core/constants/colors.dart';

class RestaurantOpeningHoursScreen extends StatefulWidget {
  const RestaurantOpeningHoursScreen({super.key});

  @override
  State<RestaurantOpeningHoursScreen> createState() => _RestaurantOpeningHoursScreenState();
}

class _RestaurantOpeningHoursScreenState extends State<RestaurantOpeningHoursScreen> {
  final RestaurantService _restaurantService = RestaurantService();

  Restaurant? _restaurant;
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';

  final Map<String, Map<String, String>> _openingHours = {};
  final List<String> _days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
  final Map<String, String> _dayLabels = {
    'monday': 'Thứ 2',
    'tuesday': 'Thứ 3',
    'wednesday': 'Thứ 4',
    'thursday': 'Thứ 5',
    'friday': 'Thứ 6',
    'saturday': 'Thứ 7',
    'sunday': 'Chủ nhật',
  };

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final restaurant = await _restaurantService.getMyRestaurant();
      if (restaurant == null) {
        setState(() {
          _error = 'Không tìm thấy nhà hàng của bạn';
          _isLoading = false;
        });
        return;
      }

      // Load opening hours from restaurant
      final openingHours = restaurant.openingHours ?? {};
      
      setState(() {
        _restaurant = restaurant;
        for (var day in _days) {
          if (openingHours.containsKey(day) && openingHours[day] is Map) {
            final dayHours = openingHours[day] as Map<String, dynamic>;
            _openingHours[day] = {
              'open': dayHours['open']?.toString() ?? '09:00',
              'close': dayHours['close']?.toString() ?? '22:00',
            };
          } else {
            _openingHours[day] = {
              'open': '09:00',
              'close': '22:00',
            };
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveHours() async {
    if (_restaurant == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Convert to the format expected by backend
      final openingHoursMap = <String, Map<String, String>>{};
      for (var day in _days) {
        openingHoursMap[day] = {
          'open': _openingHours[day]!['open']!,
          'close': _openingHours[day]!['close']!,
        };
      }

      await _restaurantService.updateOpeningHours(_restaurant!.id, openingHoursMap);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật giờ mở cửa'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectTime(BuildContext context, String day, String type) async {
    final currentTime = _openingHours[day]![type]!;
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _openingHours[day]![type] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giờ mở cửa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRestaurant,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _days.length,
                        itemBuilder: (context, index) {
                          final day = _days[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(
                                _dayLabels[day]!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectTime(context, day, 'open'),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.access_time, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              _openingHours[day]!['open']!,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(' - '),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _selectTime(context, day, 'close'),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.access_time, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              _openingHours[day]!['close']!,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveHours,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Lưu giờ mở cửa',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

