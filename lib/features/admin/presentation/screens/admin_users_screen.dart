import 'package:flutter/material.dart';
import '../../../../core/models/user.dart';
import '../../../../core/services/admin_service.dart';
import '../../../../core/constants/colors.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<User> _users = [];
  bool _isLoading = true;
  String _error = '';
  
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  
  String? _selectedRole;
  bool? _selectedIsActive;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await _adminService.getUsers(
        page: _currentPage,
        role: _selectedRole,
        isActive: _selectedIsActive,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _users = result['users'] as List<User>;
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

  Future<void> _handleUpdateUser(User user) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UserEditDialog(user: user),
    );

    if (result != null) {
      try {
        await _adminService.updateUser(
          userId: user.id,
          fullName: result['fullName'] as String?,
          phone: result['phone'] as String?,
          role: result['role'] as String?,
          isActive: result['isActive'] as bool?,
          isVerified: result['isVerified'] as bool?,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật user thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
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

  Future<void> _handleDeleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa User'),
        content: Text('Bạn có chắc chắn muốn xóa user "${user.fullName}"?'),
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
        await _adminService.deleteUser(user.id);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa user thành công'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
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
        title: const Text('Quản lý Users'),
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
                // Search
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
                              _loadUsers(resetPage: true);
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
                    _loadUsers(resetPage: true);
                  },
                ),
                const SizedBox(height: 12),
                // Role and Status filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(value: 'customer', child: Text('Customer')),
                          DropdownMenuItem(value: 'restaurant_owner', child: Text('Restaurant Owner')),
                          DropdownMenuItem(value: 'driver', child: Text('Driver')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                          _loadUsers(resetPage: true);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
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
                          _loadUsers(resetPage: true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users List
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
                              onPressed: () => _loadUsers(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(child: Text('Không có user nào'))
                        : Column(
                            children: [
                              // Total count
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Tổng: $_total users',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // List
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => _loadUsers(),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _users.length,
                                    itemBuilder: (context, index) {
                                      final user = _users[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: _getRoleColor(user.role),
                                            child: Text(
                                              user.fullName[0].toUpperCase(),
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          title: Text(
                                            user.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(user.email),
                                              if (user.phone != null) Text('📞 ${user.phone}'),
                                              Row(
                                                children: [
                                                  _buildChip(
                                                    _getRoleLabel(user.role),
                                                    _getRoleColor(user.role),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _buildChip(
                                                    user.isActive ? 'Active' : 'Inactive',
                                                    user.isActive ? Colors.green : Colors.red,
                                                  ),
                                                  if (user.isVerified) ...[
                                                    const SizedBox(width: 8),
                                                    _buildChip('Verified', Colors.blue),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Sửa'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
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
                                                _handleUpdateUser(user);
                                              } else if (value == 'delete') {
                                                _handleDeleteUser(user);
                                              }
                                            },
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Pagination
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
                                                _loadUsers();
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
                                                _loadUsers();
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.purple;
      case UserRole.restaurantOwner:
        return Colors.orange;
      case UserRole.driver:
        return Colors.blue;
      case UserRole.customer:
        return Colors.green;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.restaurantOwner:
        return 'Owner';
      case UserRole.driver:
        return 'Driver';
      case UserRole.customer:
        return 'Customer';
    }
  }
}

class _UserEditDialog extends StatefulWidget {
  final User user;

  const _UserEditDialog({required this.user});

  @override
  State<_UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<_UserEditDialog> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late String _selectedRole;
  late bool _isActive;
  late bool _isVerified;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    // Convert UserRole enum to string for backend
    _selectedRole = _roleToString(widget.user.role);
    _isActive = widget.user.isActive;
    _isVerified = widget.user.isVerified;
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'customer';
      case UserRole.restaurantOwner:
        return 'restaurant_owner';
      case UserRole.driver:
        return 'driver';
      case UserRole.admin:
        return 'admin';
    }
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
      title: const Text('Chỉnh sửa User'),
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
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'customer', child: Text('Customer')),
                DropdownMenuItem(value: 'restaurant_owner', child: Text('Restaurant Owner')),
                DropdownMenuItem(value: 'driver', child: Text('Driver')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
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
              'role': _selectedRole,
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

