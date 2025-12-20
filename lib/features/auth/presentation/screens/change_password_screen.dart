import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      await apiService.put(
        ApiConstants.changePassword,
        data: {
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
        },
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Đổi mật khẩu thất bại';
      if (e.toString().contains('Current password is incorrect')) {
        errorMessage = 'Mật khẩu hiện tại không đúng';
      } else if (e.toString().contains('at least 6 characters')) {
        errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Vui lòng nhập mật khẩu hiện tại và mật khẩu mới',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Change Password Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

