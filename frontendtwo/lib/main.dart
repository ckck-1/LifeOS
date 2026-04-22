import 'package:flutter/material.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(fontFamily: 'Inter'), // Ensure you add Inter font to pubspec.yaml
      home: OnboardingScreen(),
    );
  }
}