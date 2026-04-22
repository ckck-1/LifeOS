import 'package:flutter/material.dart';
import 'package:frontendtwo/core/constants/colors.dart';
import 'package:frontendtwo/features/auth/data/auth_service.dart'; // Ensure this matches your file path
import 'package:frontendtwo/features/auth/presentation/screens/register_screen.dart';
import 'package:frontendtwo/features/home/presentation/screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Logic Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Updated Logic handling based on your AuthService
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. We change 'bool' to 'var' or 'dynamic' to stop the type error
      final response = await AuthService().login(email, password);

      if (!mounted) return;

      // 2. Check the status code from the Dio Response
      // Typically 200 or 201 means success
      if (response.statusCode == 200 || response.statusCode == 201) {
        
        // Navigation on success
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Helpful for debugging: print the error to console
      print("Login Error: $e");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Welcome back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enter your credentials to continue",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 60),

              _buildLabel("Email address"),
              _buildTextField(
                "john.carter@brixagency.com",
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              _buildLabel("Password"),
              _buildTextField(
                "••••••••••••••",
                _passwordController,
                isPassword: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot password?",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 3. Functional Button with Loading State
              _buildActionButton(
                _isLoading ? "Processing..." : "Login →",
                context,
                _isLoading ? null : _handleLogin,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                      style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  RegisterScreen()),
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: AppColors.secondarySuccess,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.white24, thickness: 1),
              const SizedBox(height: 24),

              // Footer Legal Text
              RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  children: [
                    TextSpan(text: "By continuing, you agree to our "),
                    TextSpan(
                        text: "Terms",
                        style: TextStyle(
                            color: AppColors.secondarySuccess,
                            decoration: TextDecoration.underline)),
                    TextSpan(text: " and "),
                    TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                            color: AppColors.secondarySuccess,
                            decoration: TextDecoration.underline)),
                    TextSpan(text: "."),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Component Builders (Preserved UI) ---

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, BuildContext context, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF40C4FF),
          disabledBackgroundColor: const Color(0xFF40C4FF).withOpacity(0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}