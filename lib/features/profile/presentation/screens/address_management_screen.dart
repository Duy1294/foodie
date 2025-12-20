import 'package:flutter/material.dart';
import '../../../../core/models/address.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/constants/colors.dart';
import 'add_edit_address_screen.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  final AddressService _addressService = AddressService();
  List<Address> _addresses = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final addresses = await _addressService.getAddresses();
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(Address address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa địa chỉ'),
        content: Text('Bạn có chắc chắn muốn xóa địa chỉ "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _addressService.deleteAddress(address.id);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa địa chỉ thành công'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadAddresses();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ giao hàng'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditAddressScreen(),
                ),
              );
              if (result == true) {
                _loadAddresses();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAddresses,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có địa chỉ nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Thêm địa chỉ để giao hàng nhanh hơn',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditAddressScreen(),
                                ),
                              );
                              if (result == true) {
                                _loadAddresses();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm địa chỉ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAddresses,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: address.isDefault
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                child: Icon(
                                  address.isDefault
                                      ? Icons.home
                                      : Icons.location_on,
                                  color: address.isDefault
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      address.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (address.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Mặc định',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(address.fullAddress),
                                  if (address.phone != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '📞 ${address.phone}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  if (address.recipientName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '👤 ${address.recipientName}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Sửa'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Xóa', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditAddressScreen(
                                          address: address,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        _loadAddresses();
                                      }
                                    });
                                  } else if (value == 'delete') {
                                    _deleteAddress(address);
                                  }
                                },
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

