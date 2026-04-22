import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  final Function(String) onLoginSuccess;
  
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://lifeos-7nj8.onrender.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        widget.onLoginSuccess(data['token']);
      } else {
        _showError("Login failed. Please check your credentials.");
      }
    } catch (e) {
      _showError("Network error. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF40C4FF);
    const Color brandGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text("Welcome back", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Enter your credentials to continue", style: TextStyle(color: Color(0xFF7E8494), fontSize: 16)),
              const SizedBox(height: 50),
              
              _buildInputLabel("Email address"),
              _buildTextField(_emailController, "john.carter@example.com", false),
              const SizedBox(height: 20),
              
              _buildInputLabel("Password"),
              _buildTextField(_passwordController, "••••••••••••", true),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot password?", style: TextStyle(color: Color(0xFF7E8494), fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: const StadiumBorder(),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Login ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF7E8494))),
                  GestureDetector(
                    onTap: () {}, // Handle Signup routing
                    child: const Text("Sign up", style: TextStyle(color: brandGreen, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white10),
              const SizedBox(height: 30),
              
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Color(0xFF7E8494), fontSize: 12),
                  children: [
                    TextSpan(text: "By continuing, you agree to our "),
                    TextSpan(text: "Terms", style: TextStyle(color: brandGreen, decoration: TextDecoration.underline)),
                    TextSpan(text: " and\n"),
                    TextSpan(text: "Privacy Policy", style: TextStyle(color: brandGreen, decoration: TextDecoration.underline)),
                    TextSpan(text: "."),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Color(0xFF7E8494), fontSize: 14)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black45),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ) : null,
      ),
    );
  }
}