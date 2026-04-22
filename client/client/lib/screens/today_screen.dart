// ignore_for_file: deprecated_member_use

// import 'package:client/screens/ask_lifeos-sheet.dart';
import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import 'ask_lifeos-sheet.dart';

class TodayScreen extends StatefulWidget {
  final Function(String) onNavigate;
  const TodayScreen({super.key, required this.onNavigate});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with TickerProviderStateMixin {
  bool _aiActive = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color accentBlue = Color(0xFF7BA5D6);
    const Color primaryRed = Color(0xFF510105);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                'Today is structured',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    '2 focus windows available  •  ',
                    style: TextStyle(color: Color(0xFF6B6B73), fontSize: 14),
                  ),
                  _buildAIBadge(accentBlue),
                ],
              ),
              const SizedBox(height: 40),
              _buildSectionHeader("LIVE PRIORITIES", "AI-ranked"),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: AuthService().getPriorities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return const Center(
                        child: CircularProgressIndicator(color: primaryRed),
                      );
                    final items = snapshot.data ?? [];
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _PriorityCard(
                        rank: index + 1,
                        title: items[index]['description'] ?? 'Untitled',
                        subtitle: items[index]['type'] ?? 'Priority',
                        isFirst: index == 0,
                      ),
                    );
                  },
                ),
              ),
              if (_aiActive) _buildAICard(accentBlue, primaryRed),
              const SizedBox(height: 16),
              _buildCommandBar(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIBadge(Color color) => Row(
    children: [
      Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        'AI active',
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
    ],
  );

  Widget _buildSectionHeader(String left, String right) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        left,
        style: const TextStyle(
          color: Color(0xFF404040),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      Text(
        right,
        style: const TextStyle(color: Color(0xFF6B6B73), fontSize: 11),
      ),
    ],
  );

  Widget _buildAICard(Color blue, Color red) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF121214),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PulseDot(color: blue, controller: _pulseController),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "You're most productive in the next 90 minutes. Lock focus?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lock focus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => setState(() => _aiActive = false),
              child: const Text(
                'Dismiss',
                style: TextStyle(color: Color(0xFF6B6B73)),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildCommandBar() => GestureDetector(
    onTap: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AskLifeOSSheet(),
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text(
            'Ask LIFEOS...',
            style: TextStyle(color: Color(0xFF6B6B73), fontSize: 16),
          ),
          const Spacer(),
          Icon(
            Icons.auto_awesome,
            color: Colors.white.withOpacity(0.05),
            size: 18,
          ),
        ],
      ),
    ),
  );
}

class _PriorityCard extends StatelessWidget {
  final int rank;
  final String title;
  final String subtitle;
  final bool isFirst;
  const _PriorityCard({
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: isFirst ? const Color(0xFF510105) : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1C),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: isFirst
                    ? const Color(0xFF510105)
                    : const Color(0xFF404040),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B6B73),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  final Color color;
  final AnimationController controller;
  const _PulseDot({required this.color, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.5).animate(controller),
          child: FadeTransition(
            opacity: Tween(begin: 0.5, end: 0.0).animate(controller),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
