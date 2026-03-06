import 'package:flutter/material.dart';
import 'package:lifeos_frontend/opportunities.dart';

void main() {
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AiAssistantScreen(),
    );
  }
}

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildSquareBackButton(context),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "LifeOS Assistant",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 45),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Category Chips
              _buildCategoryList(),

              const SizedBox(height: 30),

              /// Latest Updates
              _buildSectionHeader("Latest Updates"),
              _buildHorizontalGrid(context, [
                _buildAssistantCard(
                  context,
                  "Opportunities\n& Income",
                  Icons.payments_outlined,
                  const OpportunitiesScreen(),
                ),
                _buildAssistantCard(
                  context,
                  "Goals\n& Progress",
                  Icons.track_changes,
                  const GoalsScreen(),
                ),
                _buildAssistantCard(
                  context,
                  "Daily\nAdvice",
                  Icons.calendar_today_outlined,
                  const DailyAdviceScreen(),
                ),
              ]),

              const SizedBox(height: 20),

              /// Recent
              _buildSectionHeader("Recent"),
              _buildHorizontalGrid(context, [
                _buildAssistantCard(
                  context,
                  "LifeOS",
                  Icons.chat_bubble_outline,
                  const ChatScreen(),
                  subtitle: "Chat For All Life\nDecisions",
                ),
                _buildAssistantCard(
                  context,
                  "Notes",
                  Icons.sticky_note_2_outlined,
                  const NotesScreen(),
                  subtitle: "Organize Your Mind.",
                ),
                _buildAssistantCard(
                  context,
                  "Tasks",
                  Icons.spa_outlined,
                  const TasksScreen(),
                  subtitle: "Execute What Matters",
                ),
              ]),

              const SizedBox(height: 20),

              /// Sessions
              _buildSectionHeader("Sessions"),
              _buildHorizontalGrid(context, [
                _buildAssistantCard(
                  context,
                  "Focus",
                  Icons.hourglass_empty,
                  const FocusSessionScreen(),
                ),
                _buildAssistantCard(
                  context,
                  "Deep Work",
                  Icons.bolt,
                  const DeepWorkScreen(),
                ),
              ]),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// BACK BUTTON
  Widget _buildSquareBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
        onPressed: () {},
      ),
    );
  }

  /// CATEGORY CHIPS
  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _buildChip("All", isSelected: true),
          _buildChip("Income"),
          _buildChip("Skills"),
          _buildChip("Focus"),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// SECTION HEADER
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// HORIZONTAL CARD LIST
  Widget _buildHorizontalGrid(BuildContext context, List<Widget> cards) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(children: cards),
    );
  }

  /// CARD
  Widget _buildAssistantCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen, {
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
            const SizedBox(height: 15),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black26,
              child: Icon(Icons.arrow_forward, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// BOTTOM NAV
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// PLACEHOLDER SCREENS
////////////////////////////////////////////////////////////

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Goals & Progress");
  }
}

class DailyAdviceScreen extends StatelessWidget {
  const DailyAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Daily Advice");
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("LifeOS Chat");
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Notes");
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Tasks");
  }
}

class FocusSessionScreen extends StatelessWidget {
  const FocusSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Focus Session");
  }
}

class DeepWorkScreen extends StatelessWidget {
  const DeepWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _blankScreen("Deep Work");
  }
}

/// GENERIC BLANK PAGE
Widget _blankScreen(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
    body: Center(
      child: Text("$title Screen", style: const TextStyle(fontSize: 22)),
    ),
  );
}
