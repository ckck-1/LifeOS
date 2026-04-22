import 'dart:convert';
import 'package:flutter/material.dart';
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
  String userName = "Loading..."; // Variable to hold the user's name
  List<dynamic> activeGoals = [];
  bool isLoading = true;

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
        // Update '/auth/me' to match your actual backend user profile endpoint
        http.get(Uri.parse('$baseUrl/auth/me'), headers: headers), 
      ]);

      if (mounted) {
        setState(() {
          // 1. Parse /ai/daily-focus.
          if (responses[0].statusCode == 200) {
            final focusData = json.decode(responses[0].body);
            dailyFocusText = focusData['response'] ?? "Stay productive today.";
          }

          // 2. Parse /goals.
          if (responses[1].statusCode == 200) {
            activeGoals = json.decode(responses[1].body);
          }

          // 3. Parse User Profile.
          if (responses[2].statusCode == 200) {
            final userData = json.decode(responses[2].body);
            // Adjust 'name' or 'firstName' based on your actual JSON response keys
            userName = userData['name'] ?? userData['firstName'] ?? "User"; 
          } else {
            userName = "User"; // Fallback if the endpoint fails or doesn't exist yet
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
              _buildQuickActions(brandBlue),
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
            // Use the dynamically loaded name here
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: const StadiumBorder(),
            ),
            child: const Text(
              "Start Session",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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
        _actionIcon("Weekly-plan", Icons.calendar_today_outlined, blue),
        _actionIcon("Tasks", Icons.check_box_outline_blank, blue),
        _actionIcon("Opportunities", Icons.lightbulb_outline, blue),
        _actionIcon("Goals", Icons.flag_outlined, blue),
      ],
    );
  }

  Widget _actionIcon(String label, IconData icon, Color blue) {
    return Column(
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
    );
  }

  Widget _buildGoalsList(Color green) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activeGoals.isEmpty) {
      return const Text(
        "No active goals found.",
        style: TextStyle(color: Colors.white54),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activeGoals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, i) {
        final goal = activeGoals[i];

        // Calculate progress based on API targetValue and currentValue
        double target = (goal['targetValue'] ?? 1).toDouble();
        double current = (goal['currentValue'] ?? 0).toDouble();
        double progressRatio = target > 0 ? (current / target) : 0;
        int progressPercent = (progressRatio * 100).toInt();

        return Row(
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progressRatio,
                    strokeWidth: 8,
                    color: green,
                    backgroundColor: const Color(0xFF1D2635),
                  ),
                  Center(
                    child: Text(
                      "$progressPercent%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
                    "Goal ${i + 1}",
                    style: const TextStyle(
                      color: Color(0xFF7E8494),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goal['description'] ?? 'Unnamed Goal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Visual pill matching the screenshot
                  Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
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
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: const Color(0xFF1D2635)),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF0B1220),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 26),
            activeIcon: Icon(Icons.home, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border, size: 26),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 26),
            label: '',
          ),
        ],
      ),
    );
  }
}