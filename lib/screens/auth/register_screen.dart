import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AppRoutes.dart';
import '../../theme/app_theme.dart';
import '../../viewmodel/authVM.dart';

enum ValidationReason {
  none,
  empty,
  notEqual,
  invalidEmail,
  tooShort,
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationReason reason;

  // Private constructor enforcing required fields
  const ValidationResult._({
    required this.isValid,
    required this.reason,
    this.errorMessage,
  });

  // Factory for successful validation
  factory ValidationResult.success() {
    return const ValidationResult._(
      isValid: true,
      reason: ValidationReason.none,
    );
  }

  // Factory for failed validation
  factory ValidationResult.failure(ValidationReason reason, String message) {
    return ValidationResult._(
      isValid: false,
      reason: reason,
      errorMessage: message,
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _validationError;

  ValidationResult _validateRegisterFields({
    required String name,
    required String email,
    required String password,
    required String confirmedPassword,
  }) {
    if (name.isEmpty) {
      return ValidationResult.failure(ValidationReason.empty, 'Họ và tên là bắt buộc.');
    }

    if (email.isEmpty) {
      return ValidationResult.failure(ValidationReason.empty, 'Email là bắt buộc.');
    }

    if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(email)) {
      return ValidationResult.failure(ValidationReason.invalidEmail, 'Email không hợp lệ.');
    }

    if (password.isEmpty) {
      return ValidationResult.failure(ValidationReason.empty, 'Mật khẩu là bắt buộc.');
    }

    if (password.length < 8) {
      return ValidationResult.failure(ValidationReason.tooShort, 'Mật khẩu phải có ít nhất 8 ký tự.');
    }

    if (confirmedPassword != password) {
      return ValidationResult.failure(ValidationReason.notEqual, 'Xác nhận mật khẩu không khớp.');
    }

    return ValidationResult.success();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmedPassword = _confirmPasswordController.text;

    final validation = _validateRegisterFields(
      name: name,
      email: email,
      password: password,
      confirmedPassword: confirmedPassword,
    );

    if (!validation.isValid) {
      setState(() => _validationError = validation.errorMessage);
      return;
    }

    setState(() => _validationError = null);

    final auth = context.read<AuthVM>();
    auth.clearError();

    final success = await auth.login(email, password);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // Main content container box
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        width: 3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 58,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(255, 18, 18, 18),
                                Color.fromARGB(255, 18, 19, 20),
                                Color(0xFF121314),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE2E8F0),
                                Color(0xFF94A3B8),
                                Color(0xFFCBD5E1),
                              ],
                            ).createShader(bounds),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'REGISTER',
                                  style: TextStyle(
                                    fontFamily: 'authfont',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          color: const Color(0xFF151617),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _nameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Họ và tên',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Mật khẩu',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Xác nhận mật khẩu',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Consumer<AuthVM>(
                                builder: (context, auth, _) {
                                  final error = _validationError ?? auth.error;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (error != null) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Text(
                                            error,
                                            style: const TextStyle(
                                              color: Color(0xFFFF6B6B),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1A1C1E),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          side: const BorderSide(color: Color(0xFF3A3F44), width: 1),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        onPressed: auth.isLoading ? null : _handleRegister,
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                'Đăng ký',
                                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1),
                                              ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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