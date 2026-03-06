import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ⚡ Must be first

  // Optional: Initialize SharedPreferences early if needed
  final prefs = await SharedPreferences.getInstance();

  // Hide status bar globally
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
