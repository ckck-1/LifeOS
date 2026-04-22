import 'package:flutter/material.dart';
import 'package:frontendtwo/features/auth/data/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();

  // Colors from the provided UI image
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color primaryBlue = Color(0xFF40C4FF);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color cardColor = Color(0xFF1C222E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hello, John",
                    style: TextStyle(
                      color: accentGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CircleAvatar(backgroundColor: Colors.white, radius: 20),
                ],
              ),
              const SizedBox(height: 30),

              // DAILY FOCUS SECTION (Stacked Card UI)
              FutureBuilder(
                future: _authService.getDailyFocus(),
                builder: (context, snapshot) {
                  final focusData = snapshot.data;
                  return _buildDailyFocusCard(
                    focusData?['focus'] ?? "Loading focus...",
                  );
                },
              ),

              const SizedBox(height: 40),

              // AI SHORTCUTS (Real Icons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAIShortcut("Weekly-plan", Icons.event_note_rounded),
                  _buildAIShortcut("Tasks", Icons.task_alt_rounded),
                  _buildAIShortcut("Opportunities", Icons.auto_awesome_rounded),
                  _buildAIShortcut("Goals", Icons.track_changes_rounded),
                ],
              ),

              const SizedBox(height: 40),
              const Text(
                "Active Goals",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 20),

              // ACTIVE GOALS LIST
              FutureBuilder<List<dynamic>>(
                future: _authService.getGoals(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final goals = snapshot.data!;
                  return Column(
                    children: goals
                        .map(
                          (g) =>
                              _buildGoalItem(g['title'], g['progress'] ?? 50),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDailyFocusCard(String text) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Card layers to create that stacked effect from your image
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 300,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Daily Focus",
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Start Session",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIShortcut(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: darkBg, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: primaryBlue, fontSize: 12)),
      ],
    );
  }

  Widget _buildGoalItem(String title, int progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress / 100,
                  color: accentGreen,
                  backgroundColor: Colors.white10,
                  strokeWidth: 8,
                ),
              ),
              Text(
                "$progress%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Goal one",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF121826),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home_filled, color: Colors.white),
          Icon(Icons.search, color: Colors.white38),
          Icon(Icons.chat_bubble_outline, color: Colors.white38),
          Icon(Icons.favorite_border, color: Colors.white38),
          Icon(Icons.person_outline, color: Colors.white38),
        ],
      ),
    );
  }
}
