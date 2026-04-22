import 'package:flutter/material.dart';
import 'package:frontendtwo/screens/onboarding.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LifeOSApp(),
  ));
}

class LifeOSApp extends StatefulWidget {
  const LifeOSApp({super.key});

  @override
  State<LifeOSApp> createState() => _LifeOSAppState();
}

class _LifeOSAppState extends State<LifeOSApp> {
  bool _hasSeenOnboarding = false;

  void _completeOnboarding() => setState(() => _hasSeenOnboarding = true);

  @override
  Widget build(BuildContext context) {
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(onFinish: _completeOnboarding);
    }

    return LoginScreen(
      onLoginSuccess: (String token) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen(token: token)),
        );
      },
    );
  }
}