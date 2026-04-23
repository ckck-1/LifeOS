import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeeklyPlanScreen extends StatefulWidget {
  final String token;
  const WeeklyPlanScreen({super.key, required this.token});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;

  final Color scaffoldBg = const Color(0xFF0B1220);
  final Color accentBlue = const Color(0xFF40C4FF);

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    const url = 'https://lifeos-7nj8.onrender.com/ai/weekly-plan';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<String> dayLabels = [
          "MO",
          "TU",
          "WE",
          "TH",
          "FR",
          "SA",
          "SU",
        ];

        setState(() {
          _plans = [
            {
              "day": dayLabels[0],
              "date": "04/23/2026",
              "content": data['response']?.toString() ?? "No content available",
              "isExpanded": false,
            },
            {
              "day": dayLabels[1],
              "date": "04/24/2026",
              "content":
                  "Started with heat mapping. Users were clicking 'Learn More' but bouncing at 8 seconds. The button worked, but the landing content didn't match expectations.",
              "isExpanded": false,
            },
            {
              "day": dayLabels[2],
              "date": "04/25/2026",
              "content":
                  "Solution: Rewrote copy to match button promise. Added social proof above fold. A/B tested 3 variants. Simple changes, massive impact ✨",
              "isExpanded": false,
            },
          ];

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(backgroundColor: Colors.white, radius: 15),
        ),
        title: const Text(
          "Weekly Plan",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(backgroundColor: Colors.white, radius: 15),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            "Optimized by LifeOS",
            style: TextStyle(
              color: accentBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) => _buildTimelineItem(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final plan = _plans[index];

    final String day = plan['day']?.toString() ?? '';
    final String date = plan['date']?.toString() ?? '';
    final String content = plan['content']?.toString() ?? '';
    final bool isExpanded = plan['isExpanded'] ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: accentBlue, width: 2),
              ),
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            if (index != _plans.length - 1)
              Container(
                width: 2,
                height: isExpanded ? 200 : 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [accentBlue, accentBlue.withOpacity(0.05)],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 6),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                secondChild: Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

              _buildActionRow(index, isExpanded),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(int index, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.white38, size: 20),
          const Spacer(),
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _plans[index]['isExpanded'] = !isExpanded;
              });
            },
            child: Icon(
              isExpanded ? Icons.close_fullscreen : Icons.open_in_full,
              color: Colors.white38,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
