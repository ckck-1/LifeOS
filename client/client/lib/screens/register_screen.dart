import 'package:flutter/material.dart';
import '../core/logo_painter.dart';
import '../core/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onSwitchToLogin;

  const RegisterScreen({super.key, required this.onRegisterSuccess, required this.onSwitchToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    bool success = await AuthService().register(_nameController.text, _emailController.text, _passwordController.text);
    setState(() => _isLoading = false);
    if (success) widget.onRegisterSuccess();
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFFF3B30);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomPaint(size: const Size(48, 48), painter: LifeOSLogoPainter(strokeColor: Colors.white, dotColor: primaryRed)),
                const SizedBox(height: 24),
                const Text('Initialize LIFEOS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                const Text('Create your personal operating system', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 48),
                TextField(controller: _nameController, decoration: _inputDecoration("Name")),
                const SizedBox(height: 16),
                TextField(controller: _emailController, decoration: _inputDecoration("Email")),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: true, decoration: _inputDecoration("Password")),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                    child: Text(_isLoading ? "Initializing system..." : "Initialize System", style: const TextStyle(color: Colors.white)),
                  ),
                ),
                TextButton(onPressed: widget.onSwitchToLogin, child: const Text("Already have access? Enter LIFEOS", style: TextStyle(color: Colors.grey, fontSize: 12))),
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
  );
}