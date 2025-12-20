import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _apiService = ApiService();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.put(
        ApiConstants.updateProfile,
        data: {
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        },
      );

      // Reload user data
      await _authService.init();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa thông tin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Email (read-only)
              TextFormField(
                initialValue: user?.email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  enabled: false,
                ),
              ),
              const SizedBox(height: 16),
              // Full name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu thông tin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

