import 'package:flutter/material.dart';

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
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    _buildSquareBackButton(context),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'LifeOS Assistant',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 45), // To balance the back button
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Category Filter Chips
              _buildCategoryList(),
              const SizedBox(height: 30),
              // Latest Updates Section
              _buildSectionHeader('Latest Updates'),
              _buildHorizontalGrid([
                _buildAssistantCard(
                  'Opportunities\n& Income',
                  Icons.payments_outlined,
                  const Color(0xFFF8F9FA),
                ),
                _buildAssistantCard(
                  'Goals\n& Progress',
                  Icons.track_changes,
                  const Color(0xFFF8F9FA),
                ),
                _buildAssistantCard(
                  'Daily\nAdvice',
                  Icons.calendar_today_outlined,
                  const Color(0xFFF8F9FA),
                ),
              ]),
              const SizedBox(height: 20),
              // Recent Section
              _buildSectionHeader('Recent'),
              _buildHorizontalGrid([
                _buildAssistantCard(
                  'LifeOS',
                  Icons.chat_bubble_outline,
                  const Color(0xFFF8F9FA),
                  subtitle: 'Chat For All Life\nDecisions',
                ),
                _buildAssistantCard(
                  'Notes',
                  Icons.sticky_note_2_outlined,
                  const Color(0xFFF8F9FA),
                  subtitle: 'Organize Your Mind.',
                ),
                _buildAssistantCard(
                  'Tasks',
                  Icons.spa_outlined,
                  const Color(0xFFF8F9FA),
                  subtitle: 'Execute What Matters',
                ),
              ]),
              const SizedBox(height: 20),
              // Sessions Section
              _buildSectionHeader('Sessions'),
              _buildHorizontalGrid([
                _buildAssistantCard(
                  'Focus',
                  Icons.hourglass_empty,
                  const Color(0xFFF8F9FA),
                ),
                _buildAssistantCard(
                  'Deep Work',
                  Icons.bolt,
                  const Color(0xFFF8F9FA),
                ),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _buildChip('All', isSelected: true),
          _buildChip('Income', icon: Icons.favorite_border),
          _buildChip('Skills', icon: Icons.sports_basketball_outlined),
          _buildChip('Focus'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_forward, color: Colors.grey, size: 24),
        ],
      ),
    );
  }

  Widget _buildHorizontalGrid(List<Widget> cards) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(children: cards),
    );
  }

  Widget _buildAssistantCard(
    String title,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.2,
            ),
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
          // Circular Arrow Button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.access_time), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}
