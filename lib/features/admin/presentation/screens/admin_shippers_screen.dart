import 'package:flutter/material.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/constants/colors.dart';

class AdminShippersScreen extends StatefulWidget {
  const AdminShippersScreen({super.key});

  @override
  State<AdminShippersScreen> createState() => _AdminShippersScreenState();
}

class _AdminShippersScreenState extends State<AdminShippersScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<User> _shippers = [];
  bool _isLoading = true;
  String _error = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  
  bool? _selectedIsActive;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadShippers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShippers({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _adminService.getShippers(
        page: _currentPage,
        isActive: _selectedIsActive,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _shippers = result['shippers'] as List<User>;
        _total = result['total'] as int;
        _currentPage = result['page'] as int;
        _totalPages = result['pages'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdateShipper(User shipper) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ShipperEditDialog(shipper: shipper),
    );

    if (result != null) {
      try {
        await _adminService.updateShipper(
          shipperId: shipper.id,
          fullName: result['fullName'] as String?,
          phone: result['phone'] as String?,
          isActive: result['isActive'] as bool?,
          isVerified: result['isVerified'] as bool?,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật shipper thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadShippers();
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
        title: const Text('Quản lý Shippers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _loadShippers(resetPage: true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    _searchQuery = value;
                    _loadShippers(resetPage: true);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool>(
                  value: _selectedIsActive,
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tất cả')),
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedIsActive = value;
                    });
                    _loadShippers(resetPage: true);
                  },
                ),
              ],
            ),
          ),
          // Shippers List
          Expanded(
            child: _isLoading
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
                              onPressed: () => _loadShippers(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _shippers.isEmpty
                        ? const Center(child: Text('Không có shipper nào'))
                        : Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Tổng: $_total shippers',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => _loadShippers(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _shippers.length,
                                    itemBuilder: (context, index) {
                                      final shipper = _shippers[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            child: Icon(Icons.delivery_dining, color: Colors.white),
                                          ),
                                          title: Text(
                                            shipper.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(shipper.email),
                                              if (shipper.phone != null) Text('📞 ${shipper.phone}'),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  _buildChip(
                                                    shipper.isActive ? 'Active' : 'Inactive',
                                                    shipper.isActive ? Colors.green : Colors.red,
                                                  ),
                                                  if (shipper.isVerified) ...[
                                                    const SizedBox(width: 8),
                                                    _buildChip('Verified', Colors.blue),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _handleUpdateShipper(shipper),
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (_totalPages > 1)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: _currentPage > 1
                                            ? () {
                                                setState(() {
                                                  _currentPage--;
                                                });
                                                _loadShippers();
                                              }
                                            : null,
                                      ),
                                      Text('Trang $_currentPage / $_totalPages'),
                                      IconButton(
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: _currentPage < _totalPages
                                            ? () {
                                                setState(() {
                                                  _currentPage++;
                                                });
                                                _loadShippers();
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ShipperEditDialog extends StatefulWidget {
  final User shipper;

  const _ShipperEditDialog({required this.shipper});

  @override
  State<_ShipperEditDialog> createState() => _ShipperEditDialogState();
}

class _ShipperEditDialogState extends State<_ShipperEditDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late bool _isActive;
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.shipper.fullName);
    _phoneController = TextEditingController(text: widget.shipper.phone ?? '');
    _isActive = widget.shipper.isActive;
    _isVerified = widget.shipper.isVerified;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa Shipper'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Verified'),
              value: _isVerified,
              onChanged: (value) {
                setState(() {
                  _isVerified = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'fullName': _fullNameController.text.trim(),
              'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
              'isActive': _isActive,
              'isVerified': _isVerified,
            });
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

