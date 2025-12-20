import 'package:flutter/material.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/constants/colors.dart';

class ShipperWorkingHoursScreen extends StatefulWidget {
  const ShipperWorkingHoursScreen({super.key});

  @override
  State<ShipperWorkingHoursScreen> createState() => _ShipperWorkingHoursScreenState();
}

class _ShipperWorkingHoursScreenState extends State<ShipperWorkingHoursScreen> {
  final ShipperService _shipperService = ShipperService();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  final Map<String, Map<String, String>> _workingHours = {
    'monday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'tuesday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'wednesday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'thursday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'friday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'saturday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
    'sunday': {'start': '08:00', 'end': '18:00', 'enabled': 'true'},
  };

  final Map<String, String> _dayNames = {
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

      if (settings != null && settings['workingHours'] != null) {
        final hours = settings['workingHours'] as Map<String, dynamic>;
        setState(() {
          for (var day in _workingHours.keys) {
            if (hours[day] != null) {
              final dayHours = hours[day] as Map<String, dynamic>;
              _workingHours[day] = {
                'start': dayHours['start']?.toString() ?? '08:00',
                'end': dayHours['end']?.toString() ?? '18:00',
                'enabled': 'true',
              };
            }
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

  Future<void> _selectTime(BuildContext context, String day, String type) async {
    final currentTime = _workingHours[day]![type]!;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        _workingHours[day]![type] = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final hoursToSave = <String, Map<String, String>>{};
      for (var day in _workingHours.keys) {
        if (_workingHours[day]!['enabled'] == 'true') {
          hoursToSave[day] = {
            'start': _workingHours[day]!['start']!,
            'end': _workingHours[day]!['end']!,
          };
        }
      }

      await _shipperService.updateWorkingHours(hoursToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật giờ làm việc thành công'),
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
        title: const Text('Giờ làm việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
            ),
        ],
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
                  ..._workingHours.keys.map((day) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dayNames[day]!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Switch(
                                    value: _workingHours[day]!['enabled'] == 'true',
                                    onChanged: (value) {
                                      setState(() {
                                        _workingHours[day]!['enabled'] = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_workingHours[day]!['enabled'] == 'true') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectTime(context, day, 'start'),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Giờ bắt đầu'),
                                              Text(
                                                _workingHours[day]!['start']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectTime(context, day, 'end'),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Giờ kết thúc'),
                                              Text(
                                                _workingHours[day]!['end']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}

