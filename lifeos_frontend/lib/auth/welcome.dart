import 'package:flutter/material.dart';
import 'package:lifeos_frontend/auth/login.dart';
import 'package:lifeos_frontend/auth/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              // ... inside Column children
              const Spacer(flex: 2),

              // --- LOGO ---
              Center(
                child: Image.asset(
                  'assets/logo.png', // Ensure the path matches your project structure
                  height: 100, // Matches the previous icon size
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // --- TITLE ---
              const Text(
                'Welcome to\nLifeOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -1.0,
                  height: 1.2,
                ),
              ),
              const Spacer(flex: 2),
              // --- PRIMARY BUTTONS ---
              // --- Update the build method of WelcomeScreen ---

              // ... inside Column children
              _buildActionButton(
                label: 'Log in',
                backgroundColor: const Color(0xFF121212),
                textColor: Colors.white,
                hasShadow: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Sign up',
                backgroundColor: const Color(0xFFE5E5E5),
                textColor: Colors.grey.shade600,
                onPressed: () {
                  // NAVIGATION ADDED HERE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
              ),
              // ...
              const Spacer(flex: 1),
              // --- SOCIAL SECTION ---
              Text(
                'Continue With Accounts',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      'GOOGLE',
                      const Color(0xFFF1D1D1),
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      'FACEBOOK',
                      const Color(0xFFD1DDF1),
                      const Color(0xFF5C85C1),
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

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed, // <--- Add this line
    bool hasShadow = false,
  }) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed, // <--- Use the variable here
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, Color color, Color textColor) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
