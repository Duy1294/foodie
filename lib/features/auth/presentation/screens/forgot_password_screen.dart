import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/api_constants.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        ApiConstants.forgotPassword,
        data: {
          'email': _emailController.text.trim(),
        },
      );

      if (!mounted) return;

      final data = response.data;
      String? resetToken;

      // In development, token might be in response
      if (data is Map && data.containsKey('resetToken')) {
        resetToken = data['resetToken'] as String?;
      }

      if (resetToken != null && resetToken.isNotEmpty) {
        // Development mode - show token and navigate to reset
        final token = resetToken; // Local variable to ensure non-null
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Token (Development)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Token đã được gửi. Trong development mode, token là:'),
                const SizedBox(height: 8),
                SelectableText(
                  token,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Bạn có muốn tiếp tục đặt lại mật khẩu?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResetPasswordScreen(token: token),
                    ),
                  );
                },
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        );
      } else {
        // Production mode - show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email đặt lại mật khẩu đã được gửi. Vui lòng kiểm tra hộp thư của bạn.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
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
        title: const Text('Quên mật khẩu'),
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
              const SizedBox(height: 32),
              const Icon(
                Icons.lock_reset,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập email của bạn để nhận link đặt lại mật khẩu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleForgotPassword,
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
                        'Gửi email đặt lại mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              
              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

