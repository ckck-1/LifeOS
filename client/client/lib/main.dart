import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      // Apply a consistent Dark Theme to match the LifeOS aesthetic
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF3B30), // Your Primary Red
          background: Color(0xFF000000),
          surface: Color(0xFF1C1C1E), // Surface-1 equivalent
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(letterSpacing: -0.5),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

/// The AppRoot manages the navigation state between Auth and Main App
enum AppStatus { splash, authLogin, authRegister, authenticated }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppStatus _status = AppStatus.splash;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      // The child is determined by the current _status
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_status) {
      case AppStatus.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () {
            setState(() => _status = AppStatus.authLogin);
          },
        );

      case AppStatus.authLogin:
        return LoginScreen(
          key: const ValueKey('login'),
          onLoginSuccess: () {
            setState(() => _status = AppStatus.authenticated);
          },
          onSwitchToRegister: () {
            setState(() => _status = AppStatus.authRegister);
          },
        );

      case AppStatus.authRegister:
        return RegisterScreen(
          key: const ValueKey('register'),
          onRegisterSuccess: () {
            // Usually after registration, you go to home or login
            setState(() => _status = AppStatus.authenticated);
          },
          onSwitchToLogin: () {
            setState(() => _status = AppStatus.authLogin);
          },
        );

      case AppStatus.authenticated:
        return const HomeScreen(
          key: ValueKey('home'),
        );
    }
  }
}