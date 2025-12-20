import 'package:flutter/material.dart';
import '../../../../core/services/shipper_service.dart';
import '../../../../core/constants/colors.dart';

class ShipperDeliveryAreasScreen extends StatefulWidget {
  const ShipperDeliveryAreasScreen({super.key});

  @override
  State<ShipperDeliveryAreasScreen> createState() => _ShipperDeliveryAreasScreenState();
}

class _ShipperDeliveryAreasScreenState extends State<ShipperDeliveryAreasScreen> {
  final ShipperService _shipperService = ShipperService();
  final _areaController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  List<String> _deliveryAreas = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await _shipperService.getProfile();
      final settings = profile['shipperSettings'] as Map<String, dynamic>?;

      if (settings != null && settings['deliveryAreas'] != null) {
        final areas = settings['deliveryAreas'] as List<dynamic>;
        setState(() {
          _deliveryAreas = areas.map((e) => e.toString()).toList();
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

  void _addArea() {
    final area = _areaController.text.trim();
    if (area.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên khu vực'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deliveryAreas.contains(area)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khu vực này đã tồn tại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _deliveryAreas.add(area);
      _areaController.clear();
    });
  }

  void _removeArea(String area) {
    setState(() {
      _deliveryAreas.remove(area);
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await _shipperService.updateDeliveryAreas(_deliveryAreas);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật khu vực giao hàng thành công'),
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
        title: const Text('Khu vực giao hàng'),
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
                            'Thêm khu vực',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _areaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tên khu vực',
                                    border: OutlineInputBorder(),
                                    hintText: 'VD: Quận 1, Quận 2',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _addArea,
                                icon: const Icon(Icons.add),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_deliveryAreas.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'Chưa có khu vực nào',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Danh sách khu vực',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_deliveryAreas.length} khu vực',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          ..._deliveryAreas.map((area) => ListTile(
                                title: Text(area),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeArea(area),
                                ),
                              )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text('Lưu thay đổi'),
                  ),
                ],
              ),
            ),
    );
  }
}

