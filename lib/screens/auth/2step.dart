import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AppRoutes.dart';
import '../../viewmodel/authVM.dart';
import '../../app_layout.dart';

class TwoStepScreen extends StatefulWidget {
  const TwoStepScreen({super.key});

  @override
  State<TwoStepScreen> createState() => _TwoStepScreenState();
}

class _TwoStepScreenState extends State<TwoStepScreen> {
  final _otpController = TextEditingController();
  String? _validationError;

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      setState(() => _validationError = 'Vui lòng nhập mã OTP.');
      return;
    }

    if (otp.length < 6) {
      setState(() => _validationError = 'Mã OTP phải có 6 chữ số.');
      return;
    }

    setState(() => _validationError = null);

    final auth = context.read<AuthVM>();
    auth.clearError();

    final success = await auth.verifyOtp(otp);
    if (!mounted) return;

    if (success) {
      final role = auth.user?.role;
      if (role == 'ADMIN') {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.admin, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    }
  }

  Future<void> _handleResend() async {
    final auth = context.read<AuthVM>();
    final success = await auth.resendOtp();
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Mã OTP đã được gửi lại!' : 'Gửi lại mã thất bại.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthVM>();
    final email = auth.twoStepEmail ?? 'email của bạn';

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

                    // ─── MASTER PARENT CONTAINER ───
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
                            
                            // ─── HEADER BAR ───
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
                                      'VERIFY',
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

                            // ─── FORM CONTENT ───
                            Container(
                              color: const Color(0xFF151617),
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    'Một mã xác thực đã được gửi đến email:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 24),

                                  // OTP field
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 18, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLength: 6,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      hintText: '******',
                                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18, letterSpacing: 8),
                                      prefixIcon: Icon(Icons.security_rounded, color: Colors.grey[500]),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.25),
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
                                  const SizedBox(height: 16),

                                  // Error display
                                  Builder(builder: (context) {
                                    final error = _validationError ?? auth.error;
                                    if (error == null) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Text(
                                        error,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFFFF6B6B),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }),

                                  // Verify button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1C1E),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      side: const BorderSide(color: Color(0xFF3A3F44), width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onPressed: auth.isLoading ? null : _handleVerify,
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
                                            'Verify OTP',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Resend link
                                  TextButton(
                                    onPressed: auth.isLoading ? null : _handleResend,
                                    child: const Text(
                                      'Gửi lại mã OTP',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),
                                  
                                  // Back to login
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Quay lại Đăng nhập',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
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
          ),
        ],
      ),
    );
  }
}
