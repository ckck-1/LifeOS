import 'package:flutter/material.dart';
import './splashScreen.dart'; // 1. IMPORT YOUR SPLASH FILE HERE

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeOS', // Updated title
      theme: ThemeData(
        // 2. FIXED SYNTAX HERE: Added 'ColorScheme' before '.fromSeed'
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 3. SET SPLASH SCREEN AS HOME
      home: const SplashScreen(),
    );
  }
}
