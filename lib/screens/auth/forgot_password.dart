import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ProfileColors.surface,
          title: const Text('Thành công', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Một liên kết khôi phục mật khẩu đã được gửi đến email của bạn.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Quay lại đăng nhập', style: TextStyle(color: ProfileColors.lime)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khôi phục mật khẩu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nhập email của bạn để nhận liên kết đặt lại mật khẩu.',
                  style: TextStyle(color: Colors.white60, fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ mail',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.25),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF2E3135), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white38, width: 1.5),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1C1E),
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF3A3F44), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Gửi yêu cầu',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
