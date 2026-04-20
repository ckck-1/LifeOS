import 'package:flutter/material.dart';
import '../core/logo_painter.dart';
import '../core/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSwitchToRegister;

  const LoginScreen({super.key, required this.onLoginSuccess, required this.onSwitchToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);
    
    if (success) {
      widget.onLoginSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Denied")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryRed = Color(0xFFFF3B30);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo Section
                Stack(alignment: Alignment.center, children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, color: primaryRed.withOpacity(0.05))),
                  CustomPaint(size: const Size(48, 48), painter: LifeOSLogoPainter(strokeColor: Colors.white, dotColor: primaryRed)),
                ]),
                const SizedBox(height: 24),
                const Text('LIFEOS', style: TextStyle(fontSize: 20, letterSpacing: -0.5, fontWeight: FontWeight.w500)),
                const Text('Your life, structured by intelligence', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 48),

                // Form
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Password"),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: _isLoading 
                      ? const Text("Entering LIFEOS...", style: TextStyle(color: Colors.white))
                      : const Text("Enter LIFEOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                // Footer
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(onPressed: widget.onSwitchToRegister, child: const Text("Create account", style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const Text("•", style: TextStyle(color: Colors.grey)),
                  TextButton(onPressed: () {}, child: const Text("Forgot access", style: TextStyle(color: Colors.grey, fontSize: 12))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    hintText: label,
    filled: true,
    fillColor: const Color(0xFF1C1C1E),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}