import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AppRoutes.dart';
import '../../viewmodel/authVM.dart';
import '../../app_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final bool _isLogin = true;
  String? _validationError;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _validationError = 'Email and password are required.');
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PersistentBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ─── 1. MASTER PARENT CONTAINER (Outer Border + Glow Shadow) ───
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05), // Whispy outer rim edge
                      width: 3,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.shade800,
                    //     spreadRadius: 1,
                    //     blurRadius: 20,
                    //   ),
                    // ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0), // Matte slate outline framework
                        width: 3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        // ─── DIV A: THE METALLIC HEADER BAR (No Title) ───
                        Container(
                          height: 58, 
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(255, 18, 18, 18), // Top highlight edge
                                Color.fromARGB(255, 18, 19, 20), // Main dark slate bar
                                Color(0xFF121314), // Shadows into the seam line
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                          // ShaderMask keeps the action icons glowing with metallic gradients
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE2E8F0), // Cool platinum silver reflection
                                Color(0xFF94A3B8), // Soft chrome shadows
                                Color(0xFFCBD5E1),
                              ],
                            ).createShader(bounds),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontFamily: 'authfont',
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  )
                                )
                              ]
                            )
                          ),
                        ),

                        // ─── DIV B: THE FORM CONTENT CONTAINER ───
                        Container(
                          color: const Color(0xFF151617), // Rich, clean premium matte black container base
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),

                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Nhập địa chỉ mail',
                                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.grey[500]),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25), // Sunken field matrix look
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135), // Smooth custom charcoal wire frame
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Nhập mật khẩu',
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
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(
                                      color: Color(0xFF2E3135),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    borderSide: BorderSide(
                                      color: Colors.white38,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              // Clear Actions Row (Đăng ký ngay & Quên mật khẩu)
                              if (_isLogin) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushReplacementNamed(context, AppRoutes.register);
                                      },
                                      child: const Text(
                                        'Đăng ký ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => forgotPassword(context),
                                      child: const Text(
                                        'Quên mật khẩu',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 16),
                              ],

                              const SizedBox(height: 12),

                              Consumer<AuthVM>(
                                builder: (context, auth, _) {
                                  final error = _validationError ?? auth.error;
                                  if (error == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(
                                      error,
                                      style: const TextStyle(
                                        color: Color(0xFFFF6B6B),
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Submit button (Vào Button)
                              Consumer<AuthVM>(
                                builder: (context, auth, _) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1C1E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      side: const BorderSide(color: Color(0xFF3A3F44), width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: auth.isLoading ? null : _handleLogin,
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
                                            'Sign In',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),

                              // Divider Lines
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('hoặc', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ),
                                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Authentic Social Layout Icons Strip
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No OAUTH service yet unfortunately',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    )
                                  )
                                ],
                              )
                            ],
                          ),
                        ),

                      ], 
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),],),
    );
  }

  // Quick structural builder for the circle social media nodes at the card footer base
  Widget _buildSocialCircle(IconData icon, Color bg, {bool isGoogle = false}) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Icon(
          icon,
          color: bg,
          size: isGoogle ? 32 : 24,
        ),
      ),
    );
  }
}