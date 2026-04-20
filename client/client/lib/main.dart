import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/today_screen.dart';

void main() {
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
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
        // Consistent theme colors across the app
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0A0A0B),
          surface: Color(0xFF121214),
          primary: Color(0xFF510105),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

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
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case AppStatus.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onComplete: () => setState(() => _status = AppStatus.authLogin),
        );
      case AppStatus.authLogin:
        return LoginScreen(
          key: const ValueKey('login'),
          onLoginSuccess: () => setState(() => _status = AppStatus.authenticated),
          onSwitchToRegister: () => setState(() => _status = AppStatus.authRegister),
        );
      case AppStatus.authRegister:
        return RegisterScreen(
          key: const ValueKey('register'),
          onRegisterSuccess: () => setState(() => _status = AppStatus.authenticated),
          onSwitchToLogin: () => setState(() => _status = AppStatus.authLogin),
        );
      case AppStatus.authenticated:
        return const HomeScreen(key: ValueKey('home'));
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      TodayScreen(onNavigate: (s) => setState(() => _selectedIndex = 1)),
      const Center(child: Text("Tasks Screen")),
      const Center(child: Text("Goals Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF1A1A1C), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          backgroundColor: const Color(0xFF0A0A0B),
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color(0xFF404040),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.panorama_fish_eye), label: "Today"),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Tasks"),
            BottomNavigationBarItem(icon: Icon(Icons.track_changes_rounded), label: "Goals"),
          ],
        ),
      ),
    );
  }
}