import 'package:flutter/material.dart';
import '../core/logo_painter.dart';
import '../core/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess, onSwitchToRegister;
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onSwitchToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Define colors inside build to ensure they are available to the context
    const Color primaryRed = Color(0xFF510105);
    const Color inputBackground = Color(0xFF121316);
    const Color mutedText = Color(0xFF6B6B73);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              CustomPaint(
                size: const Size(56, 56),
                painter: LifeOSLogoPainter(
                  strokeColor: Colors.white.withOpacity(0.4),
                  dotColor: primaryRed,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'LifeOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your life, structured by intelligence',
                style: TextStyle(color: mutedText, fontSize: 14),
              ),
              const SizedBox(height: 60),
              _buildTextField(
                _emailController,
                "Email",
                inputBackground,
                mutedText,
                primaryRed,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _passwordController,
                "Password",
                inputBackground,
                mutedText,
                primaryRed,
                isObscure: true,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    disabledBackgroundColor: primaryRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoading ? "Entering LIFEOS" : "Enter LIFEOS",
                    style: TextStyle(
                      color: Colors.white.withOpacity(_isLoading ? 0.5 : 1.0),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: widget.onSwitchToRegister,
                    child: const Text(
                      "Create account",
                      style: TextStyle(color: mutedText, fontSize: 14),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('•', style: TextStyle(color: mutedText)),
                  ),
                  const Text(
                    "Forgot access",
                    style: TextStyle(color: mutedText, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    Color bg,
    Color textCol,
    Color caret, {
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        cursorColor: caret,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textCol.withOpacity(0.5)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
