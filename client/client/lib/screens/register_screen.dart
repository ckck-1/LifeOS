import 'package:flutter/material.dart';
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
      widget.onRegisterSuccess();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors consistent with Login screen
    const Color scaffoldBg = Color(0xFF0B1220);
    const Color brandBlue = Color(0xFF40C4FF);
    const Color inputFieldBg = Colors.white;
    const Color hintColor = Color(0xFFB0B4C0);
    const Color textColor = Color(0xFF1D212B);
    const Color mutedText = Color(0xFF7E8494);
    const Color linkGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Header section
              const Text(
                'Initialize LifeOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create your personal operating system',
                style: TextStyle(color: mutedText, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Form Labels and Fields
              _buildLabel("Full name"),
              _buildTextField(
                _nameController,
                "John Carter",
                inputFieldBg,
                hintColor,
                brandBlue,
                textColor,
              ),
              const SizedBox(height: 20),

              _buildLabel("Email address"),
              _buildTextField(
                _emailController,
                "john.carter@brixagency.com",
                inputFieldBg,
                hintColor,
                brandBlue,
                textColor,
              ),
              const SizedBox(height: 20),

              _buildLabel("Password"),
              _buildTextField(
                _passwordController,
                "••••••••••••",
                inputFieldBg,
                hintColor,
                brandBlue,
                textColor,
                isObscure: true,
                suffixIcon: const Icon(
                  Icons.visibility_off_outlined,
                  color: mutedText,
                  size: 20,
                ),
              ),

              const SizedBox(height: 40),

              // Register/Initialize Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoading ? "Initializing..." : "Initialize System",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!_isLoading)
                        const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Switch to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have access? ",
                    style: TextStyle(color: mutedText, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: widget.onSwitchToLogin,
                    child: const Text(
                      "Enter LifeOS",
                      style: TextStyle(
                        color: linkGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF7E8494), fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    Color bg,
    Color hintCol,
    Color caret,
    Color textCol, {
    bool isObscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      cursorColor: caret,
      style: TextStyle(color: textCol, fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: hint,
        hintStyle: TextStyle(color: hintCol),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(35),
          borderSide: BorderSide(color: caret, width: 1.5),
        ),
      ),
    );
  }
}
