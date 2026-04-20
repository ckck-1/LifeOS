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
    setState(() => _isLoading = true);
    bool success = await AuthService().register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) widget.onRegisterSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomPaint(
                  size: const Size(48, 48),
                  painter: LifeOSLogoPainter(
                    strokeColor: theme.colorScheme.onBackground,
                    dotColor: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Initialize LifeOS', style: theme.textTheme.titleLarge),
                const SizedBox(height: 48),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: "Name"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: "Email"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Password"),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isLoading
                          ? "Initializing system..."
                          : "Initialize System",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  child: Text(
                    "Already have access? Enter LifeOS",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
