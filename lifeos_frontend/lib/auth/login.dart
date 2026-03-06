import 'package:flutter/material.dart';
import 'package:lifeos_frontend/auth/register.dart';
import 'package:lifeos_frontend/home.dart';
import 'package:lifeos_frontend/services/auth_service.dart';
import 'package:lifeos_frontend/auth/welcome.dart'; // Your post-login page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  void _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    debugPrint("LOGIN BUTTON PRESSED");
    debugPrint("Email entered: $email");

    if (email.isEmpty || password.isEmpty) {
      debugPrint("ERROR: Fields are empty");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _loading = true);
    debugPrint("Sending login request to server...");

    try {
      final success = await _authService.login(email, password);

      debugPrint("Server response received");
      debugPrint("Login success status: $success");

      setState(() => _loading = false);

      if (success) {
        debugPrint("Login successful. Navigating to AI Assistant Screen");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AiAssistantScreen()),
        );
      } else {
        debugPrint("Login failed: Invalid credentials");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);

      debugPrint("LOGIN ERROR OCCURRED");
      debugPrint("Error details: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error connecting to server: $e')));
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
              ),
              const SizedBox(height: 40),
              // Header
              const Text(
                'Login Your\nAccount',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 40),
              // Email Field
              CustomTextField(
                hint: 'JosephIren@Mail.Com',
                icon: Icons.mail_outline,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              // Password Field
              CustomTextField(
                hint: '●●●●●●●●●●●●',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password ?',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF121515),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              // Switch to Sign Up
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Register (Replacement)
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(text: "Create New Account? "),
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: Color(0xFF121515),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Social Footer
              const Center(
                child: Text(
                  "Continue With Accounts",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      label: 'GOOGLE',
                      color: const Color(0xFFF5D1CB),
                      textColor: const Color(0xFFD35D47),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SocialButton(
                      label: 'FACEBOOK',
                      color: const Color(0xFFD1DCEB),
                      textColor: const Color(0xFF5A7DB0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
