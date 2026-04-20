import 'package:flutter/material.dart';
import '../core/logo_painter.dart';
import '../core/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess, onSwitchToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  void _handleRegister() async {
    print("🚀 REGISTER BUTTON CLICKED");

    setState(() => _isLoading = true);

    bool success = await AuthService().register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    print("✅ REGISTER RESULT: $success");

    if (!mounted) return;

    if (success) {
      print("🔥 CALLING onRegisterSuccess()");
      widget.onRegisterSuccess(); // THIS MUST FIRE
    } else {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Initialize LIFEOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Create your personal operating system',
                style: TextStyle(color: mutedText, fontSize: 14),
              ),

              const SizedBox(height: 60),

              _buildTextField(
                _nameController,
                "Name",
                inputBackground,
                mutedText,
                primaryRed,
              ),
              const SizedBox(height: 12),
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
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    disabledBackgroundColor: primaryRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isLoading ? "Initializing System..." : "Initialize System",
                    style: TextStyle(
                      color: Colors.white.withOpacity(_isLoading ? 0.5 : 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: widget.onSwitchToLogin,
                child: const Text(
                  "Already have access? Enter LifeOS",
                  style: TextStyle(color: mutedText),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
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
        style: const TextStyle(color: Colors.white),
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
