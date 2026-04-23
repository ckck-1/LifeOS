import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontendtwo/screens/SessionScreen.dart';
import 'package:frontendtwo/screens/ai_chat.dart'; // IMPORT CHAT
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String token;
  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = "https://lifeos-7nj8.onrender.com";
  String dailyFocusText = "Loading your daily focus...";
  String userName = "Loading...";
  List<dynamic> activeGoals = [];
  bool isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final headers = {
      'Authorization': 'Bearer ${widget.token}',
      'Accept': 'application/json',
    };
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/ai/daily-focus'), headers: headers),
        http.get(Uri.parse('$baseUrl/goals'), headers: headers),
        http.get(Uri.parse('$baseUrl/auth/me'), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          if (responses[0].statusCode == 200)
            dailyFocusText =
                json.decode(responses[0].body)['response'] ??
                "Stay productive.";
          if (responses[1].statusCode == 200)
            activeGoals = json.decode(responses[1].body);
          if (responses[2].statusCode == 200) {
            final user = json.decode(responses[2].body);
            userName = user['name'] ?? user['firstName'] ?? "User";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBg = Color(0xFF0B1220);
    const Color brandBlue = Color(0xFF40C4FF);
    const Color brandGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(brandGreen),
              _buildDailyFocusCard(brandBlue),
              const SizedBox(height: 32),
              _buildQuickActions(brandBlue), // Shortcuts
              const SizedBox(height: 32),
              const Text(
                "Active Goals",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildGoalsList(brandGreen),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(brandBlue),
    );
  }

  Widget _buildHeader(Color green) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, $userName',
            style: TextStyle(
              color: green,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const CircleAvatar(backgroundColor: Colors.white, radius: 22),
        ],
      ),
    );
  }

  Widget _buildDailyFocusCard(Color blue) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D2635),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Focus',
            style: TextStyle(
              color: blue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dailyFocusText,
            style: const TextStyle(
              color: Color(0xFF7E8494),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showTaskSelector(context, blue),
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: const Color(0xFF0B1220),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(60),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Start Session",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color blue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionIcon("Weekly", Icons.calendar_today_outlined, blue, () {}),
        _actionIcon("AI Chat", Icons.auto_awesome, blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AIChatScreen(token: widget.token),
            ),
          );
        }),
        _actionIcon("Tasks", Icons.check_box_outline_blank, blue, () {}),
        _actionIcon("Goals", Icons.flag_outlined, blue, () {}),
      ],
    );
  }

  Widget _actionIcon(
    String label,
    IconData icon,
    Color blue,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF0B1220), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: blue,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(Color green) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeGoals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, i) {
        final goal = activeGoals[i];
        return Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value:
                        (goal['currentValue'] ?? 0) /
                        (goal['targetValue'] ?? 1),
                    strokeWidth: 8,
                    color: green,
                    backgroundColor: const Color(0xFF1D2635),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['description'] ?? 'Goal',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav(Color active) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0B1220),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white38,
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AIChatScreen(token: widget.token),
            ),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }

  Future<void> _showTaskSelector(BuildContext context, Color blue) async {
    // ... existing _showTaskSelector code ...
  }
}
