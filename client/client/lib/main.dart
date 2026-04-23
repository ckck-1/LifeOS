import 'package:flutter/material.dart';
import 'package:frontendtwo/screens/onboarding.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatefulWidget {
  const LifeOSApp({super.key});

  @override
  State<LifeOSApp> createState() => _LifeOSAppState();
}

class _LifeOSAppState extends State<LifeOSApp> {
  bool _hasSeenOnboarding = false;
  String? _token;

  void _completeOnboarding() {
    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  void _onLoginSuccess(String token) {
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _getCurrentScreen(),
    );
  }

  Widget _getCurrentScreen() {
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(onFinish: _completeOnboarding);
    }

    if (_token == null) {
      return LoginScreen(onLoginSuccess: _onLoginSuccess);
    }

    return HomeScreen(token: _token!);
  }
}
